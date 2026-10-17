# Daily brief — Scythe-add-on_minecraft-mod (2026-10-17)

## What I looked at

All 23 tracked files. Both manifests, the item/recipe/loot-table JSON, the whole resource
pack including the attachable, geometry and animation, and all four markdown docs. I also
decoded `iron_scythe.png` and `pack_icon.png` byte-by-byte (zlib/struct, no Pillow
available) to actually look at the pixels rather than trust the filenames, and validated
every JSON file with `json.load` — all 12 parse clean. Not a web project, so no browser
check.

## What happened since 2026-10-06

Two of the three actionable tasks from the last review landed. `8644814` removed the
`minecraft:weapon` component that fired an undefined `scythe:hurt_event` and moved the icon
onto the behavior side — that was the genuine blocker on the item registering at all.
`2560df4` replaced the 119-byte diagonal line with real 8-colour pixel art.

Task 2 — `build.sh` — was skipped. That's the one that mattered for verification, and it is
why the other two fixes are still unconfirmed 11 days later. There is still no script of any
kind in the repo, `.gitignore:11` excludes `*.mcaddon`, and no release exists, so
`TESTING_IPAD.md:13`'s "download `scythe_addon.mcaddon` directly from the repo" remains an
instruction for a file that physically cannot be there. It goes back to #1.

## The new finding

The held 3D model will render near-invisible, and you'd have burned a whole iPad test run
discovering it. `attachables/scythe.json:11` sets the model's texture to
`textures/items/iron_scythe` — the 16×16 *item icon* — while `scythe.geo.json:22-40` box-UVs
its cubes onto regions of that icon that are mostly empty. I measured the alpha: the blade
cube's UV window (u 0–8, v 0–10) is 9 of 80 pixels opaque, 11%, because all the art lives in
columns 8–15. The handle cube's window is 50% opaque but samples the blade's steel pixels,
not the brown handle. Under `entity_alphatest` the transparent samples are discarded, so in
third person you get a thin steel sliver where the handle belongs and nothing at all where
the blade belongs.

My recommendation is to delete the attachable, the geometry and the animation outright.
`minecraft:hand_equipped: true` already makes Bedrock render the flat sprite held like a
vanilla tool, which is what most weapon add-ons ship, and the sprite now looks good. That
turns three files of broken scaffolding into zero and makes the project finished instead of
half-modelled. The alternative — a proper `textures/entity/scythe.png` UV-matched in
Blockbench — is a real afternoon, not an hour, and it's a bigger project than the one
weapon this add-on is scoped to.

The quick win fell out of the same pixel decode: the new texture has a 2-pixel break at the
blade/handle junction. Column 8 alpha for rows 0–9 reads `[255,255,255,0,0,255,255,255,255,255]`
— rows 3 and 4 are empty, so the blade floats above the rivet. Two pixels of `#363A3D` and
the icon stops looking unfinished in the hotbar.

## Also proposing

A chore task to clear three verified-dead things: `resource_pack/items/scythe.json` (declares
`format_version "1.21.0"` but uses the retired `description.category` field, and duplicates
an identifier the BP now owns — the last doer flagged it and deliberately left it as scope
creep, so I've made it explicit scope), the orphan loot table nothing references, and
`minecraft:display_name` hardcoding the literal `"Iron Scythe"` instead of the lang key, which
makes `en_US.lang` dead weight. And a docs task: five statements across `TESTING_IPAD.md` and
`README.md` are now false, including two that describe the texture as a grey silhouette — a
tester reading those would dismiss a real rendering bug as expected behaviour.

## Verdict

Two fixes from genuinely finished. The scope here is one weapon and that weapon is basically
built. Ship `build.sh`, delete the attachable chain, do one iPad run, and call it done. The
parked Script API ideas (sweep attack, lifesteal, crop harvest) are a different, larger
project — starting any of them before a first successful load would be the mistake.
