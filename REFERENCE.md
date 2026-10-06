# Reference — Scythe Add-On (Minecraft Bedrock)

## What it is

A two-pack Minecraft Bedrock Edition add-on that adds one custom melee weapon,
`scythe:iron_scythe` — 8 damage, 500 durability, enchantable in the sword slot,
repairable with iron ingots. Pure JSON; no Script API, no build step, no dependencies.
20 files total.

## Current state (2026-10-06)

**Scaffold, not working.** Last commit 2026-06-10. The add-on has never been confirmed
to load in-game — the owner's own notes recorded the crafting recipe failing during an
iPad test, and work stopped there. There is also no way to package it for a device.
See `TODO.md` for the ranked path to a first successful load.

What is genuinely done: both manifests have real, unique UUIDs and the BP→RP dependency
is correctly in sync (`533f82e0-…`); the texture atlas registration is correct; pack
icons exist at 256×256.

What is placeholder: the item texture (119 bytes, a diagonal line), the pack icons, and
the 3D geometry (two stacked cubes).

## Layout

```
behavior_pack/          # game logic
  manifest.json         # BP header 40c8cb20-…, depends on RP 533f82e0-…
  items/scythe.json     # the item definition — both known bugs live here
  recipes/scythe_crafting.json
  loot_tables/items/scythe.json   # orphan, referenced by nothing
resource_pack/          # visuals
  manifest.json         # RP header 533f82e0-…
  items/scythe.json     # legacy-format item def; declares the icon
  textures/item_texture.json + textures/items/iron_scythe.png
  models/entity/scythe.geo.json   # geometry.scythe
  animations/scythe.animation.json # animation.scythe.wield (static pose)
  attachables/scythe.json          # ties model + texture + animation together
  texts/en_US.lang, texts/languages.json
```

## Running it

No build. To test on a desktop Bedrock install:

1. Copy `behavior_pack/` into `com.mojang/development_behavior_packs/`
2. Copy `resource_pack/` into `com.mojang/development_resource_packs/`
3. Enable **both** packs on the world — the item will not appear with only one

For iPad, see `TESTING_IPAD.md` — but note two of its instructions are currently wrong
(`TODO.md` task 5), and it assumes a `.mcaddon` file that does not exist yet.

## Target

Minecraft Bedrock 1.21.0+ (`min_engine_version` in both manifests). Item and recipe
definitions use `format_version` `1.21.0`; the attachable uses `1.10.0` and the geometry
`1.12.0`, which is normal — those schemas version independently.

## Gotchas

- Recipe pattern is `" II" / " SI" / "S  "` — iron top-right, sticks on the lower-left
  diagonal. The README, `TESTING_IPAD.md`, and the JSON all agree on this.
- `minecraft:display_name` in the BP item hardcodes the literal string `"Iron Scythe"`,
  so `resource_pack/texts/en_US.lang` is currently dead weight. Switch it to the key
  `item.scythe:iron_scythe.name` before adding any second locale.
- `.gitignore` excludes `*.mcaddon`, `*.mcpack`, `*.zip` — distributable builds are meant
  to be GitHub release assets, never committed.
