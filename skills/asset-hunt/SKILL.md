---
name: asset-hunt
description: Find and fetch high-quality free assets (3D models, characters, textures, skies, UI kits, icons, fonts, sound effects, music, Godot addons) for a game, with licences recorded. Use during planning to build the asset shortlist, during a build when a milestone needs a thing the player sees or hears, and whenever Gideon asks where to get assets or to make a game look or sound better.
argument-hint: search <what you need> | fetch (everything in PLAN.md) | <need>
---

# Asset hunt

`C:\dev\gamedev-notes\ASSETS.md` is the reference: the rule for what to import, the table
of what to use for what, the style families, the fetch recipes and the licence rules. Read
its first two sections now if they are not in context. `scripts/assets.py` does the work.

## Search mode (planning)

For each thing on screen or in the ear at full size, in the order the player meets them:

1. Decide import versus model with the rule: how many pixels tall, for how long, and is its
   shape game state. Write the number down.
2. Search the right sources for the art direction (stylised: Kenney, KayKit, Quaternius;
   photoreal: Poly Haven, ambientCG; both: fonts, icons, audio):
   ```powershell
   python C:\dev\gamedev-notes\scripts\assets.py search polyhaven models <term>
   python C:\dev\gamedev-notes\scripts\assets.py search ambientcg <term>
   python C:\dev\gamedev-notes\scripts\assets.py search kenney 3D --filter <term>
   python C:\dev\gamedev-notes\scripts\assets.py search kaykit
   python C:\dev\gamedev-notes\scripts\assets.py search polypizza <term> --license CC0
   python C:\dev\gamedev-notes\scripts\assets.py search freesound "<term>"
   python C:\dev\gamedev-notes\scripts\assets.py search fonts <term>
   python C:\dev\gamedev-notes\scripts\assets.py search opengameart <term> --type music
   ```
   Two minutes per subject. Record the misses in the plan; a miss shapes the design.
3. Pick one style family for characters and one for environment, and say how they will be
   unified (light, tonemap, roughness, rim, palette recolour).
4. Fonts: always one display family and one text family, two weights each, from Google
   Fonts. Music: check the Tallbeard loop bundle before generating. SFX: Kenney packs for
   UI and impacts, jsfxr or generated for anything that must answer game state.
5. Return the shortlist table: need, source, id, licence, fetch command, target folder,
   import settings. That table goes into `PLAN.md`.

## Fetch mode (building)

Run every fetch command in the plan's asset table from the game repo root. Each one writes
into `assets/<source>/...`, appends `assets/CREDITS.md`, and for large textures and skies
writes the `.import` with VRAM compression and a size limit. Then:

1. Drop `.gdignore` into any `Previews`, `Isometric`, `Source` or `Samples` folder the script
   did not already cover.
2. `godot --headless --path . --import *> build\import.log` and read the log for `ERROR`.
   A glTF that imports white has lost its `textures/` folder.
3. `ls -laS .godot\imported | head` after any import: it is the only place the real cost
   shows. A sky or a 4k texture that landed uncompressed is fixed in its `.import`.
4. Wire the asset in through the game's own material and light setup (imported materials
   forced to the game's roughness and tonemap), normalise scale, and film the scene it
   appears in. An asset that has not been seen in the game is not done.
5. Commit the assets and `CREDITS.md` together. Never commit a Quaternius QAL pack to a
   public repo.

## When a source misbehaves

The URL patterns in `assets.py` were verified on 2026-09-10. When one fails, fix the script
(it is shared by every game), test the fix, and `/record-lesson` with the new pattern. If a
key is missing the script says which line to add to `C:\dev\.env`; ask for that in the ship
report, not mid-build, and use a keyless source meanwhile.
