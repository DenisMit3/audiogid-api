
import os
from PIL import Image, ImageDraw, ImageFont, ImageColor

def create_icon():
    # Create 1024x1024 image
    size = (1024, 1024)
    image = Image.new('RGBA', size, (255, 255, 255, 0))
    draw = ImageDraw.Draw(image)

    # Gradient Background (Deep Blue to Purple)
    # Simple linear gradient simulation
    top_color = (13, 17, 23)   # Dark Web Style
    bottom_color = (35, 134, 54) # Green accent
    
    # Modern Gradientish background
    for y in range(size[1]):
        r = int(top_color[0] + (bottom_color[0] - top_color[0]) * y / size[1])
        g = int(top_color[1] + (bottom_color[1] - top_color[1]) * y / size[1])
        b = int(top_color[2] + (bottom_color[2] - top_color[2]) * y / size[1])
        draw.line([(0, y), (1024, y)], fill=(r, g, b))

    # Draw "AG" Logo or similar
    # Loading default font since we don't know what's available
    # Drawing a simple sleek Circle and Text
    
    # Circle
    margin = 100
    draw.ellipse([margin, margin, 1024-margin, 1024-margin], outline=(255, 255, 255), width=40)
    
    # Text "AudioGid" or similar symbol
    # Since we lack custom fonts, let's draw a Play triangle
    
    # Center Point (512, 512)
    # Triangle Points
    p1 = (400, 300)
    p2 = (400, 724)
    p3 = (750, 512)
    
    draw.polygon([p1, p2, p3], fill=(255, 255, 255))
    
    # Save
    path = "apps/mobile_flutter/assets/store/icon.png"
    os.makedirs(os.path.dirname(path), exist_ok=True)
    image.save(path)
    print(f"Icon generated at {path}")

if __name__ == "__main__":
    create_icon()
