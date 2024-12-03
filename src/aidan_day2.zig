const std = @import("std");

fn check_rest(numbers: *std.ArrayList(i32), idx: usize, x: i32, increasing: bool, already_ignored: bool) bool {
    var flag = true;
    var last = x;
    for (idx..numbers.items.len) |i| {
        const next = numbers.items[i];
        if (increasing) {
            const diff = next - last;
            if (diff <= 0 or diff > 3) {
                if (already_ignored or !check_rest(numbers, i + 1, last, increasing, true)) {
                    flag = false;
                }
                break;
            }
        } else {
            const diff = last - next;
            if (diff <= 0 or diff > 3) {
                if (already_ignored or !check_rest(numbers, i + 1, last, increasing, true)) {
                    flag = false;
                }
                break;
            }
        }
        last = next;
    }
    return flag;
}

pub fn main(galloc: std.mem.Allocator) !void {
    const file: std.fs.File = try std.fs.cwd().openFile("data/day2.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var buf: [128]u8 = undefined;

    var part1: u32 = 0;
    var part2: u32 = 0;

    var lines: u32 = 0;

    // Read file line by line
    while (try buf_reader.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        lines += 1;

        var line_numbers = std.ArrayList(i32).init(galloc);
        defer line_numbers.deinit();

        // Split by spaces and parse the numbers
        var itr = std.mem.splitSequence(u8, line, " ");
        while (true) {
            const numstr = itr.next() orelse break;
            const num = try std.fmt.parseInt(i32, std.mem.trim(u8, numstr, " \t\r\n"), 10);
            try line_numbers.append(num);
        }
        
        const first = line_numbers.items[0];
        const last = line_numbers.items[1];
        var increasing: bool = false;
        var flag = true;

        if (last > first) {
            increasing = true;
            const diff = last - first;
            if (diff > 3) flag = false;
        } else if (last < first) {
            increasing = false;
            const diff = first - last;
            if (diff > 3) flag = false;
        } else {
            flag = false;
        }

        // --------------------------
        // Part 1
        if (flag and check_rest(&line_numbers, 2, last, increasing, true)) {
            part1 += 1;
            part2 += 1; // Also solves part of Part 2
            continue;
        }
        // --------------------------
        // Part 2
        const skip = line_numbers.items[2];

        if (last == first) {
            // Skip the first. Only check we need to make!
            flag = true;
            if (skip > last) {
                increasing = true;
                const diff = skip - last;
                if (diff > 3) flag = false;
            } else if (skip < last) {
                increasing = false;
                const diff = last - skip;
                if (diff > 3) flag = false;
            } else {
                flag = false;
            }

            if (flag and check_rest(&line_numbers, 3, skip, increasing, true)) {
                part2 += 1;
                continue;
            }

        } else {
            if (flag and check_rest(&line_numbers, 2, last, increasing, false)) {
                part2 += 1;
                continue;
            }

            // The problem may be the third.
            if (flag and check_rest(&line_numbers, 3, last, increasing, true)) {
                part2 += 1;
                continue;
            }

            // Need to also handle where we ignore the second
            flag = true;
            if (skip > first) {
                increasing = true;
                const diff = skip - first;
                if (diff > 3) flag = false;
            } else if (skip < first) {
                increasing = false;
                const diff = first - skip;
                if (diff > 3) flag = false;
            } else {
                flag = false;
            }

            if (flag and check_rest(&line_numbers, 3, skip, increasing, true)) {
                part2 += 1;
                continue;
            }
            
            // Check where we skip the first
            flag = true;
            if (skip > last) {
                increasing = true;
                const diff = skip - last;
                if (diff > 3) flag = false;
            } else if (skip < last) {
                increasing = false;
                const diff = last - skip;
                if (diff > 3) flag = false;
            } else {
                flag = false;
            }

            if (flag and check_rest(&line_numbers, 3, skip, increasing, true)) {
                part2 += 1;
                continue;
            }
        }
        // --------------------------
    }

    std.debug.print("Part 1: {d}\n", .{part1});
    std.debug.print("Part 2: {d}\n", .{part2});
}
