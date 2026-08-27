const fb = @import("framebuffer.zig");
const map = @import("map.zig");
const player_file = @import("player.zig");

const fov: f32 = 1.0471976; // 60 grados.

pub fn render(buffer: *fb.Framebuffer, level_index: usize, player: player_file.Player) void {
    // Por cada columna de la pantalla se lanza un rayo y se dibuja una pared vertical.
    buffer.drawBackground();

    var column: i32 = 0;
    while (column < fb.screen_width) : (column += 1) {
        const percent = @as(f32, @floatFromInt(column)) / @as(f32, @floatFromInt(fb.screen_width));
        const ray_angle = player.angle - fov / 2.0 + percent * fov;

        const hit = castRay(level_index, player.x, player.y, ray_angle);
        const corrected = hit.distance * @cos(ray_angle - player.angle);
        const wall_height = @as(i32, @intFromFloat(@as(f32, @floatFromInt(fb.screen_height)) / corrected));

        const top = @divTrunc(fb.screen_height - wall_height, 2);
        const bottom = top + wall_height;
        const color = shade(map.wallColor(hit.tile), hit.distance);

        drawWallColumn(buffer, column, top, bottom, color);
    }
}

fn castRay(level_index: usize, start_x: f32, start_y: f32, angle: f32) RayHit {
    // El rayo avanza poco a poco hasta tocar una celda que sea pared.
    const ray_dx = @cos(angle);
    const ray_dy = @sin(angle);

    var distance: f32 = 0.05;
    while (distance < 20.0) : (distance += 0.02) {
        const test_x = start_x + ray_dx * distance;
        const test_y = start_y + ray_dy * distance;

        const tile_x: i32 = @intFromFloat(@floor(test_x));
        const tile_y: i32 = @intFromFloat(@floor(test_y));
        const tile = map.tileAt(level_index, tile_x, tile_y);

        if (tile != 0) {
            return .{
                .distance = distance,
                .tile = tile,
            };
        }
    }

    return .{
        .distance = 20.0,
        .tile = 1,
    };
}

fn drawWallColumn(buffer: *fb.Framebuffer, x: i32, top: i32, bottom: i32, color: fb.Color) void {
    var y = top;
    while (y <= bottom) : (y += 1) {
        buffer.point(x, y, color);
    }
}

fn shade(color: fb.Color, distance: f32) fb.Color {
    // Mientras mas lejos esta una pared, mas oscura se pinta para dar profundidad.
    const light = @max(0.25, 1.0 - distance * 0.08);

    return .{
        .r = @intFromFloat(@as(f32, @floatFromInt(color.r)) * light),
        .g = @intFromFloat(@as(f32, @floatFromInt(color.g)) * light),
        .b = @intFromFloat(@as(f32, @floatFromInt(color.b)) * light),
        .a = 255,
    };
}

const RayHit = struct {
    distance: f32,
    tile: u8,
};
