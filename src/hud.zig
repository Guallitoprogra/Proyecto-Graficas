const fb = @import("framebuffer.zig");

pub fn drawFps(buffer: *fb.Framebuffer, fps: u32) void {
    drawText(buffer, 232, 8, "FPS", fb.colors.white);
    drawNumber(buffer, 258, 8, fps, fb.colors.white);
}

pub fn drawMessage(buffer: *fb.Framebuffer, x: i32, y: i32, text: []const u8, color: fb.Color) void {
    drawText(buffer, x, y, text, color);
}

fn drawText(buffer: *fb.Framebuffer, x: i32, y: i32, text: []const u8, color: fb.Color) void {
    var cursor = x;
    for (text) |letter| {
        if (letter == ' ') {
            cursor += 6;
            continue;
        }
        drawLetter(buffer, cursor, y, letter, color);
        cursor += 6;
    }
}

fn drawNumber(buffer: *fb.Framebuffer, x: i32, y: i32, value: u32, color: fb.Color) void {
    var digits: [10]u8 = undefined;
    var count: usize = 0;
    var temp = value;

    if (temp == 0) {
        digits[0] = 0;
        count = 1;
    } else {
        while (temp > 0) : (temp /= 10) {
            digits[count] = @intCast(temp % 10);
            count += 1;
        }
    }

    var cursor = x;
    while (count > 0) {
        count -= 1;
        drawDigit(buffer, cursor, y, digits[count], color);
        cursor += 6;
    }
}

fn drawLetter(buffer: *fb.Framebuffer, x: i32, y: i32, letter: u8, color: fb.Color) void {
    const pattern = switch (letter) {
        'A' => [_]u8{ 0b010, 0b101, 0b111, 0b101, 0b101 },
        'C' => [_]u8{ 0b111, 0b100, 0b100, 0b100, 0b111 },
        'D' => [_]u8{ 0b110, 0b101, 0b101, 0b101, 0b110 },
        'E' => [_]u8{ 0b111, 0b100, 0b110, 0b100, 0b111 },
        'F' => [_]u8{ 0b111, 0b100, 0b110, 0b100, 0b100 },
        'G' => [_]u8{ 0b111, 0b100, 0b101, 0b101, 0b111 },
        'I' => [_]u8{ 0b111, 0b010, 0b010, 0b010, 0b111 },
        'J' => [_]u8{ 0b001, 0b001, 0b001, 0b101, 0b111 },
        'L' => [_]u8{ 0b100, 0b100, 0b100, 0b100, 0b111 },
        'M' => [_]u8{ 0b101, 0b111, 0b111, 0b101, 0b101 },
        'N' => [_]u8{ 0b101, 0b111, 0b111, 0b111, 0b101 },
        'O' => [_]u8{ 0b111, 0b101, 0b101, 0b101, 0b111 },
        'P' => [_]u8{ 0b110, 0b101, 0b110, 0b100, 0b100 },
        'R' => [_]u8{ 0b110, 0b101, 0b110, 0b101, 0b101 },
        'S' => [_]u8{ 0b111, 0b100, 0b111, 0b001, 0b111 },
        'T' => [_]u8{ 0b111, 0b010, 0b010, 0b010, 0b010 },
        'V' => [_]u8{ 0b101, 0b101, 0b101, 0b101, 0b010 },
        'Y' => [_]u8{ 0b101, 0b101, 0b010, 0b010, 0b010 },
        else => [_]u8{ 0, 0, 0, 0, 0 },
    };
    drawPattern(buffer, x, y, &pattern, color);
}

fn drawDigit(buffer: *fb.Framebuffer, x: i32, y: i32, digit: u8, color: fb.Color) void {
    const pattern = switch (digit) {
        0 => [_]u8{ 0b111, 0b101, 0b101, 0b101, 0b111 },
        1 => [_]u8{ 0b010, 0b110, 0b010, 0b010, 0b111 },
        2 => [_]u8{ 0b111, 0b001, 0b111, 0b100, 0b111 },
        3 => [_]u8{ 0b111, 0b001, 0b111, 0b001, 0b111 },
        4 => [_]u8{ 0b101, 0b101, 0b111, 0b001, 0b001 },
        5 => [_]u8{ 0b111, 0b100, 0b111, 0b001, 0b111 },
        6 => [_]u8{ 0b111, 0b100, 0b111, 0b101, 0b111 },
        7 => [_]u8{ 0b111, 0b001, 0b001, 0b010, 0b010 },
        8 => [_]u8{ 0b111, 0b101, 0b111, 0b101, 0b111 },
        9 => [_]u8{ 0b111, 0b101, 0b111, 0b001, 0b111 },
        else => [_]u8{ 0, 0, 0, 0, 0 },
    };
    drawPattern(buffer, x, y, &pattern, color);
}

fn drawPattern(buffer: *fb.Framebuffer, x: i32, y: i32, pattern: []const u8, color: fb.Color) void {
    for (pattern, 0..) |row, py| {
        var px: i32 = 0;
        while (px < 3) : (px += 1) {
            const mask: u8 = @as(u8, 1) << @intCast(2 - px);
            if ((row & mask) != 0) {
                buffer.rect(x + px * 2, y + @as(i32, @intCast(py)) * 2, 2, 2, color);
            }
        }
    }
}
