from PIL import Image

input_path = 'assets/images/landing_bg.jpg'
output_path = 'assets/images/landing_bg_cropped.jpg'

try:
    img = Image.open(input_path).convert('RGB')
    width, height = img.size
    pixels = img.load()
    
    bg_color = pixels[10, 10]
    
    # Find bounding box of the phone screen (or anything not bg_color)
    def color_dist(c1, c2):
        return sum(abs(a-b) for a, b in zip(c1, c2))
        
    left, top, right, bottom = width, height, 0, 0
    
    for y in range(height):
        for x in range(width):
            if color_dist(pixels[x, y], bg_color) > 30:
                if x < left: left = x
                if x > right: right = x
                if y < top: top = y
                if y > bottom: bottom = y
                
    print(f"Bounding box: {left}, {top}, {right}, {bottom}")
    
    # Phone bezels are usually thick. Let's crop an extra 5% from all sides just to be safe
    # Actually, the user wants "저 내부 사진만 사용해주고". The bounding box might include the phone frame itself!
    # Let's sample from the very center and expand until we hit the bezel.
    
    center_color = pixels[width//2, height//2]
    # This might not work if the screen has multiple colors.
    
    # Let's just crop based on a typical phone mockup ratio, or search for the inner screen bounds.
    # Often phone screens have a black bezel.
    
    # Let's save a heavily cropped image and we can adjust.
    # Typically, the screen is inside the phone frame. 
    # Let's crop the outer 10% of width and height of the bounding box.
    w = right - left
    h = bottom - top
    
    c_left = left + int(w * 0.05)
    c_top = top + int(h * 0.05)
    c_right = right - int(w * 0.05)
    c_bottom = bottom - int(h * 0.05)
    
    cropped = img.crop((c_left, c_top, c_right, c_bottom))
    cropped.save(output_path)
    print("Saved cropped image")
except Exception as e:
    print(f"Error: {e}")
