# Scythe Add-On — TODO

Ranked. Best first. Reviewed 2026-11-08.

**Status: still never confirmed working in-game — and the thing that was supposed to
unblock that doesn't run.** `build.sh` landed on 2026-10-17 (`3a68778`), but it calls `zip`,
and `zip` is not installed on this machine (`which zip` → exit 1; `shutil.which('zip')` and
`shutil.which('7z')` both `None`). The commit message for `3a68778` says outright that the
author never executed it. So the gate from the last two reviews is still closed, now for a
different and much cheaper-to-fix reason.

Everything below is still ordered to get to one successful load on the iPad.

---

## 1. `[DONE 2026-11-08]` Make `build.sh` actually run — drop the `zip` dependency

`build.sh:7` is `zip -r scythe_addon.mcaddon behavior_pack resource_pack -x '*.DS_Store'`.
There is no `zip` binary here, and with `set -euo pipefail` on line 2 the script dies on
that line with `zip: command not found`. Nothing has ever been built.

Python 3.14 **is** present and is already how every asset in this repo has been verified.
Swap line 7 for:

```sh
python3 -m zipfile -c scythe_addon.mcaddon behavior_pack resource_pack
```

That stores both folders at the archive root — which is the requirement, nesting them under
a parent is the usual reason an iPad import silently does nothing — and needs nothing
installed. (It loses the `-x '*.DS_Store'` exclusion; on Linux there are none, and if you
ever care, a six-line inline `zipfile.ZipFile` walk gives it back.)

Then **run it** and confirm `scythe_addon.mcaddon` appears. This is the smallest change on
the list and it is the one that unblocks every other item.

## 2. [BUG] Delete the held-3D-model chain — it renders near-invisible *and* isn't scythe-shaped

Two independent reasons, both measured:

**The UVs sample empty texture.** `resource_pack/attachables/scythe.json:11` points the
model's `default` texture at `textures/items/iron_scythe` — the 16×16 *item icon* — and
`scythe.geo.json:22-40` box-UVs its cubes onto regions of that icon that are mostly blank:

- blade cube (`origin [-1,8,-1]`, `size [2,8,2]`, `uv [0,0]`) samples u 0–8, v 0–10.
  **9 of 80 pixels are opaque (11%).** The art lives in columns 6–15.
- handle cube (`size [1,8,1]`, `uv [8,0]`) samples u 8–12, v 0–9 — 18/36 opaque, but those
  are the *steel blade* pixels, not the brown handle.

Under `entity_alphatest` (line 7) transparent samples are discarded, so in third person you
get a thin steel sliver where the handle belongs and nothing where the blade belongs.

**The geometry isn't a scythe.** `scythe.geo.json` is two stacked boxes: a 1×8×1 handle
(y 0→8) with a 2×8×2 blade (y 8→16) directly above it. That is a pole with a fat top. There
is no curve, no cross-piece, nothing scythe-like. Even with a perfect texture it would be
wrong.

**Do this (~30 min):** delete `resource_pack/attachables/scythe.json`,
`resource_pack/models/entity/scythe.geo.json` and
`resource_pack/animations/scythe.animation.json`. `minecraft:hand_equipped: true`
(`behavior_pack/items/scythe.json:13`) then renders the flat sprite held like a vanilla
tool — what most Bedrock weapon add-ons ship, and it looks fine now that the real texture
exists. Three files of broken scaffolding become zero and the project is *finished* rather
than *half-modelled*.

The alternative — a dedicated `textures/entity/scythe.png` UV-matched to a real Blockbench
model — is an afternoon, not an hour, and a bigger project than the one weapon this add-on
is scoped to.

Side note that deletion also solves: `animations/scythe.animation.json:7-11` is a single
static pose (`rotation [0,0,-45]`, `position [4,-4,0]`, `loop: true`) with no keyframes and
no first/third-person split, so it would be wrong in one of the two views regardless.

## 3. [BUG] The blade in the icon is completely detached from the handle

`resource_pack/textures/items/iron_scythe.png` is real pixel art (64 of 256 pixels opaque),
but the two halves never touch. Decoded alpha map:

