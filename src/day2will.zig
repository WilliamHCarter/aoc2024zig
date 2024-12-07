const std = @import("std");

pub fn main(galloc: std.mem.Allocator) !void {
    var arena = std.heap.ArenaAllocator.init(galloc);
    defer arena.deinit();
    const input: [][]i32 = try readInput(arena.allocator());

    std.debug.print("Part One Total Count: {d}\n", .{solveProblem(0, input)});
    std.debug.print("Part Two Total Count: {d}\n", .{solveProblem(1, input)});
}

pub fn solveProblem(dampener: i32, input: [][]i32) i32 {
    var safe_count: i32 = @intCast(input.len);
    for (input) |row| {
        var viols: i32 = 0; //violations of the safety measure
        for (1..row.len - 1) |i| {
            const big_gap: bool = (@abs(row[i] - row[i - 1]) > 3);
            const change_slope: bool = !((row[i - 1] > row[i] and row[i] > row[i + 1]) or (row[i - 1] < row[i] and row[i] < row[i + 1]));
            viols += @intFromBool(big_gap or change_slope);
        }
        viols += @intFromBool(@abs(row[row.len - 1] - row[row.len - 2]) > 3);
        safe_count -= @intFromBool(viols > dampener);
    }
    return safe_count;
}

pub fn readInput(arena: std.mem.Allocator) ![][]i32 {
    const file: std.fs.File = try std.fs.cwd().openFile("src/day2input.txt", .{});
    defer file.close();

    var reports = std.ArrayList([]i32).init(arena);
    var buf_reader = std.io.bufferedReader(file.reader());
    var reader = buf_reader.reader();
    var buf: [4096]u8 = undefined;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var levels = std.ArrayList(i32).init(arena);

        var iterator = std.mem.split(u8, line, " ");
        while (iterator.next()) |itr| {
            const num = try std.fmt.parseInt(i32, std.mem.trim(u8, itr, " \t\r\n"), 10);
            try levels.append(num);
        }
        try reports.append(try levels.toOwnedSlice());
    }

    const final = try reports.toOwnedSlice();
    return final;
}
