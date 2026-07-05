from PIL import Image

input_path = 'assets/images/landing_bg.jpg'
try:
    img = Image.open(input_path)
    width, height = img.size
    print(f"Image size: {width}x{height}")
    
    # Let's check some pixels in the middle vs edges
    print(f"Center pixel: {img.getpixel((width//2, height//2))}")
    print(f"Edge pixel (top left): {img.getpixel((10, 10))}")
except Exception as e:
    print(f"Error: {e}")