```
 0 ........#####...   blade
 1 ........######..
 2 ........#######.
 3 ..........######
 4 ............####
 5 .......##...####   rivet (cols 7-8) + blade tail
 6 ......###.......   handle starts
...
15 ......###.......
```

Column 8 alpha for rows 0–9 is `[255,255,255,0,0,255,255,255,255,255]` — rows 3 and 4 are
empty. The blade mass (rows 0–5) shares no edge with the handle+rivet mass (rows 5–15): the
nearest blade pixel to the rivet at (5,8) is (2,8), three rows up. In the hotbar the blade
floats.

Fill `(3,8)` and `(4,8)` with the blade's dark outline tone `#363A3D` — already used at
`(2,8)` — or extend the handle's light-brown column up two rows. ~15 min, visible
immediately, and it is the last thing making the icon look unfinished.

## 4. [DOCS] Five statements in the docs are false, and a tester follows them

~20 min, and it matters because these are the instructions for the test run task 1 enables:

- `TESTING_IPAD.md:13` — "download `scythe_addon.mcaddon` directly" from the repo. `.gitignore:11`
  excludes `*.mcaddon` and `gh release list` shows nothing, so that file cannot exist in-tree.
  Point at `build.sh` instead, or cut an actual release and attach the artifact.
- `TESTING_IPAD.md:97` and `:102` — both describe the texture as a grey silhouette / grey
  shape. Untrue since `2560df4`. **Delete these lines** — a tester reading them will dismiss
  the real rendering bug in task 2 as expected behaviour.
- `TESTING_IPAD.md:53-58` and `:94` — demands **Holiday Creator Features** under Experiments
  and blames a missing scythe on it. The item uses `menu_category`
  (`behavior_pack/items/scythe.json:6-9`), the stable post-1.20.60 schema, which should not
  need the experiment. Verify against the client during the task-1 test run, then correct or
  drop it. As written it sends you hunting a toggle that may not exist.
- `README.md:59` — `- [ ] Add iron_scythe.png texture (16×16)` is done. Tick or remove it.
  While there, `README.md:57-64`'s TODO block now duplicates this file; consider replacing it
  with a pointer to `TODO.md`.

## 5. [CHORE] Clear the three pieces of dead weight

~15 min total, all re-verified dead by grep this run:

- `resource_pack/items/scythe.json` — declares `format_version "1.21.0"` but uses
  `description.category: "Equipment"` (line 6), the field `menu_category` replaced. It only
  duplicates the identifier and icon that `behavior_pack/items/scythe.json:5,17-19` now owns.
  **Delete it.** (The 2026-10-06 doer left it deliberately, calling removal scope creep —
  this is that scope, stated explicitly.)
- `behavior_pack/loot_tables/items/scythe.json` — nothing in either pack references it; the
  only other hit for "loot_table" in the repo is `README.md:30`, a directory listing. Delete,
  or wire it to a structure/mob drop if the intent was for the scythe to be findable.
- `resource_pack/texts/en_US.lang:1` defines `item.scythe:iron_scythe.name=Iron Scythe`, but
  `behavior_pack/items/scythe.json:38-40` hardcodes the literal string in
  `minecraft:display_name.value`, so the lang file is never read. Cleanest fix: **delete the
  `minecraft:display_name` component entirely** — Bedrock then resolves the name from
  `item.<identifier>.name` automatically. (Setting `value` to the key also works.) Costs
  nothing now; it is the difference between "add a locale" being a one-file change and a
  refactor.

---

## Parked (real wants, not scoped yet)

- Both pack icons are byte-identical (`md5 60a910e7077915701565e6275fd27e9c`) and are a flat
  three-colour dark-blue blob, so BP and RP are indistinguishable in the pack list. Cosmetic.
- Script API work — sweep attack, crop harvest, lifesteal. Needs a `script` module in the BP
  manifest and a `@minecraft/server` dependency. Don't start before task 1 lands and one real
  load succeeds.
- Gold / diamond / netherite tiers; custom swing sound; extra locales (see task 5's lang fix).
- The dragon-egg + dragon-head + blaze-rod recipe idea from `README.md:63`.
