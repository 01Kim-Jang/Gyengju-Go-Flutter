from PIL import Image

input_path = 'assets/images/character.png'
output_path = 'assets/images/character.png'

try:
    img = Image.open(input_path).convert("RGBA")
    pixels = img.load()
    width, height = img.size

    bg_pixels = []
    for x in range(min(50, width)):
        for y in range(min(50, height)):
            bg_pixels.append(pixels[x, y])

    r_vals = [p[0] for p in bg_pixels]
    g_vals = [p[1] for p in bg_pixels]
    b_vals = [p[2] for p in bg_pixels]

    r_min, r_max = min(r_vals) - 15, max(r_vals) + 15
    g_min, g_max = min(g_vals) - 15, max(g_vals) + 15
    b_min, b_max = min(b_vals) - 15, max(b_vals) + 15

    print(f"Background bounds: R({r_min}-{r_max}), G({g_min}-{g_max}), B({b_min}-{b_max})")

    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if r_min <= r <= r_max and g_min <= g <= g_max and b_min <= b <= b_max:
                pixels[x, y] = (0, 0, 0, 0)

    img.save(output_path)
    print("Saved")
except Exception as e:
    print(f"Error: {e}")
