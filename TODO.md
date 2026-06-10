# Scythe Add-On — TODO List

Everything needed to make the Iron Scythe fully functional in Minecraft Bedrock Edition.
Check off items as they are completed.

---

## 1. Textures

- [x] **Create `iron_scythe.png` (16×16)**
  Draw a flat 2D inventory icon for the scythe. Saved to
  `resource_pack/textures/items/iron_scythe.png`.
  This is what players see in their hotbar and inventory.
  > **PLACEHOLDER** — auto-generated grey silhouette. Replace with proper pixel art or copy
  > `wooden_sword.png` from Minecraft's vanilla resource pack and recolor it for the final version.

- [x] **Register texture in `item_texture.json`**
  Already scaffolded at `resource_pack/textures/item_texture.json`.
  Verify the key `"iron_scythe"` maps to `"textures/items/iron_scythe"` — no file extension.

- [x] **Add `pack_icon.png` (256×256) to both packs**
  Each pack needs its own icon shown in Minecraft's pack selection screen.
  Place one at `behavior_pack/pack_icon.png` and one at `resource_pack/pack_icon.png`.
  > **PLACEHOLDER** — auto-generated dark background with rough scythe silhouette.
  > Replace with proper artwork before publishing.

---

## 2. 3D Model (Geometry)

