const std = @import("std");
const fb = @import("framebuffer.zig");
const player_file = @import("player.zig");

pub fn draw(buffer: *fb.Framebuffer, player: player_file.Player, frame: u32) void {
    // El sprite vive en una posicion fija del mundo. Si el jugador lo mira de frente, aparece en pantalla.
    const sprite_x: f32 = 8.5;
    const sprite_y: f32 = 5.5;
    const dx = sprite_x - player.x;
    const dy = sprite_y - player.y;
    const distance = @sqrt(dx * dx + dy * dy);
    const angle_to_sprite = std.math.atan2(dy, dx);
    const diff = normalizeAngle(angle_to_sprite - player.angle);

    if (@abs(diff) > 0.45 or distance < 0.3) return;

    const center_x = fb.screen_width / 2 + @as(i32, @intFromFloat(diff * 210.0));
    const size = @as(i32, @intFromFloat(42.0 / distance));
    const top = fb.screen_height / 2 - @divTrunc(size, 2) + @as(i32, @intFromFloat(@sin(@as(f32, @floatFromInt(frame)) * 0.12) * 4.0));
    const color = if ((frame / 12) % 2 == 0)
        fb.Color{ .r = 245, .g = 240, .b = 120, .a = 255 }
    else
        fb.Color{ .r = 240, .g = 125, .b = 90, .a = 255 };

    buffer.rect(center_x - @divTrunc(size, 4), top, @divTrunc(size, 2), size, color);
    buffer.rect(center_x - @divTrunc(size, 8), top - @divTrunc(size, 4), @divTrunc(size, 4), @divTrunc(size, 4), fb.colors.white);
}

fn normalizeAngle(angle_start: f32) f32 {
    var angle = angle_start;
    while (angle > 3.14159) : (angle -= 6.28318) {}
    while (angle < -3.14159) : (angle += 6.28318) {}
    return angle;
}
