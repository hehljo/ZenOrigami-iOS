#!/usr/bin/env python3
"""
Regenerate falling items with Quiet Luxury colors (2026)
Gedämpfte, edle Töne - keine bunten Farben
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
output_dir = project_root / '.temp_assets/items_quiet_luxury'
output_dir.mkdir(parents=True, exist_ok=True)

# Quiet Luxury color palette 2026
items = [
    {
        'name': 'Water Drop (Soft Blue-Gray)',
        'prompt': '''Create a water droplet in 2.5D stylized origami paper art style.

QUIET LUXURY AESTHETIC (2026):
- Made of origami paper in SOFT BLUE-GRAY color (#9BADB7 to #B8C5CF)
- Muted, elegant tones - NO vibrant or bright colors
- Subtle sophistication, understated elegance
- Geometric facets with visible paper fold lines
- Classic teardrop shape with pointed top, rounded bottom
- Delicate inner highlight for subtle depth

STYLE:
- 2.5D minimalist illustration (refined, not playful)
- Clean, sophisticated shapes with soft contrast
- Quiet luxury zen aesthetic
- Isolated on pure white background
- No cast shadows on background
- Premium feel, calming presence

Size: 512x512px, centered composition, asset takes up 60% of canvas.
Style: Premium game asset, quiet luxury origami art, sophisticated and calm.''',
        'filename': 'drop.png',
        'color': '#9BADB7'
    },
    {
        'name': 'Pearl (Champagne Beige)',
        'prompt': '''Create a precious pearl in 2.5D stylized origami paper art style.

QUIET LUXURY AESTHETIC (2026):
- Made of origami paper in CHAMPAGNE BEIGE color (#E5DDD3 to #D4C9BD)
- Elegant neutral tones - NO vibrant pinks or magentas
- Sophisticated muted palette, timeless elegance
- Geometric facets creating spherical shape with visible fold lines
- Subtle pearlescent shimmer - very understated
- Soft, refined appearance

STYLE:
- 2.5D minimalist illustration (luxurious, not flashy)
- Elegant shapes with gentle contrast
- Quiet luxury zen aesthetic
- Isolated on pure white background
- No cast shadows on background
- Premium sophisticated feel

Size: 512x512px, centered composition, asset takes up 60% of canvas.
Style: Premium game asset, quiet luxury origami art, elegant and refined.''',
        'filename': 'pearl.png',
        'color': '#E5DDD3'
    },
    {
        'name': 'Leaf (Muted Sage)',
        'prompt': '''Create an autumn leaf in 2.5D stylized origami paper art style.

QUIET LUXURY AESTHETIC (2026):
- Made of origami paper in MUTED SAGE color (#B0BBA8 to #C3CDB8)
- Soft earthy green tones - NO bright emerald greens
- Sophisticated natural palette, understated elegance
- Geometric fold lines forming leaf veins and structure
- Simple geometric leaf shape with pointed tip
- Soft gradient from stem to tip - very subtle

STYLE:
- 2.5D minimalist illustration (refined botanical)
- Clean, elegant shapes with soft natural tones
- Quiet luxury zen aesthetic
- Isolated on pure white background
- No cast shadows on background
- Premium sophisticated feel

Size: 512x512px, centered composition, asset takes up 60% of canvas.
Style: Premium game asset, quiet luxury origami art, natural sophistication.''',
        'filename': 'leaf.png',
        'color': '#B0BBA8'
    }
]

print("🎨 Regenerating Items with Quiet Luxury Colors (2026)")
print("=" * 60)
print("📝 Quiet Luxury Palette:")
print("  - Drop: Soft Blue-Gray #9BADB7 (gedämpftes Blau)")
print("  - Pearl: Champagne Beige #E5DDD3 (elegantes Beige)")
print("  - Leaf: Muted Sage #B0BBA8 (sanftes Salbeigrün)")
print()
print("✨ Aesthetic: Understated elegance, refined sophistication")
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
            print(f"  🎨 Color: {item['color']}")
        else:
            print(f"  ❌ Background removal failed")
    else:
        print(f"  ❌ Generation failed")
    print()

print("=" * 60)
print("✅ Quiet Luxury Regeneration Complete!")
print()
print(f"📂 Output: {output_dir}")
print()
print("📱 Next Steps:")
print("  1. Review images for quiet luxury aesthetic")
print("  2. Copy to Assets.xcassets/Items/")
print("  3. Test in game - should feel calm, elegant, sophisticated")
