# Scythe Add-On — Minecraft Bedrock Edition

A custom scythe weapon add-on for Minecraft Bedrock Edition.

## Features

- **Iron Scythe** — craftable melee weapon with 8 attack damage and 500 durability
- Custom 3D model and hold animation
- Enchantable (sword slot) and repairable with iron ingots

## Crafting Recipe

```
_ I I
_ S I
S _ _
```
`I` = Iron Ingot, `S` = Stick

## Project Structure

```
Scythe-add-on_minecraft-mod/
├── behavior_pack/          # Game logic (items, recipes, loot tables)
│   ├── manifest.json
│   ├── items/
│   │   └── scythe.json
│   ├── recipes/
│   │   └── scythe_crafting.json
│   └── loot_tables/items/
│       └── scythe.json
└── resource_pack/          # Visuals (textures, models, animations)
    ├── manifest.json
    ├── items/
    │   └── scythe.json
    ├── textures/
    │   ├── item_texture.json
    │   └── items/
    │       └── iron_scythe.png   ← add your texture here
    ├── models/entity/
    │   └── scythe.geo.json
    ├── animations/
    │   └── scythe.animation.json
    ├── attachables/
    │   └── scythe.json
    └── texts/
        ├── en_US.lang
        └── languages.json
```

## Installation

1. Copy `behavior_pack/` to `com.mojang/development_behavior_packs/`
2. Copy `resource_pack/` to `com.mojang/development_resource_packs/`
3. Enable both packs on your world

## TODO

- [ ] Add `iron_scythe.png` texture (16×16)
- [ ] Refine 3D geometry in Blockbench
- [ ] Add sweep/area attack via Script API
- [ ] Add additional scythe tiers (gold, diamond, netherite)