- [ ] **Design scythe geometry in Blockbench**
  Open `resource_pack/models/entity/scythe.geo.json` in [Blockbench](https://www.blockbench.net/).
  Model it as a "Bedrock Entity" model. The blade should curve away from the handle.
  Keep the pivot point at the hand grip origin so it holds correctly in-hand.

- [ ] **UV-map the model to the texture**
  Inside Blockbench, paint the UV layout onto the scythe texture (or a dedicated
  `resource_pack/textures/models/scythe.png` if using a separate model texture).
  Export the final `.geo.json` back to `resource_pack/models/entity/scythe.geo.json`.

- [ ] **Verify geometry identifier matches attachable**
  The `"identifier"` field in `scythe.geo.json` must match the `"geometry.default"`
  value inside `resource_pack/attachables/scythe.json`. Currently both use `"geometry.scythe"`.

---

## 3. Animations

- [ ] **Design wield animation**
  In Blockbench (or manually in JSON), create `animation.scythe.wield` so the scythe
  rotates and positions correctly in the player's hand (first-person and third-person).
  Saved to `resource_pack/animations/scythe.animation.json`.

- [ ] **Design swing/attack animation**
  Add `animation.scythe.attack` — a sweeping arc motion triggered when the player attacks.
  This is a short one-shot animation (loop: false). Reference: vanilla sword uses
  `animation.player.attack` as a baseline.

- [ ] **Wire animations into the attachable**
  In `resource_pack/attachables/scythe.json`, add both animations under `"animations"`
  and list them under `"scripts" > "animate"` with a condition for attack:
  ```json
  "animate": [
    "wield",
    { "attack": "variable.attack_time > 0" }
  ]
  ```

---

## 4. Attachable (In-Hand Rendering)

- [ ] **Confirm render controller**
  `resource_pack/attachables/scythe.json` currently references
  `"controller.render.item_default"`. This works for basic items. If the model has
  multiple materials or textures, create a custom render controller in
  `resource_pack/render_controllers/scythe.render_controllers.json`.

- [ ] **Test first-person vs third-person offsets**
  The wield animation may need separate bone offsets for first-person (`"first_person"`)
  and third-person (`"third_person"`) using Molang variables
  `variable.is_first_person` / `!variable.is_first_person`.

---

## 5. Item Definition (Behavior Pack)

- [ ] **Verify `format_version` matches your Minecraft target**
  `behavior_pack/items/scythe.json` uses `"1.21.0"`. Confirm this matches the
  `min_engine_version` in `behavior_pack/manifest.json`. Update both if targeting a
  different release.

- [ ] **Tune attack damage**
  Currently set to `8` (same as a diamond sword). Adjust the `"minecraft:damage"` component
  value to balance the scythe vs other weapons.

- [ ] **Tune durability**
  Currently `500` (between iron sword 250 and diamond sword 1561). Adjust
  `"minecraft:durability" > "max_durability"` to taste.

- [ ] **Add attack speed component (if using Script API)**
  Vanilla items in Bedrock do not natively support custom attack speed. If you want
  a slower, harder-hitting scythe, this must be enforced via Script API cooldown logic.

- [ ] **Add `minecraft:cooldown` component (optional)**
  Give the scythe a wind-up time between swings:
  ```json
  "minecraft:cooldown": {
    "category": "attack",
    "duration": 0.8
  }
  ```

- [ ] **Add food / interact components if needed**
  If the scythe will harvest crops or have secondary interactions, add
  `"minecraft:use_duration"` and handle the event via Script API.

---

## 6. Crafting Recipe

- [ ] **Verify recipe pattern is correct in-game**
  Load the world, open a crafting table, and confirm the Iron Scythe appears
  with the `I I / S I / S` pattern defined in
  `behavior_pack/recipes/scythe_crafting.json`.

- [ ] **Add alternate recipes for other tiers (optional)**
  Copy `scythe_crafting.json` for gold, diamond, and netherite scythes when
  those item definitions are added.

---

## 7. Manifest UUIDs

- [ ] **Generate unique UUIDs for production**
  The current UUIDs in both `manifest.json` files are placeholder values.
  Before publishing, replace every UUID with freshly generated ones from
  [uuidgenerator.net](https://www.uuidgenerator.net/) or via
  `python3 -c "import uuid; print(uuid.uuid4())"`.
  Each UUID must be globally unique — reusing UUIDs causes pack conflicts.

- [ ] **Confirm BP → RP dependency link**
  `behavior_pack/manifest.json > "dependencies"` must list the RP's header UUID.
  Currently set to `"c3d4e5f6-..."` which matches `resource_pack/manifest.json > "header" > "uuid"`.
  Keep these in sync whenever you regenerate UUIDs.

---

## 8. Localization / Text

- [ ] **Add display name to `en_US.lang`**
  Already added: `item.scythe:iron_scythe.name=Iron Scythe`.
  Extend with additional tiers as they are created, e.g. `item.scythe:diamond_scythe.name=Diamond Scythe`.

- [ ] **Add additional language files (optional)**
  Copy `en_US.lang` to `es_ES.lang`, `fr_FR.lang`, etc. for localization.
  Add each locale code to `resource_pack/texts/languages.json`.

---

## 9. Script API (Custom Behavior — Optional but Recommended)

These require enabling `"@minecraft/server"` module in the BP manifest.

- [ ] **Enable Script API in `behavior_pack/manifest.json`**
  Add a script module and dependency:
  ```json
  {
    "type": "script",
    "language": "javascript",
    "uuid": "<new-uuid>",
    "version": [1, 0, 0],
    "entry": "scripts/main.js"
  }
  ```
  And in dependencies:
  ```json
  { "module_name": "@minecraft/server", "version": "1.12.0" }
  ```

- [ ] **Create `behavior_pack/scripts/main.js`**
  Entry point for all scripted scythe behavior.

- [ ] **Implement area sweep attack**
  On `entityHit` event, detect all entities within a ~3 block arc in front of the
  player and apply damage to each. This replicates the classic "sweep attack" from
  Java Edition scythes.

- [ ] **Implement crop harvesting (optional)**
  On `itemUseOn` event, if the target block is a fully-grown crop
  (`minecraft:wheat`, `minecraft:carrots`, etc.), break it and drop its drops
  without needing to break it manually — one swipe harvests a row.

- [ ] **Implement lifesteal on kill (optional)**
  On `entityDie` event (when killed by a player holding the scythe), restore
  a percentage of the player's health (e.g. 2 HP per kill).

- [ ] **Implement particle and sound effects on swing**
  On attack, spawn a `minecraft:sweep_attack` particle and play a custom or
  vanilla swoosh sound using `world.playSound()`.

---

## 10. Sounds (Optional)

- [ ] **Add custom swing sound**
  Place an `.ogg` or `.fsb` audio file at `resource_pack/sounds/item/scythe_swing.ogg`.
  Register it in `resource_pack/sounds/sound_definitions.json`:
  ```json
  "item.scythe.swing": {
    "sounds": ["sounds/item/scythe_swing"],
    "pitch": [0.9, 1.1],
    "volume": 1.0
  }
  ```

- [ ] **Play sound via Script API on attack**
  Call `world.playSound("item.scythe.swing", location)` inside the entityHit handler.

---

## 11. Additional Scythe Tiers (Optional)

For each tier, repeat the item, recipe, and texture steps above:

- [ ] **Gold Scythe** — lower durability (32), higher enchantability (22), 7 damage
- [ ] **Diamond Scythe** — 1200 durability, 9 damage, repaired with diamonds
- [ ] **Netherite Scythe** — knockback resistance, fire immune, 10 damage, 2031 durability

---

## 12. Testing Checklist

- [ ] Install both packs in a test world (Creative mode)
- [ ] Verify scythe appears in inventory / creative search
- [ ] Verify crafting recipe works in survival
- [ ] Verify scythe holds correctly in first-person and third-person
- [ ] Verify attack animation plays on swing
- [ ] Verify damage value is correct on mobs
- [ ] Verify durability decreases on use
- [ ] Verify enchanting table accepts the scythe
- [ ] Verify repair works in anvil with iron ingots
- [ ] Test on Android / iOS / Windows (packs behave differently per platform)
- [ ] Test on Minecraft Bedrock 1.21.x (the minimum engine version declared)

---

## 13. Packaging & Distribution

- [ ] **Bundle as `.mcaddon`**
  Zip both `behavior_pack/` and `resource_pack/` folders together and rename
  the archive to `scythe_addon.mcaddon`. Double-clicking imports it on any device.

- [ ] **Bundle individual `.mcpack` files**
  Zip each pack separately as `scythe_BP.mcpack` and `scythe_RP.mcpack` for
  separate distribution or for marketplace submission format.

- [ ] **Add build script (optional)**
  Create a `Makefile` or `build.sh` that automates the zip/rename step so you
  don't do it manually every release.

- [ ] **Tag a GitHub release**
  Upload the `.mcaddon` as a release asset on GitHub so users can download it directly.
