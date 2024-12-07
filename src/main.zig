const std = @import("std");

const day1will = @import("day1will.zig");
const day2will = @import("day2will.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const galloc = gpa.allocator();
    defer {
        const err = gpa.deinit();
        if (err == .leak) std.debug.print("Memory leaks detected: {}\n", .{err});
    }


    day1will.main(galloc) catch |err| {
        std.debug.print("day1 error detected: {}", .{err});
    };
    day2will.main(galloc) catch |err| {
        std.debug.print("day2 error detected: {}", .{err});
    };
}
