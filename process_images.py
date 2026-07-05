import os
import shutil
from PIL import Image

# 1. Backgrounds
shutil.copy('assets/images/landing_bg_cropped.jpg', 'assets/images/landing_bg.jpg')
shutil.copy(r'C:\Users\baram\.gemini\antigravity\brain\3daaf8df-13a9-4412-82dd-55e798b0c854\hanji_bg_1783223933379.png', 'assets/images/hanji_bg.png')

# 2. Characters
chars = {
    r'C:\Users\baram\.gemini\antigravity\brain\3daaf8df-13a9-4412-82dd-55e798b0c854\char_female_clean_1783223942847.png': 'assets/images/char_style1_female.png',
    r'C:\Users\baram\.gemini\antigravity\brain\3daaf8df-13a9-4412-82dd-55e798b0c854\char_male_dot_1783223950715.png': 'assets/images/char_style2_male.png',
    r'C:\Users\baram\.gemini\antigravity\brain\3daaf8df-13a9-4412-82dd-55e798b0c854\char_female_dot_1783223959387.png': 'assets/images/char_style2_female.png',
}

for src, dst in chars.items():
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
        print(f"Saved {dst}")
    except Exception as e:
        print(f"Error processing {src}: {e}")
