pub const screen_width = 320;
pub const screen_height = 200;

pub const Color = packed struct(u32) {
    b: u8,
    g: u8,
    r: u8,
    a: u8,
};

pub const colors = struct {
    pub const sky = Color{ .r = 76, .g = 119, .b = 156, .a = 255 };
    pub const floor = Color{ .r = 45, .g = 42, .b = 40, .a = 255 };
    pub const white = Color{ .r = 240, .g = 235, .b = 220, .a = 255 };
    pub const black = Color{ .r = 10, .g = 10, .b = 12, .a = 255 };
};

pub const Framebuffer = struct {
    pixels: [screen_width * screen_height]Color,

    pub fn init() Framebuffer {
        var buffer: Framebuffer = undefined;
        buffer.clear(colors.black);
        return buffer;
    }

    pub fn clear(self: *Framebuffer, color: Color) void {
        for (&self.pixels) |*pixel| {
            pixel.* = color;
        }
    }

    pub fn point(self: *Framebuffer, x: i32, y: i32, color: Color) void {
        if (x < 0 or y < 0) return;
        if (x >= screen_width or y >= screen_height) return;

        const ux: usize = @intCast(x);
        const uy: usize = @intCast(y);
        self.pixels[uy * screen_width + ux] = color;
    }

    pub fn rect(self: *Framebuffer, x: i32, y: i32, w: i32, h: i32, color: Color) void {
        var py: i32 = 0;
        while (py < h) : (py += 1) {
            var px: i32 = 0;
            while (px < w) : (px += 1) {
                self.point(x + px, y + py, color);
            }
        }
    }

    pub fn line(self: *Framebuffer, x0_start: i32, y0_start: i32, x1: i32, y1: i32, color: Color) void {
        var x0 = x0_start;
        var y0 = y0_start;

        const dx: i32 = @intCast(@abs(x1 - x0));
        const dy: i32 = -@as(i32, @intCast(@abs(y1 - y0)));
        const step_x: i32 = if (x0 < x1) 1 else -1;
        const step_y: i32 = if (y0 < y1) 1 else -1;
        var err = dx + dy;

        while (true) {
            self.point(x0, y0, color);
            if (x0 == x1 and y0 == y1) break;

            const err2 = err * 2;
            if (err2 >= dy) {
                err += dy;
                x0 += step_x;
            }
            if (err2 <= dx) {
                err += dx;
                y0 += step_y;
            }
        }
    }

    pub fn drawBackground(self: *Framebuffer) void {
        var y: i32 = 0;
        while (y < screen_height) : (y += 1) {
            const color = if (y < screen_height / 2) colors.sky else colors.floor;
            var x: i32 = 0;
            while (x < screen_width) : (x += 1) {
                self.point(x, y, color);
            }
        }
    }
};
