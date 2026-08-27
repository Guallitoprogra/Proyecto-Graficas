const fb = @import("framebuffer.zig");
const player_file = @import("player.zig");

pub const width = 16;
pub const height = 12;

// 0 es espacio libre. Los otros numeros son paredes con colores distintos.
const level1 = [height][width]u8{
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

const level2 = [height][width]u8{
    .{ 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 },
    .{ 2, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 5, 0, 0, 2 },
    .{ 2, 0, 3, 3, 3, 0, 4, 0, 1, 1, 1, 0, 5, 0, 0, 2 },
    .{ 2, 0, 3, 0, 0, 0, 4, 0, 1, 0, 0, 0, 5, 5, 0, 2 },
    .{ 2, 0, 0, 0, 5, 5, 0, 0, 0, 0, 4, 0, 0, 0, 0, 2 },
    .{ 2, 4, 4, 0, 5, 0, 0, 3, 3, 0, 4, 0, 1, 1, 0, 2 },
    .{ 2, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 1, 0, 0, 2 },
    .{ 2, 0, 1, 1, 1, 0, 4, 4, 4, 0, 5, 0, 0, 0, 3, 2 },
    .{ 2, 0, 0, 0, 1, 0, 0, 0, 4, 0, 5, 5, 5, 0, 3, 2 },
    .{ 2, 0, 5, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 2 },
    .{ 2, 0, 5, 5, 5, 0, 3, 3, 3, 0, 1, 1, 1, 0, 0, 2 },
    .{ 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 },
};

pub const Level = struct {
    tiles: [height][width]u8,
    start_x: f32,
    start_y: f32,
    start_angle: f32,
};

pub const levels = [_]Level{
    .{ .tiles = level1, .start_x = 1.5, .start_y = 1.5, .start_angle = 0.0 },
    .{ .tiles = level2, .start_x = 13.5, .start_y = 9.5, .start_angle = 3.14 },
};

pub fn wallColor(tile: u8) fb.Color {
    // Cada numero del mapa se traduce a un color diferente de pared.
    return switch (tile) {
        1 => .{ .r = 180, .g = 68, .b = 68, .a = 255 },
        2 => .{ .r = 70, .g = 138, .b = 201, .a = 255 },
        3 => .{ .r = 86, .g = 166, .b = 101, .a = 255 },
        4 => .{ .r = 214, .g = 170, .b = 72, .a = 255 },
        5 => .{ .r = 139, .g = 96, .b = 190, .a = 255 },
        else => fb.colors.floor,
    };
}

pub fn exitTile(level_index: usize) [2]i32 {
    return if (level_index == 0) .{ 14, 10 } else .{ 1, 1 };
}

pub fn isAtExit(level_index: usize, x: f32, y: f32) bool {
    const exit = exitTile(level_index);
    return @as(i32, @intFromFloat(@floor(x))) == exit[0] and @as(i32, @intFromFloat(@floor(y))) == exit[1];
}

pub fn isWall(level_index: usize, x: i32, y: i32) bool {
    // Todo lo que este fuera del mapa se trata como pared para no salirse del nivel.
    if (x < 0 or y < 0) return true;
    if (x >= width or y >= height) return true;

    return levels[level_index].tiles[@intCast(y)][@intCast(x)] != 0;
}

pub fn tileAt(level_index: usize, x: i32, y: i32) u8 {
    if (x < 0 or y < 0) return 1;
    if (x >= width or y >= height) return 1;

    return levels[level_index].tiles[@intCast(y)][@intCast(x)];
}

pub fn drawMinimap(buffer: *fb.Framebuffer, level_index: usize, player: player_file.Player) void {
    // El minimapa ayuda a ver donde esta el jugador dentro del mundo 2D.
    const cell = 5;
    const start_x = 8;
    const start_y = 8;

    buffer.rect(start_x - 3, start_y - 3, width * cell + 6, height * cell + 6, fb.colors.black);

    var y: i32 = 0;
    while (y < height) : (y += 1) {
        var x: i32 = 0;
        while (x < width) : (x += 1) {
            const tile = levels[level_index].tiles[@intCast(y)][@intCast(x)];
            const color = if (tile == 0) fb.colors.floor else wallColor(tile);
            buffer.rect(start_x + x * cell, start_y + y * cell, cell - 1, cell - 1, color);
        }
    }

    const exit = exitTile(level_index);
    buffer.rect(start_x + exit[0] * cell + 1, start_y + exit[1] * cell + 1, cell - 2, cell - 2, .{ .r = 90, .g = 245, .b = 180, .a = 255 });

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
