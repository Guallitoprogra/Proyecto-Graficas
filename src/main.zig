const fb = @import("framebuffer.zig");
const map = @import("map.zig");
const player_file = @import("player.zig");
const win = @import("window.zig");

pub fn main() !void {
    var framebuffer = fb.Framebuffer.init();
    var window = try win.Window.open("Proyecto Graficas - Ray Caster");
    var player = player_file.Player{};

    while (window.isOpen()) {
        if (win.isKeyDown(0x1B)) break;
        player.update();

        framebuffer.drawBackground();
        drawCenterLine(&framebuffer);
        map.drawPreview(&framebuffer, player);

        window.draw(&framebuffer);
        win.waitMilliseconds(16);
    }
}

fn drawCenterLine(framebuffer: *fb.Framebuffer) void {
    var x: i32 = 0;
    while (x < fb.screen_width) : (x += 1) {
        framebuffer.point(x, fb.screen_height / 2, fb.colors.white);
    }
}
