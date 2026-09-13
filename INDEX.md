# Gideon's game studio - the core (loaded in every session)

Gideon builds phone games with Claude Code on this Windows PC and plays them on a Samsung
Galaxy S26 Ultra (Android, 1080x2340, Adreno 840, Vulkan). Every game is meant to be kept,
improved and eventually put on Google Play. Claude has a shell, git, `gh`, Godot 4.7.2, the
Android toolchain, `adb` to the phone, `ffmpeg`, node and python - all on the **user** PATH,
which a session older than the install does not see, so resolve a "missing" tool by path
before believing it (`GODOT.md`). Nothing here is limited by what Claude can run. Several
sessions run at once on different games.

**The goal is not to satisfy one request. It is to make each game better than the last.**
That only works if this knowledge base is read at the start and written to as you go.

## The process, and the skill that runs each step

| Step | Skill | What happens |
|---|---|---|
| **0. Check** | `/framework-check` | Before a new game or a ship: `scripts\doctor.ps1` over this base, the template and every game repo, then act on what it fails. A resume reads `reports\LATEST.txt` (the weekly run) instead of re-running |
| 1. Understand | `/new-game <idea>` | Reads this base, expands the idea, picks the engine (Godot unless the game truly wants to be a web link) |
| 2. Research | `/game-plan` | Searches for the genre's loop, reference games, one new technique, and runs the asset scout |
| 3. Plan | `/game-plan` | Writes `PLAN.md`: loop, feel, first minute, content, systems, assets, tests, polish, milestones |
| **Gate** | | **Show Gideon the plan. This is the only question you ask.** He approves or edits it |
| 4. Scaffold | `/game-scaffold` | Copies the template, renames, creates the GitHub repo, secrets, CI, first green build |
| 5. Build | `/game-studio` | Milestone by milestone, sim first, tests alongside, assets in, polish pass |
| 6. Play | `/playtest` | Headless suites, filmed runs on the desk, then on the phone over adb. Judge feel, not just pass/fail |
| 7. Ship | `/ship` | CI green, APK on a Release, screenshot and changelog to Gideon, playtest notes filed |
| Always | `/record-lesson` | Write what you learned the moment you learn it (see below). The `lesson-filer` agent does the paperwork |
| Machinery | `/studio-admin` | Changing how the studio is managed: thresholds, schedule, skills, agents, models. Reads `ADMIN.md`, never the topic files |

Resuming an existing game: read its `CLAUDE.md`, `NOTES.md`, `PLAN.md` and
`playtests/<game>.md`, then continue from its milestone list. Do not re-plan a game that has
a plan.

## Standing rules

1. **Godot by default. Real 3D unless the game reads better flat.** Web only when the game
   genuinely wants to be a link.
2. **A pure simulation core with no renderer in it.** `src/sim/` never touches a Node, a
   Viewport, an input event or a real frame. This is what makes the golden test, the
   headless harness and every rewrite possible. **The rule excludes the renderer, not the
   disk: `src/sim` MAY use `FileAccess` and `DirAccess` under `user://`.** What it may not do
   is make the disk the only way to test a save - serialisation is a pure pair, state to
   `Dictionary` and back, asserted by a round-trip test that touches no file, and the file
   call is a thin wrapper over that pair which may live either side of the wall. Asserted by
   `test/test_sim_boundary.gd`, not by a comment in a header.
3. **The full stack from the first commit**: git, GitHub repo, CI, size guard, golden test,
   smoke test, build stamp, version, changelog, `CLAUDE.md`, `NOTES.md`, `PLAN.md`. There
   are no one-off games. `PLAN.md`'s milestone list is the official outline: one `- [ ]`
   line per milestone, ticked in the commit that finishes it, and each release gets a
   changelog entry in the player's terms. The studio dashboard reads both, so an unticked
   box for finished work and a version with no entry both show up as wrong. Every
   stop-and-report and every ship opens with the plan's own count from `scripts\progress.ps1`,
   so the outline is what he is shown rather than a summary of it.
4. **Use good free assets wherever the player reads something at full size** (type, UI,
   textures, sound, music, props on screen for a long time). Model in code what is judged on
   silhouette at thirty pixels, and anything whose shape IS game state. `ASSETS.md`.
5. **Polish is part of done.** `POLISH.md` is the ship gate, not a nice-to-have.
6. **Test-play before calling anything finished.** Suites prove logic. Filmed runs and the
   phone prove feel. A screenshot proves one state, never the absence of a bug.
