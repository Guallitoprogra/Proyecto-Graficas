from PIL import Image, ImageDraw
import math

WIDTH = 320
HEIGHT = 200
SCALE = 2

SKY = (76, 119, 156)
FLOOR = (45, 42, 40)
WHITE = (240, 235, 220)

LEVEL = [
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 1],
    [1, 0, 2, 2, 0, 0, 3, 0, 0, 4, 4, 4, 0, 0, 0, 1],
    [1, 0, 2, 0, 0, 0, 3, 0, 0, 0, 0, 4, 0, 5, 0, 1],
    [1, 0, 0, 0, 3, 3, 3, 0, 5, 5, 0, 0, 0, 5, 0, 1],
    [1, 0, 4, 0, 0, 0, 0, 0, 5, 0, 0, 3, 0, 0, 0, 1],
    [1, 0, 4, 4, 4, 0, 2, 0, 0, 0, 0, 3, 3, 3, 0, 1],
    [1, 0, 0, 0, 0, 0, 2, 0, 4, 4, 0, 0, 0, 0, 0, 1],
    [1, 0, 5, 5, 0, 0, 2, 0, 0, 4, 0, 2, 2, 0, 0, 1],
    [1, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 1],
    [1, 3, 0, 0, 0, 4, 4, 0, 0, 5, 5, 0, 0, 0, 0, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
]

COLORS = {
    1: (180, 68, 68),
    2: (70, 138, 201),
    3: (86, 166, 101),
    4: (214, 170, 72),
    5: (139, 96, 190),
}


def tile_at(x, y):
    if x < 0 or y < 0 or y >= len(LEVEL) or x >= len(LEVEL[0]):
        return 1
    return LEVEL[y][x]


def cast_ray(px, py, angle):
    dx = math.cos(angle)
    dy = math.sin(angle)
    distance = 0.05
    while distance < 20:
        tx = int(math.floor(px + dx * distance))
        ty = int(math.floor(py + dy * distance))
        tile = tile_at(tx, ty)
        if tile:
            return distance, tile
        distance += 0.02
    return 20, 1


def render_frame(px, py, angle, frame):
    img = Image.new("RGB", (WIDTH, HEIGHT), SKY)
    draw = ImageDraw.Draw(img)
    draw.rectangle((0, HEIGHT // 2, WIDTH, HEIGHT), fill=FLOOR)

    fov = math.radians(60)
    for column in range(WIDTH):
        percent = column / WIDTH
        ray_angle = angle - fov / 2 + percent * fov
        distance, tile = cast_ray(px, py, ray_angle)
        corrected = distance * math.cos(ray_angle - angle)
        wall_height = int(HEIGHT / max(corrected, 0.1))
        top = (HEIGHT - wall_height) // 2
        bottom = top + wall_height
        light = max(0.25, 1 - distance * 0.08)
        color = tuple(int(c * light) for c in COLORS[tile])
        draw.line((column, top, column, bottom), fill=color)

    sprite_size = 18 + int(math.sin(frame * 0.3) * 3)
    draw.rectangle((150, 92 - sprite_size, 170, 92 + sprite_size), fill=(245, 220, 90))

    cell = 5
    sx, sy = 8, 8
    draw.rectangle((sx - 3, sy - 3, sx + 16 * cell + 3, sy + 12 * cell + 3), fill=(10, 10, 12))
    for y, row in enumerate(LEVEL):
        for x, tile in enumerate(row):
            fill = COLORS.get(tile, FLOOR)
            draw.rectangle((sx + x * cell, sy + y * cell, sx + x * cell + cell - 2, sy + y * cell + cell - 2), fill=fill)
    draw.ellipse((sx + px * cell - 2, sy + py * cell - 2, sx + px * cell + 2, sy + py * cell + 2), fill=WHITE)
    draw.text((232, 8), "FPS 60", fill=WHITE)
    return img.resize((WIDTH * SCALE, HEIGHT * SCALE), Image.Resampling.NEAREST)


def main():
    frames = []
    px, py = 2.5, 2.5
    angle = 0.0
    for frame in range(80):
        frames.append(render_frame(px, py, angle, frame))
        angle += 0.025
        px += math.cos(angle) * 0.025
        py += math.sin(angle) * 0.015

    frames[0].save("demo.gif", save_all=True, append_images=frames[1:], duration=70, loop=0)


if __name__ == "__main__":
    main()
