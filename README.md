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
| `scripts/` | `new-game.ps1`, `kb.ps1`, `assets.py`, `movie.ps1`, `device.ps1` | this repo |
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

## The one rule

**Write what you learn the moment you learn it**, as a file in `inbox/`, with
`scripts/kb.ps1 commit`. Several games run at once, so a lesson written at the end of a
session is one the other games never got, and a topic file edited mid-build is one another
session will overwrite. `/digest` folds the inbox into the topic files at the start of every
new game.

## Games

| Game | Stack | Repo | Status |
|---|---|---|---|
| Coreward | web | github.com/gideon6222/coreward | live at gideon6222.github.io/coreward |
| Candle Gift | Godot | github.com/gideon6222/candle-gift | playable |
| Stillwater | Godot | github.com/gideon6222/stillwater | playable |
| Wrecking Crew | Godot | github.com/gideon6222/wrecking-crew | playable |
| Captain Run, Wick | web | superseded by Candle Gift | archived |
