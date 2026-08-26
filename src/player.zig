const win = @import("window.zig");

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
            self.x += forward_x * move_speed;
            self.y += forward_y * move_speed;
        }

        if (win.isKeyDown('S')) {
            self.x -= forward_x * move_speed;
            self.y -= forward_y * move_speed;
        }
    }
};
