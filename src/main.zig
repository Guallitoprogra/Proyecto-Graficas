const fb = @import("framebuffer.zig");
const map = @import("map.zig");
const win = @import("window.zig");

pub fn main() !void {
    var framebuffer = fb.Framebuffer.init();
    var window = try win.Window.open("Proyecto Graficas - Ray Caster");

    while (window.isOpen()) {
        framebuffer.drawBackground();
        drawCenterLine(&framebuffer);
        map.drawPreview(&framebuffer);

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
