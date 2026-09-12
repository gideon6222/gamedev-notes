# gamedev-notes

The shared brain for Gideon's phone games. Games are built with Claude Code on a Windows
PC, in Godot 4.7 (native Android) or occasionally as web PWAs, and played on a Galaxy S26
Ultra. Every Claude Code session on this machine loads `INDEX.md`; everything else is read
by the step that needs it.

| File | What it holds | Who edits it |
|---|---|---|
| **`INDEX.md`** | The core: process, standing rules, file map, toolchain. Loaded in every session | `/digest`, rarely |
| **`PLAYER.md`** | How Gideon plays, what he complains about, how he wants to work | `/digest`, from `playtests/` |
| **`CRAFT.md`** | What makes a game good, one rule per line, by topic | `/digest` |
| **`GODOT.md`** | The Godot stack, engine traps, invariants, export and signing | `/digest` |
| **`TESTING.md`** | Test layers, harness rules, filmed runs, the phone | `/digest` |
| **`ASSETS.md`** | Where to get assets, how to fetch and import them, licences | `/digest` |
| **`POLISH.md`** | The ship gate: what complete means on a phone | `/digest` |
| **`PLAY.md`** | Getting onto Google Play | `/digest` |
| **`WEB.md`** | The web stack, for games that want to be a link | `/digest` |
| `techniques/` | Long write-ups of things done once that may be done again | `/digest` |
| `playtests/<game>.md` | His words, dated, verbatim. Append only | any session, append |
| `inbox/` | Lessons waiting to be folded in. One file each | any session, create only |
| `skills/` | The Claude Code skills that run the process. Junctioned into `~/.claude/skills` | this repo |
| `agents/` | Subagents (researcher, asset scout, playtester). Copied into `~/.claude/agents` | this repo |
| `scripts/` | `new-game.ps1`, `kb.ps1`, `assets.py`, `doctor.ps1`. `movie.ps1` and `device.ps1` are not here: they are per-game, in each repo's own `scripts/` | this repo |
| `setup/` | `install.ps1` and the files it writes into `~/.claude` | this repo |
| `archive/` | The previous generation of these notes, kept whole | never |

## Setup on a fresh machine, or after pulling a change to `setup/`

```powershell
powershell -ExecutionPolicy Bypass -File C:\dev\gamedev-notes\setup\install.ps1
gh auth login      # once
```

`install.ps1` installs `gh`, `ffmpeg` and `scrcpy` in user scope, writes
`~/.claude/CLAUDE.md`, merges hooks and permissions into `~/.claude/settings.json`, junctions
`skills/` and copies `agents/` into `~/.claude`, and creates `C:\dev\.env` from
`setup/env.example` if it does not exist. It is safe to re-run.

Then run `/framework-check` (it runs `scripts/doctor.ps1`) and fix what it reports. That is
the standing check on this repo and the games under `C:\dev`, not a one-off after install:
every `/new-game` and every `/game-studio` resume starts with it.

**To change anything in this repo, work in a git worktree, never a branch in place.**
`C:\dev\gamedev-notes` is one working tree shared by every running session, so a
`git checkout -b` there yanks every other session onto your branch mid-build. Use
`git -C C:\dev\gamedev-notes worktree add C:\dev\gamedev-notes-<topic> -b <branch>`,
work in that directory, and remove it when the branch is merged.

## The one rule

**Write what you learn the moment you learn it**, as a file in `inbox/`, with
`scripts/kb.ps1 commit`. Several games run at once, so a lesson written at the end of a
session is one the other games never got, and a topic file edited mid-build is one another
session will overwrite. `/digest` folds the inbox into the topic files at the start of every
new game, under a lease (`kb.ps1 lease`) so two digests cannot run over each other.

`/framework-check` is the standing check that the rule is actually holding: it runs
`scripts/doctor.ps1` over this repo and the games, and it is the first thing a session does,
before planning or resuming. And because this repo is one working tree shared by every
running session, framework work happens in a `git worktree`, never on a branch checked out
in place.

## Games

One row per repo under `C:\dev`. Stack is whichever of `project.godot` or `package.json`
the repo has.

| Game | Stack | Repo | What it is | Status |
|---|---|---|---|---|
| Coreward | web (three.js PWA) | github.com/gideon6222/coreward | Fly a drill ship down toward a planet core, sell ore at the surface, break the core and launch to a harder planet | Live at gideon6222.github.io/coreward. v0.31.0, the most developed game here and the only web one still built on |
| Stillwater | Godot | github.com/gideon6222/stillwater | A fishing game that starts calm at dawn and turns unsettling; depth is time, and the line upgrade is the story | v0.5.2, playable, in active phase-two build. The most active repo |
| Wildform | Godot | github.com/gideon6222/wildform | A lane shooter-runner: position is aim, and what you feed decides what you evolve into | v0.7.0, playable through eight worlds. Newest game |
| Gravewell | Godot | github.com/gideon6222/gravewell | Cut down through a dead world by lamplight, then run for the surface with its core aboard | v0.14.0, playable. Godot successor to Coreward |
| Candle Gift | Godot | github.com/gideon6222/candle-gift | A candle-factory runner modelled on Rollic's Candle Gift; `REFERENCE.md` is the observed record of it | v0.1.0, playable, phase one |
| Wrecking Crew | Godot | github.com/gideon6222/wrecking-crew | Bring a condemned building down into its own footprint with a fixed number of swings | v0.4.2, playable but frozen at a pre-Framework-v2 state: no `PLAN.md`, no `check.ps1`, no `device.ps1`, no CI `play` job. Back-fill it to the current template or retire it |
| Captain Run, Wick | web | superseded by Candle Gift | Earlier web experiments | Archived, never played |
