---
name: digest
description: Fold the lessons waiting in C:\dev\gamedev-notes\inbox into the topic files (CRAFT, GODOT, TESTING, ASSETS, POLISH, PLAYER, WEB, techniques) so every future session gets them. Use at the start of a new game, when the inbox holds more than ten files, or when Gideon asks to consolidate, clean up or review the knowledge base.
argument-hint: [--dry-run]
---

# Digest the inbox

This is the only skill that edits the topic files. One session at a time runs it, enforced
by the lease in step 1 rather than by hope; it pulls first and pushes at the end so the
window is short.

1. **Take the lease before you read anything.**
   `powershell C:\dev\gamedev-notes\scripts\kb.ps1 lease -Owner digest`. Two digests
   running at once overwrite each other's folds. It refuses while another session's lease is
   under forty-five minutes old and prints who holds it and when it expires; if it refuses,
   stop and say so. Then `kb.ps1 pull`, and list `inbox\*.md` (ignore `README.md`).
   Nothing there: release the lease and stop.
2. Read every inbox file. Group duplicates: two sessions often learn the same thing.
3. **Check the target before folding.** Search the file named in "Belongs in" for the rule
   itself, not for the lesson's title: the Grep tool with a distinctive phrase from the
   rule, or `Select-String -Path GODOT.md -Pattern '<phrase>'`. Then one of three things:
   - **The file already says it.** Fold nothing, `git rm` the inbox file, and list it in the
     report as a restatement. A lesson that repeats a line already in the base is a finding
     about the doc's wording, not a new rule.
   - **The file says the opposite.** Replace that line. Never add beside it.
   - **No hit.** It is new. Add it.
   Do this even when "Replaces or contradicts" says "nothing" or is missing: most lesson
   files carry no such field, and that gap is how two contradicting rules reached the base.
   **A corrected rule and its old version must not both survive.**
4. For each lesson, open the target file and section named in "Belongs in" (or the right
   one if that was wrong) and:
   - **Add one line** in the file's style: bold-free, one rule per line, a measured number
     marked (M), the game named only when it matters.
   - **Replace** the line found by the grep in step 3 rather than adding beside it.
   - **Move** a long write-up to `techniques/<game>-<topic>.md`, leave one line behind, and
     add its row to `techniques/README.md` in the same commit.
   - If it changes what he wants (a new complaint, a preference), edit `PLAYER.md` and
     check `playtests/` for the evidence line.
   - If it is a new URL pattern or key, edit `ASSETS.md` and `scripts/assets.py` together.
5. Keep each topic file under about 30 KB. If a section has grown past a screen, condense:
   merge lines that say one thing, drop a caution a measurement replaced, move detail to
   `techniques/`.
6. Re-read `INDEX.md`. Only change it when a standing rule or a file's purpose changed.
7. Delete each folded inbox file (`git rm`, or just delete it), then commit everything by
   name in one call, edits and deletions together:
   `kb.ps1 commit -Files CRAFT.md,GODOT.md,inbox\<a>.md,... -Message "Digest: <n> lessons (<topics>)"`.
   `kb.ps1` treats a named file that is tracked but gone from disk as a deletion. The commit
   message must contain the word `Digest`; the doctor's digest-age check greps for it.
   A push rejection means another digest ran; pull, re-apply, push.
8. **Release the lease the moment the push lands:**
   `powershell C:\dev\gamedev-notes\scripts\kb.ps1 release -Owner digest`.
9. Report the lines that changed, in one message, so he can veto. Include the restatements
   from step 3 and the contradictions you resolved, naming the line you deleted.

**Model:** this is editorial work with a written procedure. Sonnet is enough; start the
session with `claude --model sonnet` or say `/model sonnet` before step 1.

**Release the lease on the way out of any failure too** - a conflict you cannot resolve, a
red gate, his veto, a lesson you decided not to fold. A lease left behind by a stopped
session blocks every other digest for forty-five minutes.

`--dry-run`: pull, then do steps 2 and 3 as a proposed diff in chat and change nothing. Do
not take the lease for a dry run; it reads and writes nothing.

Every three or four digests, also read `playtests/` since the last digest date and check
that `PLAYER.md` still describes him: the recurring complaints, in his words, with the
newest evidence.
