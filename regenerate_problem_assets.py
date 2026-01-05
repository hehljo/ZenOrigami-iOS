#!/usr/bin/env python3
"""
Regenerate problematic assets with corrected settings
- master_star: More solid star with less aggressive removal
- water_splash: White background for AI removal
- parallax_mountains: Preserve mountain details
"""

import sys
from pathlib import Path

# Add lib to path
sys.path.append(str(Path.home() / '.claude/skills/game-asset-generator/lib'))

from image_generator import ImageGenerator
from background_remover import BackgroundRemover
from config import Config

# Get API key
config = Config()
api_key = config.get_api_key('gemini')

# Initialize components
generator = ImageGenerator(api_key=api_key, provider='gemini')
remover = BackgroundRemover(method='ai')

# Asset definitions with CORRECTED prompts (white background, 2.5D style)
assets = [
    {
        'name': 'Master Star',
        'prompt': '''Create a radiant master achievement star in a stylized minimalist art style.
Eight-pointed star with radiating triangular light rays.
Made of bright golden yellow origami paper with visible geometric fold lines.
Soft shading for depth, clean flat colors with subtle gradients.
2.5D illustration style - between flat and realistic.
Solid, well-defined shape with clear edges.
Isolated on pure white background. No shadows, no glow effects on background.
Style: modern minimalist, zen aesthetic, game-ready icon, stylized origami illustration.''',
        'filename': 'icon_master_star.png'
    },
    {
        'name': 'Water Splash',
        'prompt': '''Create water splash droplets in a stylized minimalist art style.
Small water drop shapes with various sizes and dynamic angles.
Light blue translucent origami paper with visible geometric facets.
Soft shading for depth, clean flat colors with subtle gradients.
2.5D illustration style - between flat and realistic.
Sheet with 8-12 individual droplet variations showing splash motion.
Isolated on pure white background. No water surface, no shadows, no reflections.
Style: modern minimalist, zen aesthetic, game-ready particles, stylized origami illustration.''',
        'filename': 'particle_water_splash.png'
    },
    {
        'name': 'Mountains Near',
        'prompt': '''Create nearby hills and mountains in a stylized minimalist art style.
Medium-height rolling hills with rounded peaks.
Green and brown origami paper with visible geometric fold lines.
Soft shading for depth, simple angular shapes with clean flat colors.
2.5D illustration style - between flat and realistic.
Horizontal panorama format suitable for parallax scrolling.
Isolated on pure white background. No sky, no clouds, no cast shadows.
Style: modern minimalist, zen landscape, game-ready background, stylized origami illustration.''',
        'filename': 'parallax_mountains_near.png'
    }
]

# Output directories
project_root = Path('/root/ZenOrigami-iOS')
gen_dir = project_root / '.temp_assets/01_generated'
nobg_dir = project_root / '.temp_assets/02_no_background'
opt_dir = project_root / '.temp_assets/03_optimized'

gen_dir.mkdir(parents=True, exist_ok=True)
nobg_dir.mkdir(parents=True, exist_ok=True)
opt_dir.mkdir(parents=True, exist_ok=True)

print("🔧 Regenerating problematic assets with corrected settings...")
print("=" * 60)

for i, asset in enumerate(assets, 1):
    print(f"\n📦 [{i}/{len(assets)}] {asset['name']}")
    print(f"🎨 Regenerating: {asset['filename']}")

    # Generate
    gen_path = gen_dir / asset['filename']
    success = generator.generate_image(asset['prompt'], str(gen_path))

    if success:
        print(f"✅ Generated: {gen_path}")

        # Remove background with AI
        nobg_path = nobg_dir / asset['filename']
        print(f"🤖 AI background removal...")
        remover.remove_background(str(gen_path), str(nobg_path))
        print(f"✅ Background removed: {nobg_path}")

        # Optimize
        from PIL import Image
        opt_path = opt_dir / asset['filename']
        img = Image.open(nobg_path)

        # Resize maintaining aspect ratio
        max_size = 1024
        img.thumbnail((max_size, max_size), Image.Resampling.LANCZOS)

        # Save optimized
        img.save(opt_path, 'PNG', optimize=True, quality=95)
        print(f"✅ Optimized: {opt_path}")

        if i < len(assets):
            import time
            print("⏳ Waiting 2.0s...")
            time.sleep(2.0)
    else:
        print(f"❌ Failed to generate {asset['filename']}")

print("\n" + "=" * 60)
print("✅ Regeneration complete!")
print(f"📂 Check: {opt_dir}")
