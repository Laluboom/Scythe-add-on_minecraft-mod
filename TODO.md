# Scythe Add-On — TODO

Ranked. Best first. Reviewed 2026-10-06 — the previous 280-line, 13-section version was
replaced because most of it was aspiration and two sections had gone factually wrong
(it still claimed the manifest UUIDs were placeholders and that the BP→RP dependency
pointed at `c3d4e5f6-…`; commit 865dcd0 fixed both four months ago).

**Status: this add-on has never been confirmed working in-game.** Everything below is
ordered to get to one successful load on the iPad.

---

## 1. `[DONE 2026-10-06]` Fix the item definition — this is why nothing works

`behavior_pack/items/scythe.json`. Two defects in one file, ~30 min total.

**a) Undefined event.** Lines 17–22 declare:

```json
"minecraft:weapon": { "on_hurt_entity": { "event": "scythe:hurt_event", "target": "self" } }
```

`scythe:hurt_event` is not defined anywhere — there is no `"events"` block in this file
and no other file in the pack declares it. A custom item that points at a non-existent
event raises a content error on pack load, and an item that fails to register takes its
recipe with it. This is the most likely cause of the PRIORITY bug the old TODO recorded
("recipe does not work in-game testing"). The component currently buys nothing anyway —
the event is a no-op. **Either add an `"events": { "scythe:hurt_event": { … } }` block,
or delete the `minecraft:weapon` component entirely.** Deleting is the right first move:
it isolates the variable, and plain `minecraft:damage` already handles hitting things.

**b) The icon is declared in the wrong pack.** The BP item has no `minecraft:icon`
component. The only icon declaration lives in `resource_pack/items/scythe.json:9-11`,
which is the legacy RP item format — note it also carries the old `"category": "Equipment"`
field (line 6) alongside a `format_version` of `1.21.0`, which is incoherent. For a
1.21-format item the icon belongs on the behavior side:

```json
"minecraft:icon": { "texture": "iron_scythe" }
```

Add that to the BP components, then check whether the RP item file is needed at all.

Check the content log after this change before touching anything else.

## 2. [IMPROVEMENT] Add `build.sh` that produces `scythe_addon.mcaddon`

There is no way to get this onto a device. `TESTING_IPAD.md:13` tells the reader to
"download `scythe_addon.mcaddon` directly" from the repo — but no such file exists, no
release has been cut, and `.gitignore:11` explicitly ignores `*.mcaddon`, so it never
can exist in-tree. The documented happy path is impossible.

~20 min: a shell script that zips `behavior_pack/` and `resource_pack/` into
`scythe_addon.mcaddon` (both folders at archive root, not nested in a parent dir — that
nesting is the usual reason an import silently does nothing). This matters more than it
looks: without it, task 1 cannot be verified, and the project stays untestable.

## 3. `[DONE 2026-10-06]` Draw a real 16×16 scythe texture

`resource_pack/textures/items/iron_scythe.png` is 119 bytes and renders as a single thin
diagonal stroke — it reads as a stick, not a scythe. Replace with actual pixel art: a
vertical brown handle, an iron blade curving off the top-right. Fifteen minutes in any
pixel editor and the item stops looking broken in the hotbar.

(`item_texture.json` already maps `iron_scythe` → `textures/items/iron_scythe` correctly;
no registration work needed. Just overwrite the file.)

## 4. [DESIGN] Model actual scythe geometry in Blockbench

`resource_pack/models/entity/scythe.geo.json:22-40` is not a scythe. The `blade` bone is
a 2×8×2 cube sitting directly on top of a 1×8×1 `handle` cube — a lollipop. Open it in
Blockbench as a Bedrock Entity model, give the blade a horizontal sweep off the top of
the handle, keep the `root` pivot at `[0,0,0]` so the existing wield animation still
lines up, and UV-map onto the new texture from task 3.

Related: `resource_pack/animations/scythe.animation.json` holds one static pose
(`rotation: [0,0,-45]`, `position: [4,-4,0]`, `loop: true`) with no keyframes and no
first-person/third-person split. It will be wrong in one of the two views. Worth a pass
once the geometry is real, not before.

## 5. [DOCS] Correct the two wrong instructions in `TESTING_IPAD.md`

- `:13` — the "download the .mcaddon from GitHub" path. Point at a release, or at
  `build.sh` from task 2.
- `:53-58` and `:94` — the guide requires enabling **Holiday Creator Features** under
  Experiments, and the troubleshooting table blames a missing scythe on it. Verify that
  toggle still exists in current Bedrock; custom items at `format_version` 1.21.0 are
  stable and the experiment has been graduating out. If it's gone, this sends you hunting
  for a switch that isn't there — on exactly the symptom you already hit.

---

## Parked (real wants, not scoped yet)

Kept from the old TODO so the intent isn't lost — none of this is worth starting before
task 1 lands: Script API sweep attack / crop harvest / lifesteal (needs a `script` module
in the BP manifest), custom swing sound, gold / diamond / netherite tiers, the dragon-egg
+ dragon-head + blaze-rod recipe idea from `README.md:63`, extra locales.

`behavior_pack/loot_tables/items/scythe.json` is referenced by nothing. Delete it when
you next touch the BP, or wire it to something.
