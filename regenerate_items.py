#!/usr/bin/env python3
"""
Regenerate falling items with darker, more saturated colors for better visibility
"""

import sys
from pathlib import Path

# Add lib to path
sys.path.append(str(Path.home() / '.claude/skills/game-asset-generator/lib'))

from image_generator import ImageGenerator
from config import Config
from background_remover import BackgroundRemover

# Get API key
config = Config()
api_key = config.get_api_key('gemini')

# Initialize generator
generator = ImageGenerator(api_key=api_key, provider='gemini')
bg_remover = BackgroundRemover(method="ai")

# Output directory
project_root = Path('/root/ZenOrigami-iOS')
output_dir = project_root / '.temp_assets/items_v2'
output_dir.mkdir(parents=True, exist_ok=True)

# Updated prompts with darker, more saturated colors
items = [
    {
        'name': 'Water Drop (Dark Blue)',
        'prompt': '''Create a water droplet in 2.5D stylized origami paper art style.

APPEARANCE:
- Made of origami paper in DEEP VIBRANT BLUE color (#0066CC to #004080)
- Geometric facets with visible paper fold lines creating a gem-like shape
- Classic teardrop shape with pointed top, rounded bottom
- Strong saturated color, NOT pastel or light blue
- Subtle inner glow/highlight for gem effect

STYLE:
- 2.5D stylized illustration (between flat and realistic)
- Clean, bold shapes with high contrast
- Modern minimalist zen aesthetic
- Isolated on pure white background
- No cast shadows on background

Size: 512x512px, centered composition, asset takes up 60% of canvas.
Style: Game-ready collectible item, stylized origami art, high contrast.''',
        'filename': 'drop.png'
    },
    {
        'name': 'Pearl (Bright Magenta)',
        'prompt': '''Create a precious pearl in 2.5D stylized origami paper art style.

APPEARANCE:
- Made of origami paper in BRIGHT VIBRANT MAGENTA color (#CC00CC to #FF00FF)
- Geometric facets creating spherical shape with visible fold lines
- Pearlescent shimmer effect with subtle iridescence
- Strong saturated color for maximum visibility
- Glossy, gem-like appearance

STYLE:
- 2.5D stylized illustration (between flat and realistic)
- Bold, clear shapes with high contrast
- Modern minimalist zen aesthetic
- Isolated on pure white background
- No cast shadows on background

Size: 512x512px, centered composition, asset takes up 60% of canvas.
Style: Game-ready collectible item, stylized origami art, premium feel.''',
        'filename': 'pearl.png'
    },
    {
        'name': 'Leaf (Vibrant Green)',
        'prompt': '''Create an autumn leaf in 2.5D stylized origami paper art style.

APPEARANCE:
- Made of origami paper in VIBRANT EMERALD GREEN color (#00AA44 to #00CC55)
- Geometric fold lines forming leaf veins and structure
- Simple geometric leaf shape with pointed tip
- Strong saturated green, NOT light or pastel
- Slight gradient from darker stem to brighter tip

STYLE:
- 2.5D stylized illustration (between flat and realistic)
- Bold, clear shapes with high contrast
- Modern minimalist zen aesthetic
- Isolated on pure white background
- No cast shadows on background

Size: 512x512px, centered composition, asset takes up 60% of canvas.
Style: Game-ready collectible item, stylized origami art, botanical minimalism.''',
        'filename': 'leaf.png'
    }
]

print("🎨 Regenerating Falling Items with Darker Colors")
print("=" * 60)
print("📝 Colors:")
print("  - Drop: Deep Vibrant Blue (#0066CC)")
print("  - Pearl: Bright Magenta (#CC00CC)")
print("  - Leaf: Vibrant Emerald Green (#00AA44)")
print()

for item in items:
    print(f"🎨 Generating {item['name']}...")

    # Generate image
    raw_path = output_dir / f"raw_{item['filename']}"
    success = generator.generate_image(item['prompt'], str(raw_path))

    if success:
        print(f"  ✅ Generated raw image")

        # Remove background
        final_path = output_dir / item['filename']
        if bg_remover.remove_background(str(raw_path), str(final_path)):
            print(f"  ✅ Removed background")
            print(f"  📂 Saved: {final_path}")
        else:
            print(f"  ❌ Background removal failed")
    else:
        print(f"  ❌ Generation failed")
    print()

print("=" * 60)
print("✅ Regeneration Complete!")
print()
print(f"📂 Output: {output_dir}")
print()
print("📱 Next Steps:")
print("  1. Review images for color saturation")
print("  2. Copy to Assets.xcassets/Items/")
print("  3. Test visibility in game against water background")
