const std = @import("std");
const day1 = @import("day1.zig");
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const galloc = gpa.allocator();
    defer {
        const err = gpa.deinit();
        if (err == .leak) std.debug.print("Memory leaks detected: {}\n", .{err});
    }

    day1.main(galloc) catch |err| {
        std.debug.print("day1 error detected: {}", .{err});
    };
}
