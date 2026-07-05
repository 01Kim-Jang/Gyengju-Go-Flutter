from PIL import Image

input_path = r'C:\Users\baram\.gemini\antigravity\brain\3daaf8df-13a9-4412-82dd-55e798b0c854\character_new_1783223254959.png'
output_path = 'assets/images/character.png'

try:
    img = Image.open(input_path).convert("RGBA")
    pixels = img.load()
    width, height = img.size

    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            # Tolerate slightly off-white colors as white
            if r > 240 and g > 240 and b > 240:
                pixels[x, y] = (0, 0, 0, 0)

    img.save(output_path)
    print("Saved")
except Exception as e:
    print(f"Error: {e}")
