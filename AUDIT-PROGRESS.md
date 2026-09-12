# Audit fixes: what is done, what is left

Companion to `AUDIT-2026-09-11.md`. Updated 2026-09-12.

## Where the work lives

Nothing is pushed and nothing is merged. The two shared repos were NOT branched in
place, because `C:\dev\gamedev-notes` is one working tree shared by every running
session and `git checkout -b` there would have yanked them all onto the branch.
The work is in two git worktrees:

| worktree | branch | parent |
|---|---|---|
| `C:\dev\gamedev-notes-audit` | `framework-audit-fixes` | `C:\dev\gamedev-notes` |
| `C:\dev\godot-template-audit` | `framework-audit-fixes` | `C:\dev\godot-template` |

`main` in both is untouched. Review with
`git -C C:\dev\gamedev-notes log main..framework-audit-fixes -p`. Merge, then
`git worktree remove` each one.

## Merge these two first, in this order

1. **`godot-template`** — the new gates, and a fix to the template's own game.
2. **`gamedev-notes`** — the digest, the settled contradictions, `doctor.ps1`.

Until the template is merged, `doctor.ps1` reports two failures against it. They
are accurate: the live template has the old hand-written runner and neither new
gate.

## Verified

`check.ps1` was run in `C:\dev\godot-template-audit` on 2026-09-12 and is
**green**: 40 tests, 4444 assertions, all passing, plus 19 smoke assertions. The
glob runner discovered all seven suites including the three new gates, and the
hand-counted `MIN_ASSERTIONS` floor of 4400 was correct.

`doctor.ps1` has been run end to end against `C:\dev` and reports **66 pass,
15 warn, 2 fail**, where both failures are the live `godot-template` being behind
this branch. Every `.ps1` touched parses clean under PowerShell 7.

Still unrun: the per-game suites. After merging, run `scripts\check.ps1` in each
game repo — the new `test_controls.gd` in gravewell and wrecking-crew has three
timing-dependent assertions flagged in the report, and the sim-boundary and
version gates are new everywhere.

## Done

**The learning loop.** All 46 inbox lessons folded or deleted as already covered;
`inbox/` is empty for the first time since 2026-09-10. Four live contradictions
settled, eight duplicate groups merged, ten restatements deleted rather than
added. Six new `techniques/` write-ups, all indexed. Topic files back under 30 KB
by extraction, not truncation.

**The watchdog.** `scripts/doctor.ps1` and `skills/framework-check` check inbox
backlog, days since digest, lesson format, broken cross-references, both indexes,
topic-file size, and per repo: required files, export guards, `.gitignore` form,
`version/code`, template script drift, test discovery, the gate set, sim-wall
purity as a text scan with comments and strings stripped, git hygiene and pack
size, plus web port collisions. Verified by running it: it independently
reproduced the audit's findings, and a second pass fixed three checks that fired
on things that were correct.

**The machinery.** `kb.ps1` commits by pathspec and has a 30-minute lease so two
digests cannot overlap. `new-game.ps1` no longer ships Coreward's game as a new
web game, picks up the plan on both stacks, and allocates ports by named role.
`install.ps1` stops deleting a user's own skill and clobbering their `CLAUDE.md`.
The session hook no longer reports "up to date" after a failed pull. `assets.py`
honours `--weights` and refuses copyleft.

**The games.** Every repo now passes the export guards, the `.gitignore` form,
`version/code` and the sim wall. stillwater's gate can see Godot errors (and now
`USER ERROR`) for the first time since it was scaffolded. `shot.gd` parses its
arguments in every repo. The stale-APK refusal, the glob runner and
`test_sim_boundary.gd` are ported everywhere. `rects.gd` in stillwater and
wildform carried gravewell's control names and could never run; both replaced.
wrecking-crew has `PRIVACY.md` and an honestly-labelled reconstructed `PLAN.md`.

## Needs your judgement

1. **`INDEX.md` rule 2 now settles the `FileAccess` question**: the wall excludes
   the renderer, not the disk, so `src/sim` may touch `user://`, but
   serialisation must be a pure `state -> Dictionary -> state` pair testable
   without a file. The alternative was stillwater's stricter reading. gravewell
   and candle-gift are non-compliant with the new rule (no pure pair); stillwater
   is the exemplar.
2. **`wrecking-crew`'s `CLAUDE.md` and `NOTES.md` describe a game that no longer
   exists** — the v0.3.0 above-ground demolition game, not the v0.4.0 basement
   one that shipped. The new `PLAN.md` records this rather than adopting either.
   Nothing explains why the genre changed.
3. **`gravewell/src/sim/save.gd`** has a corrected comment sitting uncommitted,
   because that file also carries a paused session's in-flight refactor. Commit
   it when you resume gravewell.

## The steering decision, settled

The template lays its track toward **-Z** behind one constant, `TRACK_Z`, so
screen right IS world +X and no sign flip sits anywhere near the input. That is
what `CRAFT.md` already prescribed and it is the version the passing run proves.
The rejected alternative was negating `dx` in the drag handler: one character,
but it puts the flip next to the input, and the template has two input paths
(`drag_by` and `_read_pad`), so the flip would have to be duplicated and a third
path added later would miss it. That is the exact mechanism behind all six
inversions.

**Existing games were NOT retrofitted to the convention.** They are correct
today, each fixed its own way, and rewriting five camera conventions that cannot
be run from here would risk more than it fixes. What they got instead is the
gate. Every game now drives a real `InputEventScreenDrag` or `ScreenTouch`
through its own handler and asserts direction on screen:

| repo | gate | note |
|---|---|---|
| candle-gift | `run_smoke.gd` | already genuine, unchanged |
| stillwater | `run_smoke.gd` | was exercising, not asserting; assertion added |
| wildform | `run_smoke.gd` | was partial; mirrored drag and creature position added |
| gravewell | `test_controls.gd` | new, none existed |
| wrecking-crew | `test_controls.gd` | new, none existed |

Nothing is currently inverted, including wrecking-crew, whose handedness was the
one genuinely open question from his "almost feel backward" report. That comment
was about the tank-controls build that has since been replaced.

**One latent recurrence risk, reported not fixed:** candle-gift compensates for a
mirrored camera with a sign at the input (`sim.steer_to(sim.target_x - dx / span
* ...)`). Its gate catches the problem so it is safe today, but the durable fix
is a `TRACK_Z`-style constant that turns the camera round and deletes the minus.

## Left

- **A save round-trip test in the template.** The template has no save module at
  all, so the pure-pair half of rule 2 is unenforceable until it gets one.
- **gravewell's 1.72 GB of dead git objects**, and coreward's `public/` still
  being inherited wholesale by a new web game.
- `techniques/three-js-traps.md` (35 KB) and `candle-gift-reference-runner.md`
  (33 KB) are both over the size limit and want splitting.