7. **Measure, do not guess.** If a rule reads like a caution, measure the number and replace
   the caution. He will ask where a number came from.
8. **When a complaint survives a correct fix, stop tuning and start measuring.** Hide a
   layer, read a pixel, print the buffer.
9. **When he names a mechanism, build that mechanism.** Every mechanism he has proposed has
   been right. When he restates from scratch instead of refining, the model is wrong, not the
   tuning.
10. **One writer per phase, one source of truth per fact.** The picture and the score derive
    from the same state. A constant that must agree with another gets a test on the derived
    quantity.
11. **A construct that cannot fail is untested, not safe.** Verify every regression test by
    reintroducing the bug. Never re-record a golden without reading the diff.
12. **Delete the stand-in in the same commit as the real thing**, and that includes DESIGN, not
    only scaffolding and placeholder art. A replaced objective is the most expensive stand-in there
    is: two endings in one game is worse than either, because the player collects things that no
    longer do anything and the next session cannot tell which one is real (`CRAFT.md`).
13. **The framework is checked, not assumed.** `scripts\doctor.ps1` runs weekly on a
    scheduled task (`reports\LATEST.txt`), on every game commit through `check.ps1`, and in
    full through `/framework-check` before a new game or a ship. A rule that nothing looks
    at is the failure this whole base keeps paying for.
14. **Cheap work goes to cheap models.** Running the doctor and filing a lesson are Haiku
    agents (`doctor-runner`, `lesson-filer`); a digest is a Sonnet session. `MODELS.md` is
    the table.

## Where knowledge lives (read what the step needs, not everything)

| File | Read when |
|---|---|
| `PLAYER.md` | Before designing anything. What he plays first, what he complains about, how he wants to work |
| `CRAFT.md` | Before planning and during the polish pass. Design lessons by topic |
| `GODOT.md` | Before writing any Godot code. Engine traps, invariants, toolchain paths, export |
| `TESTING.md` | When writing tests or a harness, and before every playtest |
| `ASSETS.md` | During the asset scout. Sources, fetch recipes, style rules, credits |
| `POLISH.md` | Before shipping. The checklist of what "complete" means on a phone |
| `PLAY.md` | Only when a game is going to the store |
| `WEB.md` | Only for a web (three.js) game |
| `techniques/` | When the plan names a technique that was done before. `techniques/README.md` is the index |
| `playtests/<game>.md` | When resuming that game. His words, verbatim |
| `inbox/` | Unfolded lessons from other sessions. `/digest` folds them into the files above |

## Recording lessons without stepping on other sessions

Several sessions write to this repo at the same time, so **nobody edits the topic files
during a build.** Instead:

- **A lesson goes to `inbox/` the moment you learn it**: `/record-lesson` writes
  `inbox/YYYY-MM-DD-<game>-<slug>.md` (one lesson per file, unique name, no conflicts) and
  commits it with `scripts/kb.ps1 commit`. The test for whether it belongs: would this have
  saved time this morning?
- **His words go to `playtests/<game>.md`**, appended, dated, verbatim, the moment he says
  them.
- **Game-specific decisions go in the game's own `NOTES.md`**, never here.
- **`/digest` is the only thing that edits `CRAFT.md`, `GODOT.md`, `TESTING.md`, `ASSETS.md`
  and `POLISH.md`.** It runs at the start of every new game and whenever `inbox/` has more
  than ten files. It pulls first, folds each inbox lesson into the right section, deletes the
  inbox file, and pushes.
- **Never `git add -A` in this repo.** Stage by name. `scripts/kb.ps1` does pull, rebase,
  add-by-name, commit and push in one call and refuses a blanket add.

## Toolchain (details and traps in `GODOT.md`)

Godot 4.7.2 console binary: `%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe`
(scripts read it from `$env:GODOT` when set). JDK, Android SDK and the debug keystore are
under `C:\dev\toolchain\`. Signing keys under `C:\dev\keys\`, never in a repo. Godot finds the
SDK, JDK and keystore through editor settings, not environment variables. API keys for asset
sites live in `C:\dev\.env` (never committed). Template: `C:\dev\godot-template`. Notes:
`C:\dev\gamedev-notes`. Games: `C:\dev\<slug>`, GitHub `gideon6222/<slug>`.
