const std = @import("std");

pub fn main(galloc: std.mem.Allocator) !void {
    const input: [2][]u32 = try readInput(galloc);
    defer {
        galloc.free(input[0]);
        galloc.free(input[1]);
    }
    //Part one
    std.sort.heap(u32, input[0], {}, std.sort.asc(u32));
    std.sort.heap(u32, input[1], {}, std.sort.asc(u32));

    var sum: u32 = 0;
    for (input[0], input[1]) |itr1, itr2| {
        sum += @max(itr1, itr2) - @min(itr1, itr2);
    }
    std.debug.print("part one sum: {d}\n", .{sum});

    //Part two
    var dest_map = std.AutoHashMap(u32, u32).init(galloc);
    defer {
        dest_map.deinit();
    }
    for (input[1]) |itr| {
        const res = try dest_map.getOrPut(itr);
        if (!res.found_existing) {
            res.value_ptr.* = 0;
        }
        res.value_ptr.* += 1;
    }

    sum = 0;
    for (input[0]) |itr| {
        const res = dest_map.get(itr) orelse 0;
        sum += itr * res;
    }
    std.debug.print("part two sum: {d}\n", .{sum});
}

pub fn readInput(galloc: std.mem.Allocator) ![2][]u32 {
    var arena = std.heap.ArenaAllocator.init(galloc);
    defer arena.deinit();

    const file: std.fs.File = try std.fs.cwd().openFile("src/day1input.txt", .{});
    defer file.close();

    var first_numbers = std.ArrayList(u32).init(arena.allocator());
    var second_numbers = std.ArrayList(u32).init(arena.allocator());

    // Create buffered reader
    var buf_reader = std.io.bufferedReader(file.reader());
    var reader = buf_reader.reader();
    var buf: [1024]u8 = undefined;

    // Read file line by line
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        // Split the line by whitespace
        var iterator = std.mem.split(u8, line, "   ");
        // Parse first number
        const first = iterator.next() orelse continue;

        const num1 = try std.fmt.parseInt(u32, std.mem.trim(u8, first, " \t\r\n"), 10);
        try first_numbers.append(num1);

        // Parse second number
        const second = iterator.next() orelse continue;
        const num2 = try std.fmt.parseInt(u32, std.mem.trim(u8, second, " \t\r\n"), 10);
        try second_numbers.append(num2);
    }

    const first_slice = try first_numbers.toOwnedSlice();
    const second_slice = try second_numbers.toOwnedSlice();

    return [2][]u32{
        try galloc.dupe(u32, first_slice),
        try galloc.dupe(u32, second_slice),
    };
}
