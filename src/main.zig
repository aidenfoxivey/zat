// Copyright (C) 2024 Aiden Fox Ivey

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

const std = @import("std");

pub fn main() !void {
    var fifo = std.fifo.LinearFifo(u8, .{ .Static = std.mem.page_size * 4 }).init();
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
