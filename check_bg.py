from PIL import Image

input_path = 'assets/images/character.png'

try:
    img = Image.open(input_path).convert("RGBA")
    pixels = img.load()
    width, height = img.size

    bg_colors = set()
    for x in range(min(10, width)):
        for y in range(min(10, height)):
            r, g, b, a = pixels[x, y]
            if a > 0:
                bg_colors.add((r, g, b))

    print("Found background colors:", bg_colors)
except Exception as e:
    print(f"Error: {e}")
