---
name: digest
description: Fold the lessons waiting in C:\dev\gamedev-notes\inbox into the topic files (CRAFT, GODOT, TESTING, ASSETS, POLISH, PLAYER, WEB, techniques) so every future session gets them. Use at the start of a new game, when the inbox holds more than ten files, or when Gideon asks to consolidate, clean up or review the knowledge base.
argument-hint: [--dry-run]
---

# Digest the inbox

This is the only skill that edits the topic files. One session at a time runs it; it pulls
first and pushes at the end so the window is short.

1. `powershell C:\dev\gamedev-notes\scripts\kb.ps1 pull`, then list `inbox\*.md` (ignore
   `README.md`). Nothing there: stop.
2. Read every inbox file. Group duplicates: two sessions often learn the same thing.
3. For each lesson, open the target file and section named in "Belongs in" (or the right
   one if that was wrong) and:
   - **Add one line** in the file's style: bold-free, one rule per line, a measured number
     marked (M), the game named only when it matters.
   - **Replace** the line quoted under "Replaces or contradicts" rather than adding beside
     it. A corrected rule and its old version must not both survive.
   - **Move** a long write-up to `techniques/<game>-<topic>.md` and leave one line behind.
   - If it changes what he wants (a new complaint, a preference), edit `PLAYER.md` and
     check `playtests/` for the evidence line.
   - If it is a new URL pattern or key, edit `ASSETS.md` and `scripts/assets.py` together.
4. Keep each topic file under about 30 KB. If a section has grown past a screen, condense:
   merge lines that say one thing, drop a caution a measurement replaced, move detail to
   `techniques/`.
5. Re-read `INDEX.md`. Only change it when a standing rule or a file's purpose changed.
6. Delete each folded inbox file with `git rm`, then commit everything by name:
   `kb.ps1 commit -Files CRAFT.md,GODOT.md,inbox\<a>.md,... -Message "Digest: <n> lessons (<topics>)"`.
   A push rejection means another digest ran; pull, re-apply, push.
7. Report the lines that changed, in one message, so he can veto.

`--dry-run`: do steps 1 to 3 as a proposed diff in chat and change nothing.

Every three or four digests, also read `playtests/` since the last digest date and check
that `PLAYER.md` still describes him: the recurring complaints, in his words, with the
newest evidence.
