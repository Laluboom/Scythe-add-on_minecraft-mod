# Daily brief — Scythe-add-on_minecraft-mod (2026-11-08)

## What I looked at

All 24 tracked files: both manifests, the item/recipe/loot-table JSON, the entire resource
pack including the attachable, geometry and animation, `build.sh`, and all four markdown
docs. I re-decoded `iron_scythe.png` byte-by-byte (zlib/struct, no Pillow here) to measure
alpha per UV window rather than trust the last review's numbers, re-validated all 12 JSON
files with `json.load` — all parse clean — and checked for the `zip` binary. Not a web
project, so no browser check.

## What happened since 2026-10-17, and the problem with it

`3a68778` added `build.sh`. That was task 1, described in the last two reviews as "the gate."
It does not work.

`build.sh:7` is `zip -r scythe_addon.mcaddon behavior_pack resource_pack -x '*.DS_Store'`.
There is no `zip` on this machine — `which zip` exits 1, and `shutil.which()` returns `None`
for both `zip` and `7z`. With `set -euo pipefail` on line 2, the script dies on that line.
The commit message for `3a68778` says plainly that the author never executed it ("`zip`/`chmod`
require approval that isn't going through in this session"), fell back to reading the script,
and shipped. So the gate has now been nominally closed and actually open for a full month,
across three reviews, and the item fixes from 2026-10-06 remain unverified in a real client.

The fix is one line. Python 3.14 is installed and is already how every asset in this repo has
been checked:

```sh
python3 -m zipfile -c scythe_addon.mcaddon behavior_pack resource_pack
```

Same archive shape — both pack folders at the root, which is the bit that matters, since
nesting them under a parent is the classic reason an iPad import silently does nothing — and
zero install dependencies. It loses the `.DS_Store` exclusion, which costs nothing on Linux.
That is both the most valuable and the smallest item on the list, so it is #1 and the quick
win. The task is not just "edit the line" — it is "edit the line and run it."

## The new finding on the 3D model

The last review's measurement holds: `attachables/scythe.json:11` points the held model's
texture at the 16×16 *item icon*, and the blade cube's box-UV window (u 0–8, v 0–10) is 9 of
80 pixels opaque — 11% — because the art lives in columns 6–15. Under `entity_alphatest` the
held scythe is a sliver.

What I'd add is a second, independent reason to delete rather than repair.
`scythe.geo.json:22-40` is two stacked boxes: a 1×8×1 handle from y 0→8 with a 2×8×2 cube
sitting directly on top of it, y 8→16. That is a pole with a fat end. No curve, no
cross-piece, nothing scythe-shaped. Fixing the UVs would get you a correctly-textured pole.
Deleting `attachables/`, `models/entity/` and `animations/` and leaning on
`minecraft:hand_equipped: true` (`behavior_pack/items/scythe.json:13`) renders the flat
sprite held like a vanilla tool — what most Bedrock weapon add-ons ship, and the sprite is
good now. Three files of broken scaffolding become zero.

## The icon break is worse than "a 2-px gap"

I'd stated it as a gap last time; measuring the connectivity, the blade is fully detached.
Column 8 alpha for rows 0–9 is `[255,255,255,0,0,255,255,255,255,255]`, and the blade mass
(rows 0–5) shares no edge at all with the handle+rivet mass (rows 5–15) — nearest blade pixel
to the rivet at (5,8) is (2,8), three rows up. Two pixels of `#363A3D` at (3,8) and (4,8)
joins them.

## Also proposing

A docs task, because `TESTING_IPAD.md` is the script for the test run task 1 finally enables
and five of its statements are false — the "download the `.mcaddon` from GitHub" path for a
gitignored file with no release behind it, two lines calling the texture a grey silhouette
(which would make a tester dismiss the real rendering bug as expected), and the Holiday
Creator Features demand that the stable `menu_category` schema shouldn't need. Plus the
carried-over chore to delete three verified-dead things: the duplicate RP item file, the
orphan loot table, and the hardcoded `minecraft:display_name` that makes `en_US.lang` unread.

## Verdict

Three small fixes from genuinely finished, but stalled on the same step for a month. The
scope here is one weapon and that weapon is correctly defined. Fix the one line in
`build.sh`, actually run it, delete the attachable chain, close the two pixels, do one iPad
load, and this is done. The parked Script API ideas — sweep attack, lifesteal, crop harvest —
are a different and larger project; starting any of them before a first successful load would
be the mistake, and it would be the third month of this repo never having run.
