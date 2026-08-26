const fb = @import("framebuffer.zig");
const player_file = @import("player.zig");

pub const width = 16;
pub const height = 12;

// 0 es espacio libre. Los otros numeros son paredes con colores distintos.
pub const tiles = [height][width]u8{
    .{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
    .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 1 },
    .{ 1, 0, 2, 2, 0, 0, 3, 0, 0, 4, 4, 4, 0, 0, 0, 1 },
    .{ 1, 0, 2, 0, 0, 0, 3, 0, 0, 0, 0, 4, 0, 5, 0, 1 },
    .{ 1, 0, 0, 0, 3, 3, 3, 0, 5, 5, 0, 0, 0, 5, 0, 1 },
    .{ 1, 0, 4, 0, 0, 0, 0, 0, 5, 0, 0, 3, 0, 0, 0, 1 },
    .{ 1, 0, 4, 4, 4, 0, 2, 0, 0, 0, 0, 3, 3, 3, 0, 1 },
    .{ 1, 0, 0, 0, 0, 0, 2, 0, 4, 4, 0, 0, 0, 0, 0, 1 },
    .{ 1, 0, 5, 5, 0, 0, 2, 0, 0, 4, 0, 2, 2, 0, 0, 1 },
    .{ 1, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 1 },
    .{ 1, 3, 0, 0, 0, 4, 4, 0, 0, 5, 5, 0, 0, 0, 0, 1 },
    .{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
};

pub fn wallColor(tile: u8) fb.Color {
    return switch (tile) {
        1 => .{ .r = 180, .g = 68, .b = 68, .a = 255 },
        2 => .{ .r = 70, .g = 138, .b = 201, .a = 255 },
        3 => .{ .r = 86, .g = 166, .b = 101, .a = 255 },
        4 => .{ .r = 214, .g = 170, .b = 72, .a = 255 },
        5 => .{ .r = 139, .g = 96, .b = 190, .a = 255 },
        else => fb.colors.floor,
    };
}

pub fn isWall(x: i32, y: i32) bool {
    if (x < 0 or y < 0) return true;
    if (x >= width or y >= height) return true;

    return tiles[@intCast(y)][@intCast(x)] != 0;
}

pub fn drawPreview(buffer: *fb.Framebuffer, player: player_file.Player) void {
    const cell = 12;
    const start_x = 18;
    const start_y = 22;

    var y: i32 = 0;
    while (y < height) : (y += 1) {
        var x: i32 = 0;
        while (x < width) : (x += 1) {
            const tile = tiles[@intCast(y)][@intCast(x)];
            const color = if (tile == 0) fb.colors.floor else wallColor(tile);
            buffer.rect(start_x + x * cell, start_y + y * cell, cell - 1, cell - 1, color);
        }
    }

    const px: i32 = start_x + @as(i32, @intFromFloat(player.x * cell));
    const py: i32 = start_y + @as(i32, @intFromFloat(player.y * cell));
    buffer.rect(px - 2, py - 2, 5, 5, fb.colors.white);
    buffer.line(
        px,
        py,
        px + @as(i32, @intFromFloat(@cos(player.angle) * 14.0)),
        py + @as(i32, @intFromFloat(@sin(player.angle) * 14.0)),
        fb.colors.white,
    );
}
