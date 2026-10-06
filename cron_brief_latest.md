# Daily brief — Scythe Add-On (Bedrock) — 2026-10-06

## What I looked at

All 20 files in both packs — every JSON in `behavior_pack/` and `resource_pack/`, the
geometry and animation, the `.lang` files, the texture PNG (viewed it, not just listed
it), plus `README.md`, `TODO.md`, `TESTING_IPAD.md` and `.gitignore`. Not a web project,
so no browser check.

Last commit was 2026-06-10 — four months ago. The final commit added a PRIORITY section
to `TODO.md` saying the crafting recipe failed during iPad testing. Nothing happened
after that.

## What I found

**The recipe probably isn't the bug — the item is.** `behavior_pack/items/scythe.json:17-22`
declares a `minecraft:weapon` component whose `on_hurt_entity` fires `scythe:hurt_event`.
That event is defined nowhere: there's no `"events"` block in the file and nothing else
in either pack declares it. A custom item pointing at a non-existent event throws a
content error on load, and an item that fails to register takes its recipe output with it
— which looks exactly like "the recipe doesn't work." The component isn't earning its
keep anyway; the event is a no-op. Deleting it is the cleanest first move.

Second defect in the same file: there's no `minecraft:icon` component. The only icon
declaration is in `resource_pack/items/scythe.json:9-11`, which is the legacy RP item
format — and that file declares `format_version: "1.21.0"` while using the pre-1.16
`"category": "Equipment"` field, so it's mixing schemas. For a 1.21-format item the icon
belongs on the behavior side.

**There is no way to install this on the iPad it was meant for.** `TESTING_IPAD.md:13`
tells you to download `scythe_addon.mcaddon` from the repo. No such file exists, no
release has been cut, and `.gitignore:11` ignores `*.mcaddon` — so it can never be
committed. The documented primary install path is impossible, and there's no build
script to produce the file either. This is why the fix above can't be verified.

**The art is all placeholder, more so than the notes suggest.** `iron_scythe.png` is 119
bytes and renders as a single thin diagonal stroke — it reads as a stick. The geometry at
`scythe.geo.json:22-40` is a 2×8×2 cube sitting on a 1×8×1 cube: a lollipop, not a scythe.
The wield animation is one static pose with no keyframes and no first/third-person split.

**The old TODO had gone stale enough to mislead.** Section 7 still claimed the manifest
UUIDs were placeholders and that the BP dependency pointed at `c3d4e5f6-…`. Both were
fixed in commit 865dcd0 — the real dependency is `533f82e0-…` and it correctly matches
the RP header. Section 8 was left unchecked while its own body said "already added."

## What I'm proposing

Everything is ordered toward one goal: get this to load in-game once. The headline is the
item-definition fix (#1), then the `build.sh` that makes verifying it possible (#2) —
those two together are about 50 minutes and move the project from "untestable" to
"testable." The quick win is drawing a real 16×16 texture (#3), which is the smallest
thing that makes it stop looking broken. Then Blockbench geometry (#4) and the two wrong
instructions in the iPad guide (#5).

I also rewrote `TODO.md` from 280 lines and 13 sections down to five tasks plus a short
parked list. The old one was mostly aspiration, two sections were factually wrong, and
its sheer size is a plausible part of why this stalled. The genuine future wants —
Script API sweep attack, extra tiers, the dragon-egg recipe idea — are preserved at the
bottom, not deleted.

**Verdict: early scaffold, never confirmed working.** The skeleton is sound — manifests,
UUIDs, dependency link, texture atlas registration are all correct. But it's one JSON fix
and a twenty-line shell script away from being able to validate anything at all, and
that's the whole game right now.
