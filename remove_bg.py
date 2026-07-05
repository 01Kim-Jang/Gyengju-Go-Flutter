import os
from rembg import remove
from PIL import Image

input_path = 'assets/images/character.png'
output_path = 'assets/images/character.png'

print(f"Loading {input_path}")
try:
    input_image = Image.open(input_path)
    print("Removing background...")
    output_image = remove(input_image)
    output_image.save(output_path)
    print(f"Saved to {output_path}")
except Exception as e:
    print(f"Error: {e}")
