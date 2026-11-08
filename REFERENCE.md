# Reference — Scythe Add-On (Minecraft Bedrock)

## What it is

A two-pack Minecraft Bedrock Edition add-on that adds one custom melee weapon,
`scythe:iron_scythe` — 8 damage, 500 durability, enchantable in the sword slot,
repairable with iron ingots. Pure JSON; no Script API, no runtime dependencies. 24 files.

## Current state (2026-11-08)

**Close, but never once loaded in-game.** The defects that would have stopped the item
registering are fixed (`8644814`: dropped the `minecraft:weapon` component pointing at an
undefined `scythe:hurt_event`, added `minecraft:icon` on the behavior side) and the item icon
is real 16×16 pixel art (`2560df4`). All 12 JSON files parse clean.

Three things still stand between this and done:

1. **`build.sh` does not run.** `build.sh:7` calls `zip`, which is not installed on this
   machine (`which zip` → exit 1, no `7z` either), and `set -euo pipefail` aborts there. The
   `3a68778` commit message confirms it was never executed. One-line fix in `TODO.md` task 1:
   `python3 -m zipfile -c scythe_addon.mcaddon behavior_pack resource_pack`.
2. **The 3D held model is broken twice over.** `attachables/scythe.json:11` UV-maps the
   geometry onto the item *icon*, and the blade cube's UV window is 11% opaque — the held
   scythe renders as a near-invisible sliver. Separately `scythe.geo.json` is two stacked
   boxes, not a scythe shape at all. `TODO.md` task 2: delete the attachable chain and ship
   the flat `hand_equipped` sprite.
3. **The icon's blade is detached from its handle** — a 2-px break at column 8, rows 3–4.
   `TODO.md` task 3.

## Layout

```
build.sh                # zips both packs into scythe_addon.mcaddon — currently broken
behavior_pack/
  manifest.json         # BP header 40c8cb20-…, depends on RP 533f82e0-…
  items/scythe.json     # the item definition — icon, damage, durability, tags
  recipes/scythe_crafting.json
  loot_tables/items/scythe.json   # orphan, referenced by nothing
  pack_icon.png         # placeholder, byte-identical to the RP one
resource_pack/
  manifest.json         # RP header 533f82e0-…
  items/scythe.json     # legacy duplicate, retired `category` field — delete
  textures/item_texture.json + textures/items/iron_scythe.png
  models/entity/scythe.geo.json    # geometry.scythe, two stacked boxes, bad UVs
  animations/scythe.animation.json # animation.scythe.wield, one static pose
  attachables/scythe.json          # ties model + texture + animation together
  texts/en_US.lang, texts/languages.json
```

## Running it

To test on a desktop Bedrock install (no build needed):

1. Copy `behavior_pack/` into `com.mojang/development_behavior_packs/`
2. Copy `resource_pack/` into `com.mojang/development_resource_packs/`
3. Enable **both** packs on the world — the item will not appear with only one

For iPad you need a `.mcaddon`: fix and run `build.sh`, then follow `TESTING_IPAD.md` —
but five of that guide's statements are currently wrong (`TODO.md` task 4).

## Target

Bedrock 1.21.0+ (`min_engine_version` in both manifests). Item and recipe use
`format_version` `1.21.0`; the attachable uses `1.10.0` and the geometry `1.12.0`, which is
normal — those schemas version independently.

## Gotchas

- Recipe pattern is `" II" / " SI" / "S  "` — iron top-right, sticks on the lower-left
  diagonal. README, `TESTING_IPAD.md` and the JSON all agree.
- `minecraft:display_name` hardcodes the literal `"Iron Scythe"`, so `texts/en_US.lang` is
  never read. Delete the component (Bedrock falls back to `item.<identifier>.name`) before
  adding a second locale.
- `.gitignore` excludes `*.mcaddon`, `*.mcpack`, `*.zip` — builds are meant to be GitHub
  release assets, never committed. No release exists yet.
- Both packs must sit at the **archive root** in the `.mcaddon`; nesting them under a parent
  folder makes an iPad import fail silently.
