const fb = @import("framebuffer.zig");
const hud = @import("hud.zig");
const map = @import("map.zig");
const player_file = @import("player.zig");
const raycaster = @import("raycaster.zig");
const win = @import("window.zig");

pub fn main() !void {
    var framebuffer = fb.Framebuffer.init();
    var window = try win.Window.open("Proyecto Graficas - Ray Caster");
    var player = player_file.Player{};
    var level_index: usize = 0;
    var last_second = win.nowMilliseconds();
    var frames_this_second: u32 = 0;
    var fps: u32 = 0;

    while (window.isOpen()) {
        if (win.isKeyDown(0x1B)) break;
        if (win.isKeyDown('1')) {
            level_index = 0;
            player.setLevelStart(level_index);
        }
        if (win.isKeyDown('2')) {
            level_index = 1;
            player.setLevelStart(level_index);
        }

        player.update(level_index);

        raycaster.render(&framebuffer, level_index, player);
        map.drawMinimap(&framebuffer, level_index, player);
        hud.drawFps(&framebuffer, fps);

        window.draw(&framebuffer);
        frames_this_second += 1;

        const now = win.nowMilliseconds();
        if (now - last_second >= 1000) {
            fps = frames_this_second;
            frames_this_second = 0;
            last_second = now;
        }

        win.waitMilliseconds(16);
    }
}
