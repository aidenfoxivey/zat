const std = @import("std");

pub fn main() !void {
    var allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = allocator.allocator();

    var fifo = std.fifo.LinearFifo(u8, .Dynamic).init(gpa);
    defer fifo.deinit();
    try fifo.ensureTotalCapacity(std.mem.page_size * 4);
    const stdout_file = std.io.getStdOut().writer();

    var args = std.process.ArgIterator.init();
    _ = args.skip();
    while (args.next()) |arg| {
        const file = if (arg.len == 1 and arg[0] == '-')
            std.io.getStdIn()
        else
            try std.fs.cwd().openFile(arg, .{});
        try fifo.pump(file.reader(), stdout_file);
    }
}
