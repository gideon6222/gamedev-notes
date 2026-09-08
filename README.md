# gamedev-notes

The shared brain for Gideon's games. Games are built with Claude Code on a Windows PC and
played on a Galaxy S26 Ultra, installed to the home screen as PWAs.

**Read this repo before starting or resuming any game.** Without it nothing compounds.

| File | What it holds | Lifecycle |
|---|---|---|
| **`SKILL.md`** | The process, start to ship. **The canonical copy of the `phone-game-studio` skill** — the installed one is a pointer at this file, because the plugin cache it lives in is re-extracted every session | Rewrite in place |
| **`PIPELINE.md`** | The stack, how to ship, and the **measured** limits. Start here to find out what is actually constrained | Rewrite in place |
| **`CRAFT.md`** | What makes a game good. Organised by topic, not by date | Edit the right section |
| **`ASSETS.md`** | Where to get things we did not make, how to shrink them, and when not to bother | Rewrite in place |
| **`PLAYTESTS.md`** | What Gideon actually said, dated, in his words | **Append only** — it is evidence |

## No game is a one-off

Every game is built to be added to indefinitely, so every one gets the full stack from the
first commit — git, Vite, TypeScript, CI, a size guard, a golden test, `CLAUDE.md`,
`NOTES.md`, a build stamp and a changelog. `PIPELINE.md` has the list. There is no "start
simple and migrate later": that migration then has to happen around a game you are trying not
to break.

## How this reaches every session

`~/.claude/CLAUDE.md` points at this repo and loads in **every** Claude Code session on this
machine, in every project. Each game repo also has its own `CLAUDE.md` pointing here, which
loads when a session runs in or under that directory. A session already running when these
files change will not see them until it restarts.

## The one rule

**Write what you learn in the same commit as the change that taught it.** Not at the end of a
session, not when the game ships. Several games run at once, so a lesson recorded after this
game finishes is one the next game never got.

The test: *would this have saved time if I had known it this morning?* If yes, write it now,
even mid-build.

## Prefer a measurement to a caution

If a rule anywhere reads like a guess — "keep it small", "be careful with memory" — go and
measure the real number, write it down, and delete the caution. Several rules in here were
precautions from when Claude could not run anything locally. That era is over.

## Games

| Game | Repo | Live |
|---|---|---|
| Coreward | github.com/gideon6222/coreward | https://gideon6222.github.io/coreward/ |
| Captain Run | github.com/gideon6222/Captain_Run | https://gideon6222.github.io/Captain_Run/ |
