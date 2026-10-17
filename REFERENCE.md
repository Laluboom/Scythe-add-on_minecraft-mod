# Reference — Scythe Add-On (Minecraft Bedrock)

## What it is

A two-pack Minecraft Bedrock Edition add-on that adds one custom melee weapon,
`scythe:iron_scythe` — 8 damage, 500 durability, enchantable in the sword slot,
repairable with iron ingots. Pure JSON; no Script API, no dependencies. 23 files.

## Current state (2026-10-17)

**Close, but never yet loaded in-game.** The two defects that would have stopped the item
registering are fixed (`8644814`: dropped the `minecraft:weapon` component pointing at an
undefined `scythe:hurt_event`, added `minecraft:icon` on the behavior side) and the item
icon is now real 16×16 pixel art (`2560df4`). All 12 JSON files parse.

Two things still stand between this and done:

1. **No packaging step.** There is no build script anywhere in the repo, `.gitignore`
   excludes `*.mcaddon`, and no release exists — so there is no way to get the add-on onto
   a device, and the fixes above remain unverified.
2. **The 3D held model is broken.** `attachables/scythe.json:11` UV-maps the geometry onto
   the item *icon* texture; the blade cube's UV window is 11% opaque, so the held scythe
   will render as a near-invisible sliver. See `TODO.md` task 2 — deleting the attachable
   chain and shipping the flat `hand_equipped` sprite is the recommended fix.

## Layout

```
behavior_pack/
  manifest.json         # BP header 40c8cb20-…, depends on RP 533f82e0-…
  items/scythe.json     # the item definition — icon, damage, durability, tags
  recipes/scythe_crafting.json
  loot_tables/items/scythe.json   # orphan, referenced by nothing
  pack_icon.png         # 256×256, placeholder, identical to the RP one
resource_pack/
  manifest.json         # RP header 533f82e0-…
  items/scythe.json     # legacy duplicate, malformed `category` field — delete
  textures/item_texture.json + textures/items/iron_scythe.png
  models/entity/scythe.geo.json    # geometry.scythe, two cubes, bad UVs
  animations/scythe.animation.json # animation.scythe.wield, one static pose
  attachables/scythe.json          # ties model + texture + animation together
  texts/en_US.lang, texts/languages.json
```

## Running it

No build step yet. To test on a desktop Bedrock install:

1. Copy `behavior_pack/` into `com.mojang/development_behavior_packs/`
2. Copy `resource_pack/` into `com.mojang/development_resource_packs/`
3. Enable **both** packs on the world — the item will not appear with only one

For iPad, see `TESTING_IPAD.md`, but it assumes a `.mcaddon` that does not exist and five
of its statements are now wrong (`TODO.md` task 5).

## Target

Bedrock 1.21.0+ (`min_engine_version` in both manifests). Item and recipe use
`format_version` `1.21.0`; the attachable uses `1.10.0` and the geometry `1.12.0`, which is
normal — those schemas version independently.

## Gotchas

- Recipe pattern is `" II" / " SI" / "S  "` — iron top-right, sticks on the lower-left
  diagonal. README, `TESTING_IPAD.md` and the JSON all agree.
- `minecraft:display_name` hardcodes the literal `"Iron Scythe"`, so
  `texts/en_US.lang` is dead weight. Point it at `item.scythe:iron_scythe.name` before
  adding a second locale.
- `.gitignore` excludes `*.mcaddon`, `*.mcpack`, `*.zip` — builds are meant to be GitHub
  release assets, never committed.
