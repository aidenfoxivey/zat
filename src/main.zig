const jdz_allocator = @import("jdz_allocator");
const std = @import("std");
const Allocator = std.mem.Allocator;

const stdin = std.io.getStdIn().reader();
const stdout_file = std.io.getStdOut().writer();
var bw = std.io.bufferedWriter(stdout_file);
const stdout = bw.writer();

pub fn main() !void {
    var jdz = jdz_allocator.JdzAllocator(.{}).init();
    defer jdz.deinit();

    const gpa: Allocator = jdz.allocator();
    const all_args = try std.process.argsAlloc(gpa);
    defer std.process.argsFree(gpa, all_args);
    const args = all_args[1..];

    var read_buffer: [4096]u8 = undefined;

    if (args.len == 0) {
        while (true) {
            const read_result = stdin.readUntilDelimiterOrEof(&read_buffer, '\n');
            if (read_result) |line| {
                const lineStr = line orelse return error.UnexpectedNull;
                try stdout.print("{s}\n", .{lineStr});
                try bw.flush();
            } else |err| {
                return err;
            }
        }
    } else {
        for (args) |arg| {
            const fname = arg;
            const file = try std.fs.cwd().openFile(fname, .{});
            defer file.close();

            const file_info = try file.stat();
            const file_size = file_info.size;

            var file_buffer = try gpa.alloc(u8, file_size);
            defer gpa.free(file_buffer);

            const reader = file.reader();
            const bytes_read = try reader.readAll(&read_buffer);

            try stdout.print("{s}", .{file_buffer[0..bytes_read]});
        }
        try bw.flush();
    }
}
