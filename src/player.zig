const win = @import("window.zig");
const map = @import("map.zig");

pub const Player = struct {
    x: f32 = 2.5,
    y: f32 = 2.5,
    angle: f32 = 0.0,

    pub fn update(self: *Player) void {
        const move_speed: f32 = 0.045;
        const turn_speed: f32 = 0.035;

        if (win.isKeyDown('A')) self.angle -= turn_speed;
        if (win.isKeyDown('D')) self.angle += turn_speed;

        const forward_x = @cos(self.angle);
        const forward_y = @sin(self.angle);

        if (win.isKeyDown('W')) {
            self.tryMove(forward_x * move_speed, forward_y * move_speed);
        }

        if (win.isKeyDown('S')) {
            self.tryMove(-forward_x * move_speed, -forward_y * move_speed);
        }
    }

    fn tryMove(self: *Player, dx: f32, dy: f32) void {
        const next_x = self.x + dx;
        const next_y = self.y + dy;

        // Se revisa por separado para que el jugador pueda deslizarse contra las paredes.
        if (!map.isWall(@intFromFloat(@floor(next_x)), @intFromFloat(@floor(self.y)))) {
            self.x = next_x;
        }

        if (!map.isWall(@intFromFloat(@floor(self.x)), @intFromFloat(@floor(next_y)))) {
            self.y = next_y;
        }
    }
};
