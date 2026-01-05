#!/usr/bin/env python3
"""
Generate iOS App Icon for ZenOrigami
Following iOS Human Interface Guidelines 2026
"""

import sys
from pathlib import Path

# Add lib to path
sys.path.append(str(Path.home() / '.claude/skills/game-asset-generator/lib'))

from image_generator import ImageGenerator
from config import Config
from PIL import Image

# Get API key
config = Config()
api_key = config.get_api_key('gemini')

# Initialize generator
generator = ImageGenerator(api_key=api_key, provider='gemini')

# iOS App Icon Prompt (Best Practice 2026)
app_icon_prompt = {
    'name': 'ZenOrigami App Icon',
    'prompt': '''Create an iOS app icon for a zen meditation idle game in a 2.5D stylized minimalist origami art style.

COMPOSITION (centered, clear hierarchy):
- FOREGROUND: Large prominent origami paper boat (60% of icon size)
  - Light blue origami paper with visible geometric fold lines
  - Triangular sails, angular hull, facing right
  - Clear, bold, instantly recognizable even at 20px

- BACKGROUND: Stylized origami mountains
  - Distant mountain peaks in soft blue/white
  - Simple angular shapes, layered for depth
  - Low horizon line (bottom 30% of icon)

- SKY: Gradient from light blue to teal (#7EC8E3 to #4FB3BF)
  - Soft, calming zen atmosphere
  - Clean pastel colors

STYLE REQUIREMENTS:
- Bold, clear shapes (recognizable at 20-180px)
- High contrast between boat and background
- Minimal details, maximum impact
- Zen aesthetic, modern minimalist
- 2.5D illustration style

Square format 1024x1024px.
Solid background (NO transparency - iOS requirement).
Rounded corners added automatically by iOS.
Style: iOS app icon, game-ready, stylized origami art.''',
    'filename': 'AppIcon.png'
}

# Output directories
project_root = Path('/root/ZenOrigami-iOS')
output_dir = project_root / '.temp_assets/app_icon'
output_dir.mkdir(parents=True, exist_ok=True)

print("🎨 Generating iOS App Icon...")
print("=" * 60)
print(f"📱 Following iOS Human Interface Guidelines 2026")
print(f"📐 Size: 1024x1024px (master)")
print(f"🎯 Style: 2.5D Stylized Origami")
print()

# Generate master icon (1024x1024)
master_path = output_dir / app_icon_prompt['filename']
print(f"🎨 Generating master icon...")
success = generator.generate_image(app_icon_prompt['prompt'], str(master_path))

if success:
    print(f"✅ Generated master icon: {master_path}")

    # Verify size and format
    img = Image.open(master_path)
    print(f"📐 Size: {img.size}")
    print(f"📄 Format: {img.format}")
    print(f"🎨 Mode: {img.mode}")

    # Ensure RGB mode (no alpha for iOS)
    if img.mode == 'RGBA':
        print(f"⚠️  Converting RGBA to RGB (iOS requirement)...")
        # Create white background
        rgb_img = Image.new('RGB', img.size, (255, 255, 255))
        rgb_img.paste(img, mask=img.split()[3] if len(img.split()) == 4 else None)
        rgb_img.save(master_path, 'PNG', quality=100)
        img = rgb_img
        print(f"✅ Converted to RGB")

    # Generate all iOS required sizes
    sizes = {
        'iPhone Notification': [20, 40, 60],
        'iPhone Settings': [58, 87],
        'iPhone Spotlight': [80, 120],
        'iPhone App': [120, 180],
        'iPad Notification': [20, 40],
        'iPad Settings': [29, 58],
        'iPad Spotlight': [40, 80],
        'iPad App': [76, 152],
        'iPad Pro App': [167],
        'App Store': [1024]
    }

    print()
    print("📦 Generating iOS required sizes...")
    all_sizes_dir = output_dir / 'all_sizes'
    all_sizes_dir.mkdir(exist_ok=True)

    for category, size_list in sizes.items():
        for size in size_list:
            resized = img.copy()
            resized.thumbnail((size, size), Image.Resampling.LANCZOS)
            output_path = all_sizes_dir / f'icon_{size}x{size}.png'
            resized.save(output_path, 'PNG', optimize=True, quality=95)
            print(f"  ✅ {size}x{size}px ({category})")

    print()
    print("=" * 60)
    print("✅ App Icon Generation Complete!")
    print()
    print(f"📂 Master Icon: {master_path}")
    print(f"📂 All Sizes: {all_sizes_dir}")
    print()
    print("📱 Next Steps:")
    print("  1. Review master icon at 1024x1024")
    print("  2. Integrate into Xcode AppIcon.appiconset")
    print("  3. Update Contents.json with all sizes")

else:
    print("❌ Failed to generate app icon")
    sys.exit(1)
