# Audit fixes: what is done, what is not

Companion to `AUDIT-2026-09-11.md`. Paused 2026-09-12 at Gideon's request.

## Where the work lives

Nothing is pushed and nothing is merged. The two shared repos were NOT branched in
place, because `C:\dev\gamedev-notes` is one working tree shared by every running
session and `git checkout -b` there would have yanked them all onto the branch.
Instead the work sits in two separate git worktrees:

| worktree | branch | parent repo |
|---|---|---|
| `C:\dev\gamedev-notes-audit` | `framework-audit-fixes` | `C:\dev\gamedev-notes` |
| `C:\dev\godot-template-audit` | `framework-audit-fixes` | `C:\dev\godot-template` |

`main` in both is untouched. Review with
`git -C C:\dev\gamedev-notes log main..framework-audit-fixes -p`.
When done, `git worktree remove` each one.

## Done and committed to the game repos (main, local, unpushed)

| repo | commit | what |
|---|---|---|
| stillwater | `6ab35f3` | `check.ps1` can see Godot errors for the first time since scaffold |
| stillwater | `cbbd648` | `.gitignore` build negation fixed, 38 loose PNGs now ignored |
| gravewell | `76310e5` | `shot.gd` seconds/state parse |
| gravewell | `ad7d2e6` | `device.ps1` Native wrapper, now at parity with the template |
| gravewell | `34f13d0` | `version/code` asserted, bumped 1 to 17 |
| wildform | `d7363f8` | `shot.gd` seconds/state parse |
| wildform | `cc0363a` | `version/code` asserted, bumped 1 to 7 |
| candle-gift | `e119762` | export guards, `build/.gdignore`, `shot.gd`, live exit code in `check.sh`, version test |
| wrecking-crew | `6db325d` | export guards, `build/.gdignore`, `shot.gd` |

Nothing touched a file a live session had dirty. Every commit used an explicit
pathspec so it could not sweep up another session's staged work.

## Done on the branches

`godot-template-audit` (`2601deb`): glob test discovery with an empty-glob failure,
an assertion-count floor in both runners and in the harness, `test_version.gd`,
`test_sim_boundary.gd` (standing rule 2 as a real gate), `test_controls.gd` (a real
`InputEventScreenDrag` through the handler), `shot.gd` state argument, `movie.ps1`
log unwrap, `check_size.gd` stale-APK refusal, `rects.gd` generalised.

`godot-template-audit` (uncommitted): `src/sim/save.gd` - the save as a pure
`Sim` <-> `Dictionary` pair, total or false - plus `to_dict`/`apply` on `SimRng` for the
stream position, and `test/test_save.gd`, which round-trips a played run, proves it then
ADVANCES identically, and opens no file. That is the half of INDEX.md rule 2 the template
could not enforce: it had no save module at all, and `Sim.state()` is a lossy HUD snapshot
with no inverse. NOT RUN - see point 2 below.

`gamedev-notes-audit` (`8dfaa4a`): `kb.ps1` pathspec commit plus a 30-minute lease,
`new-game.ps1` web stub and named-role ports, `install.ps1` safety fixes,
`settings.merge.json` hook honesty via `setup/session-start.ps1`, `assets.py`
weights and licence guard, `agents/` tool and fallback fixes.

`gamedev-notes-audit` (uncommitted): `setup/web-stub/public/` - a manifest named after the
new game, a placeholder icon, and the `sw-legacy-cleanup.js` that workbox's `importScripts`
names - and `new-game.ps1` now replaces `public/` from the stub the way it replaces `src/`,
verifies nothing of the source game's survived there, substitutes the placeholders in it, and
resets `assets/CREDITS.md`. A new web game no longer ships Coreward's ship models, and no
longer precaches them.

## Needs Gideon's eyes before merge

1. **The template was steering inverted.** `test_controls.gd` caught it on the first
   write, which makes the template the sixth instance of the bug that has shipped in
   five games. The fix is in `src/game/main.gd` behind one constant, `TRACK_Z`. It is
   a behavioural change to the template, not just a test, so read it.
2. **Almost nothing has been executed.** `scripts\check.ps1` in
   `C:\dev\godot-template-audit` has been run once and was green - 40 tests, 4,444
   assertions, plus 19 smoke assertions - but that was BEFORE `src/sim/save.gd`,
   `SimRng.to_dict`/`apply` and `test/test_save.gd`. Run it again. Expected after them:
   **48 tests, 4,578 assertions** (133 new in `test_save.gd`, plus one more from
   `test_sim_boundary.gd`, which asserts once per file under `src/sim` and now sees five).
   That is under `MIN_ASSERTIONS + FLOOR_SLACK` (4,800), so the floor stays at 4,400 and the
   runner will not nag. On the notes branch nothing has been executed at all: no PowerShell
   has run, so `new-game.ps1` is read, not proven.
3. ~~A web scaffold still inherits Coreward's `public/`.~~ Fixed on the branch: `public/`
   is replaced from `setup/web-stub/public/` like `src/`, and the scaffold now fails if any
   file of the source game's survives there. What a new web game still inherits from the
   source game is its TOOLING, as designed - including `vite.config.js`'s `globPatterns`
   (which still lists `glb` and `webp`: harmless once the models are gone, and the safe
   direction to be wrong in) and its Coreward-shaped comments, and
   `scripts/check-bundle-size.mjs`'s `DEFAULT_TOLERANCE`, which names `rock-normal.webp`.
4. ~~`INDEX.md` rule 2 must settle the `FileAccess` question.~~ Settled in rule 2 and now
   enforced on both sides: `test_sim_boundary.gd` records why `FileAccess` and `DirAccess`
   are deliberately not gate tokens, and `test_save.gd` is the round-trip test the rule
   demands. gravewell's and candle-gift's `save.gd` have NOT been read against it - the
   standard is that `apply` restores every field or returns false, and a lenient one that
   defaults a missing key passes nothing.

## Not started

- **The digest of the 44-lesson backlog.** This is the largest remaining item and the
  root cause in the audit. It edits every topic file, so it wants the lease that is
  now in `kb.ps1`.
- **The doctor script** (`scripts/doctor.ps1`) and its `/framework-check` skill: the
  standing watchdog for template drift per repo, inbox backlog, broken references,
  missing guards and `version/code`. Agreed design, not yet written.
- **Skill file corrections**: the POLISH phone gate carve-out, `check.ps1` versus
  `npm run check` for web, the replay-scenario claim no repo satisfies, wiring
  `agents/playtester.md` into `skills/playtest/SKILL.md`.
- **Topic-file contradictions** in section 3 of the audit, and the PLAYER.md rewrite.
- gravewell's 1.72 GB history, and wrecking-crew's missing `PLAN.md`.
