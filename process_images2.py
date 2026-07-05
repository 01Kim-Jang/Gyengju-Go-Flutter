import os
import shutil
from PIL import Image

# 1. Crop Landing BG further to remove notch (top 4%)
try:
    img = Image.open('assets/images/landing_bg.jpg')
    width, height = img.size
    crop_top = int(height * 0.04) # Crop 4% off the top
    cropped = img.crop((0, crop_top, width, height))
    cropped.save('assets/images/landing_bg.jpg')
    print("Cropped landing_bg.jpg to remove notch.")
except Exception as e:
    print(f"Error cropping landing bg: {e}")

# 2. Process 6 Characters
chars = {
    r'C:\Users\baram\.gemini\antigravity\brain\3daaf8df-13a9-4412-82dd-55e798b0c854\silla_king_1783224961137.png': 'assets/images/char_king.png',
    r'C:\Users\baram\.gemini\antigravity\brain\3daaf8df-13a9-4412-82dd-55e798b0c854\silla_queen_1783224971276.png': 'assets/images/char_queen.png',
    r'C:\Users\baram\.gemini\antigravity\brain\3daaf8df-13a9-4412-82dd-55e798b0c854\silla_hwarang_1783224979846.png': 'assets/images/char_hwarang.png',
    r'C:\Users\baram\.gemini\antigravity\brain\3daaf8df-13a9-4412-82dd-55e798b0c854\silla_merchant_1783224992221.png': 'assets/images/char_merchant.png',
    r'C:\Users\baram\.gemini\antigravity\brain\3daaf8df-13a9-4412-82dd-55e798b0c854\silla_princess_1783225002354.png': 'assets/images/char_princess.png',
    r'C:\Users\baram\.gemini\antigravity\brain\3daaf8df-13a9-4412-82dd-55e798b0c854\silla_main_8head_1783225169828.png': 'assets/images/char_main.png',
}

for src, dst in chars.items():
    if not os.path.exists(src):
        print(f"Warning: {src} does not exist!")
        continue
    try:
        img = Image.open(src).convert("RGBA")
        pixels = img.load()
        width, height = img.size

        for y in range(height):
            for x in range(width):
                r, g, b, a = pixels[x, y]
                # Tolerate slightly off-white colors as white
                if r > 240 and g > 240 and b > 240:
                    pixels[x, y] = (0, 0, 0, 0)

        img.save(dst)
        print(f"Processed and saved {dst}")
    except Exception as e:
        print(f"Error processing {src}: {e}")
