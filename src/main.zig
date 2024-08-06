const std = @import("std");

var allocator = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = allocator.allocator();
var read_buffer: [16384]u8 = undefined;
const stdin = std.io.getStdIn().reader();
var buffer: [256]u8 = undefined; // Define a buffer to hold the input
const stdout_file = std.io.getStdOut().writer();
var bw = std.io.bufferedWriter(stdout_file);
const stdout = bw.writer();

pub fn main() !void {
    const all_args = try std.process.argsAlloc(gpa);
    defer std.process.argsFree(gpa, all_args);
    const args = all_args[1..];

    if (args.len == 0) {
        while (true) {
            const read_result = stdin.readUntilDelimiterOrEof(&buffer, '\n');
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

            const reader = file.reader();
            while (true) {
                const bytes_read = try reader.read(&read_buffer);
                if (bytes_read == 0) break;
                try stdout.print("{s}", .{read_buffer[0..bytes_read]});
            }
        }
        try bw.flush();
    }
}
