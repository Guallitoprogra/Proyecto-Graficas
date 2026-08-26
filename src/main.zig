const fb = @import("framebuffer.zig");
const map = @import("map.zig");
const player_file = @import("player.zig");
const raycaster = @import("raycaster.zig");
const win = @import("window.zig");

pub fn main() !void {
    var framebuffer = fb.Framebuffer.init();
    var window = try win.Window.open("Proyecto Graficas - Ray Caster");
    var player = player_file.Player{};

    while (window.isOpen()) {
        if (win.isKeyDown(0x1B)) break;
        player.update();

        raycaster.render(&framebuffer, player);
        map.drawPreview(&framebuffer, player);

        window.draw(&framebuffer);
        win.waitMilliseconds(16);
    }
}
