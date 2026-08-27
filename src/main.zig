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
    // Estos son los objetos principales del juego: pantalla, ventana, jugador y estado.
    var framebuffer = fb.Framebuffer.init();
    var window = try win.Window.open("Proyecto Graficas - Ray Caster");
    var player = player_file.Player{};
    var level_index: usize = 0;
    var last_second = win.nowMilliseconds();
    var frames_this_second: u32 = 0;
    var fps: u32 = 0;
    var mode = Mode.welcome;
    var level_start_time = win.nowMilliseconds();
    var last_finish_seconds: u32 = 0;

    while (window.isOpen()) {
        if (win.isKeyDown(0x1B)) break;
        const now = win.nowMilliseconds();

        // La pantalla de inicio espera Enter antes de empezar el nivel.
        if (mode == .welcome) {
            drawWelcome(&framebuffer);
            window.draw(&framebuffer);
            if (win.isKeyDown(0x0D)) {
                player.setLevelStart(level_index);
                level_start_time = win.nowMilliseconds();
                mode = .playing;
            }
            win.waitMilliseconds(16);
            continue;
        }

        // Cuando se gana, se muestra el tiempo y Enter manda al siguiente nivel.
        if (mode == .success) {
            drawSuccess(&framebuffer, last_finish_seconds);
            window.draw(&framebuffer);
            if (win.isKeyDown(0x0D)) {
                level_index = (level_index + 1) % map.levels.len;
                mode = .playing;
                player.setLevelStart(level_index);
                level_start_time = win.nowMilliseconds();
            }
            win.waitMilliseconds(16);
            continue;
        }

        // Las teclas 1 y 2 cambian de nivel sin tener que recompilar el programa.
        if (win.isKeyDown('1')) {
            level_index = 0;
            player.setLevelStart(level_index);
            level_start_time = now;
        }
        if (win.isKeyDown('2')) {
            level_index = 1;
            player.setLevelStart(level_index);
            level_start_time = now;
        }

        player.update(level_index);

        // Este es el render normal del juego: mundo 3D, sprite, minimapa y FPS.
        raycaster.render(&framebuffer, level_index, player);
        sprite.draw(&framebuffer, player, @intCast(frames_this_second));
        map.drawMinimap(&framebuffer, level_index, player);
        hud.drawFps(&framebuffer, fps);

        window.draw(&framebuffer);
        frames_this_second += 1;

        // La salida del nivel se revisa usando la posicion actual del jugador.
        if (map.isAtExit(level_index, player.x, player.y)) {
            last_finish_seconds = @intCast((now - level_start_time) / 1000);
            mode = .success;
        }

        // Contador simple de FPS: cuenta frames durante un segundo completo.
        if (now - last_second >= 1000) {
            fps = frames_this_second;
            frames_this_second = 0;
            last_second = now;
        }

        win.waitMilliseconds(16);
    }
}

fn drawWelcome(framebuffer: *fb.Framebuffer) void {
    // Esta pantalla es solo UI dibujada con rectangulos y texto de pixeles.
    framebuffer.clear(.{ .r = 12, .g = 18, .b = 31, .a = 255 });
    framebuffer.rect(0, 118, fb.screen_width, 82, .{ .r = 42, .g = 38, .b = 35, .a = 255 });
    framebuffer.rect(24, 32, 272, 118, .{ .r = 30, .g = 39, .b = 58, .a = 255 });
    framebuffer.rect(28, 36, 264, 110, .{ .r = 50, .g = 65, .b = 91, .a = 255 });

    hud.drawBigMessage(framebuffer, 68, 56, "RAYCASTER", fb.colors.white);
    hud.drawMessage(framebuffer, 74, 102, "ENTER PARA JUGAR", .{ .r = 245, .g = 218, .b = 110, .a = 255 });
    hud.drawMessage(framebuffer, 74, 124, "WASD MOVER  1 2 NIVEL", fb.colors.white);
}

fn drawSuccess(framebuffer: *fb.Framebuffer, seconds: u32) void {
    // Al ganar se muestra el tiempo para que se vea una condicion de exito clara.
    framebuffer.clear(.{ .r = 12, .g = 49, .b = 43, .a = 255 });
    framebuffer.rect(30, 38, 260, 124, .{ .r = 25, .g = 92, .b = 77, .a = 255 });
    framebuffer.rect(36, 44, 248, 112, .{ .r = 40, .g = 126, .b = 99, .a = 255 });

    hud.drawBigMessage(framebuffer, 54, 62, "FELICIDADES", fb.colors.white);
    hud.drawMessage(framebuffer, 82, 106, "TIEMPO:", .{ .r = 245, .g = 218, .b = 110, .a = 255 });
    hud.drawSmallNumber(framebuffer, 138, 106, seconds, .{ .r = 245, .g = 218, .b = 110, .a = 255 });
    hud.drawMessage(framebuffer, 170, 106, "SEG", .{ .r = 245, .g = 218, .b = 110, .a = 255 });
    hud.drawMessage(framebuffer, 58, 132, "ENTER SIGUIENTE NIVEL", fb.colors.white);
}
