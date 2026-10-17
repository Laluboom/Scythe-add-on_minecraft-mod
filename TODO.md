# Scythe Add-On — TODO

Ranked. Best first. Reviewed 2026-10-17.

**Status: still never confirmed working in-game.** The 2026-10-06 review's tasks 1 and 3
(item definition, texture) both landed — commits `8644814` and `2560df4`. Task 2
(`build.sh`) was skipped, and it was the one that unblocked testing. It is back at #1.

Everything below is ordered to get to one successful load on the iPad.

---

## 1. `[DONE 2026-10-17]` Add `build.sh` that produces `scythe_addon.mcaddon`

Still no way to get this onto a device. Nothing in `git ls-files` is a script. `.gitignore:11`
ignores `*.mcaddon`, there is no GitHub release, and `TESTING_IPAD.md:13` tells the reader
to "download `scythe_addon.mcaddon` directly" from the repo — a file that cannot exist
in-tree. The documented happy path is impossible, and that is the entire reason the item
fixes from 11 days ago are still unverified.

~20 min: a shell script that zips `behavior_pack/` and `resource_pack/` into
`scythe_addon.mcaddon`. **Both folders must sit at the archive root**, not nested inside a
parent directory — that nesting is the usual reason an iPad import silently does nothing.
`cd` into the repo root and `zip -r scythe_addon.mcaddon behavior_pack resource_pack
-x '*.DS_Store'` is the whole job; the value is in having it committed so it is repeatable.

This is the gate. Nothing else on this list can be checked without it.

## 2. [BUG] The held 3D model renders near-invisible — most likely delete it

`resource_pack/attachables/scythe.json:11` points the model's `default` texture at
`textures/items/iron_scythe` — the 16×16 *item icon*. But `scythe.geo.json:22-40` box-UVs
its cubes onto regions of that icon that are mostly empty:

- blade cube (`origin [-1,8,-1]`, `size [2,8,2]`, `uv [0,0]`) samples u 0–8, v 0–10.
  **9 of those 80 pixels are opaque (11%).** The icon's art lives in columns 8–15.
- handle cube (`size [1,8,1]`, `uv [8,0]`) samples u 8–12, v 0–9 — 18/36 opaque, but that
  region is the *steel blade* pixels, not the brown handle.

With `entity_alphatest` (line 7) the transparent samples are discarded, so in third person
the scythe will be a thin steel sliver where the handle should be and nothing where the
blade should be. Measured by decoding the PNG and counting alpha per UV window.

Two ways out, ~45 min either way:

- **Delete `attachables/scythe.json`, `models/entity/scythe.geo.json` and
  `animations/scythe.animation.json`.** `minecraft:hand_equipped: true`
  (`behavior_pack/items/scythe.json:13`) then renders the flat sprite held like a vanilla
  tool, which is what most Bedrock weapon add-ons ship and which now looks fine since the
  real texture landed. **Recommended** — it removes three files of broken scaffolding and
  the project becomes genuinely finished rather than genuinely half-modelled.
- Or keep the model and give it its own texture at `textures/entity/scythe.png`, sized to
  the UV layout, registered separately. That is a Blockbench session, not an hour.

Also note `animations/scythe.animation.json` is a single static pose
(`rotation [0,0,-45]`, `position [4,-4,0]`, `loop: true`) with no keyframes and no
first/third-person split — it will be wrong in one of the two views regardless. Deleting
takes care of it.

## 3. `[QUICK WIN ~15min]` Close the 2-pixel break in the scythe texture

`resource_pack/textures/items/iron_scythe.png` is real pixel art now, but the blade does
not touch the handle. Alpha down column 8, rows 0–9, reads
`[255, 255, 255, 0, 0, 255, 255, 255, 255, 255]` — rows 3 and 4 are empty. The dark rivet
at row 5 (cols 7–8) and the blade's left edge at rows 0–2 (cols 8–10) have a 2-px gap
between them, so in the hotbar the blade floats above the handle.

Fill (3,8) and (4,8) with the blade's dark outline tone `#363A3D` — the same colour already
used at (2,8) — or extend the handle's light-brown column up two rows. One edit, visible
immediately in the hotbar, and it is the last thing making the icon look unfinished.

## 4. [CHORE] Clear the three pieces of dead weight

~15 min total, all verified dead by grep:

- `resource_pack/items/scythe.json` — declares `format_version "1.21.0"` but uses
  `description.category: "Equipment"` (line 6), the field replaced by `menu_category` in
  the modern schema. It duplicates the identifier and the icon that
  `behavior_pack/items/scythe.json:17-19` now owns. Delete it. (The 2026-10-06 doer left
  it deliberately, calling removal scope creep — this is that scope, explicitly.)
- `behavior_pack/loot_tables/items/scythe.json` — referenced by nothing in either pack.
  Delete, or wire it to a structure/mob drop if the intent was for the scythe to be found.
- `resource_pack/texts/en_US.lang` defines `item.scythe:iron_scythe.name=Iron Scythe`, but
  `behavior_pack/items/scythe.json:38-40` hardcodes the literal string in
  `minecraft:display_name.value`, so the lang file never gets read. Change the value to the
  key `item.scythe:iron_scythe.name`. Costs nothing now and is the difference between
  "add a locale" being a one-file change versus a refactor later.

## 5. [DOCS] Fix the five claims in the docs that are now false

~20 min, and it matters because these are the instructions a tester follows:

- `TESTING_IPAD.md:13` — the "download the .mcaddon from GitHub" path. Point at `build.sh`
  from task 1, or cut a release.
- `TESTING_IPAD.md:97` and `:102` — both say the texture is a grey silhouette / grey shape.
  Not true since `2560df4`. Delete those lines; a tester reading them will dismiss a real
  rendering bug as expected.
- `TESTING_IPAD.md:53-58` and `:94` — the guide demands **Holiday Creator Features** under
  Experiments and blames a missing scythe on it. The item uses `menu_category`, the stable
  post-1.20.60 schema, which should not need the experiment at all. Verify against the
  actual client during the task-1 test run and correct or drop it — as written it sends you
  hunting for a toggle that may not exist, on exactly the symptom already hit once.
- `README.md:59` — `- [ ] Add iron_scythe.png texture (16×16)` is done. Tick or remove it.

---

## Parked (real wants, not scoped yet)

- Both pack icons are byte-identical (`md5 60a910e7…`) and are a flat three-colour dark-blue
  blob, so BP and RP are indistinguishable in the pack list. Cosmetic; do it when bored.
- Script API work — sweep attack, crop harvest, lifesteal. Needs a `script` module in the BP
  manifest and a `@minecraft/server` dependency. Don't start before task 1 lands.
- Gold / diamond / netherite tiers; custom swing sound; extra locales (see task 4's lang fix).
- The dragon-egg + dragon-head + blaze-rod recipe idea from `README.md:63`.
