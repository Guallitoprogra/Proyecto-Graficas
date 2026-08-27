const fb = @import("framebuffer.zig");
const hud = @import("hud.zig");
const map = @import("map.zig");
const player_file = @import("player.zig");
const raycaster = @import("raycaster.zig");
const sprite = @import("sprite.zig");
const win = @import("window.zig");

const Mode = enum {
    welcome,
    playing,
    success,
};

pub fn main() !void {
    var framebuffer = fb.Framebuffer.init();
    var window = try win.Window.open("Proyecto Graficas - Ray Caster");
    var player = player_file.Player{};
    var level_index: usize = 0;
    var last_second = win.nowMilliseconds();
    var frames_this_second: u32 = 0;
    var fps: u32 = 0;
    var mode = Mode.welcome;

    while (window.isOpen()) {
        if (win.isKeyDown(0x1B)) break;
        const now = win.nowMilliseconds();

        if (mode == .welcome) {
            drawWelcome(&framebuffer);
            window.draw(&framebuffer);
            if (win.isKeyDown(0x0D)) mode = .playing;
            win.waitMilliseconds(16);
            continue;
        }

        if (mode == .success) {
            drawSuccess(&framebuffer);
            window.draw(&framebuffer);
            if (win.isKeyDown(0x0D)) {
                mode = .playing;
                player.setLevelStart(level_index);
            }
            win.waitMilliseconds(16);
            continue;
        }

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
        sprite.draw(&framebuffer, player, @intCast(frames_this_second));
        map.drawMinimap(&framebuffer, level_index, player);
        hud.drawFps(&framebuffer, fps);

        window.draw(&framebuffer);
        frames_this_second += 1;

        if (map.isAtExit(level_index, player.x, player.y)) {
            mode = .success;
        }

        if (now - last_second >= 1000) {
            fps = frames_this_second;
            frames_this_second = 0;
            last_second = now;
        }

        win.waitMilliseconds(16);
    }
}

fn drawWelcome(framebuffer: *fb.Framebuffer) void {
    framebuffer.clear(.{ .r = 16, .g = 18, .b = 28, .a = 255 });
    framebuffer.rect(38, 44, 244, 100, .{ .r = 34, .g = 42, .b = 58, .a = 255 });
    hud.drawMessage(framebuffer, 78, 70, "RAY CASTER", fb.colors.white);
    hud.drawMessage(framebuffer, 58, 104, "ENTER PARA JUGAR", .{ .r = 245, .g = 218, .b = 110, .a = 255 });
}

fn drawSuccess(framebuffer: *fb.Framebuffer) void {
    framebuffer.clear(.{ .r = 14, .g = 50, .b = 42, .a = 255 });
    framebuffer.rect(44, 54, 232, 88, .{ .r = 30, .g = 88, .b = 72, .a = 255 });
    hud.drawMessage(framebuffer, 78, 78, "NIVEL LISTO", fb.colors.white);
    hud.drawMessage(framebuffer, 60, 112, "ENTER REINICIA", .{ .r = 245, .g = 218, .b = 110, .a = 255 });
}
