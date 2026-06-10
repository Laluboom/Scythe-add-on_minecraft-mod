# Testing the Scythe Add-On on iPad (Minecraft Bedrock)

## Requirements
- iPad with Minecraft installed (App Store version)
- A way to transfer the `.mcaddon` file to the iPad (see options below)
- Minecraft version 1.21.0 or higher

---

## Step 1 — Get the `.mcaddon` File

Either:
- **Download from GitHub** — go to the repo and download `scythe_addon.mcaddon` directly, or
- **Build it locally** and transfer (see below)

---

## Step 2 — Transfer to iPad

### Option A — AirDrop (easiest if you have a Mac)
1. On your Mac, right-click `scythe_addon.mcaddon` → Share → AirDrop
2. Select your iPad
3. On iPad, tap **Accept**
4. iOS will ask "Open with..." → choose **Minecraft**
5. Minecraft opens and imports both packs automatically

### Option B — iCloud Drive
1. Upload `scythe_addon.mcaddon` to iCloud Drive from any device
2. On iPad, open the **Files** app → iCloud Drive → find the file
3. Tap and hold the file → **Share** → **Copy to Minecraft**
4. Minecraft imports it automatically

### Option C — Google Drive / Dropbox
1. Upload the file to Google Drive or Dropbox
2. Open the Drive/Dropbox app on iPad
3. Tap the file → tap the **three dots** → **Open in** → **Minecraft**

### Option D — Cable (via Finder on Mac)
1. Connect iPad to Mac via USB
2. Open **Finder** → select your iPad → **Files** tab
3. Drag `scythe_addon.mcaddon` into the Minecraft section
4. Disconnect, open Minecraft — the pack should be imported

---

## Step 3 — Activate the Packs in a World

1. Open Minecraft → **Play** → **Create New World** (or edit an existing one)
2. Scroll down to **Add-Ons** (or **Resource Packs** / **Behavior Packs**)
3. Under **Behavior Packs** → tap **My Packs** → activate **Scythe Add-On (BP)**
4. Under **Resource Packs** → tap **My Packs** → activate **Scythe Add-On (RP)**

### Enable Experiments (required)
Still in world settings, scroll to **Experiments** and toggle on:
- **Holiday Creator Features** ← required for custom items to work

> Without this, the scythe item will not appear in-game.

5. Tap **Create** / **Play**

---

## Step 4 — Test In-Game

### Test the crafting recipe
1. Switch to **Survival mode** (or use a crafting table in Creative)
2. Open a **Crafting Table**
3. Place items in this pattern:
   ```
   [ ]    [Iron] [Iron]
   [ ]    [Stick][Iron]
   [Stick][ ]    [ ]
   ```
4. The **Iron Scythe** should appear in the output slot

### Test in Creative
1. Open inventory → search **"scythe"** or **"iron scythe"**
2. It should appear under the Equipment tab

### What to verify
- [ ] Scythe appears in creative search
- [ ] Crafting recipe works in survival
- [ ] Scythe shows in hotbar when held
- [ ] Attacking a mob deals damage
- [ ] Durability bar decreases on use

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Packs not showing after import | Restart Minecraft and check My Packs |
| Scythe not in creative search | Make sure Holiday Creator Features is enabled |
| Crafting recipe not working | Confirm both BP and RP are active in the world |
| "Experimental Gameplay" warning on world load | Normal — tap **Play** to continue |
| Broken/missing texture on the scythe | Expected for now — placeholder texture is a grey silhouette |

---

## Notes
- The scythe texture is currently a placeholder — it will look like a grey shape
- No swing animation yet — that comes in a later update
- Pack icons may appear as a rough sketch — also placeholder
