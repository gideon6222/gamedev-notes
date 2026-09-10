# A tool winget installed is invisible to a session that started before it, so resolve it by path before believing `Get-Command`

**Game:** stillwater  **Date:** 2026-09-09  **Belongs in:** GODOT.md / toolchain, or TESTING.md wherever the film tool is described

## What happened

`scripts\movie.ps1` refused to run: "ffmpeg not on PATH; run
`C:\dev\gamedev-notes\setup\install.ps1`". ffmpeg was installed - `winget list --id
Gyan.FFmpeg` reported 9.0.1, and its directory was present in the **user** PATH in the
registry. What it was not in was the environment of the shell doing the asking, because
winget writes the user PATH and a process only reads that at startup. A Claude session's
shell can be hours older than the install.

The advice in the error was the expensive part. `install.ps1` reinstalls nothing (winget
answers "already installed"), and on the way past it rewrites `~/.claude/CLAUDE.md`,
re-junctions every skill and merges settings - a large blast radius, shared with other running
sessions, to fix a PATH that was already correct.

The fix is three lines: `Get-Command`, then the winget Packages glob
(`$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Gyan.FFmpeg_*\ffmpeg-*-full_build\bin\ffmpeg.exe`),
then the user PATH out of the registry, and only then give up - with the one-line winget
command rather than the installer. Committed to `godot-template` as 49702e0, so new games have
it.

## The rule

Before a script concludes a tool is missing, look where its installer actually puts it. On this
PC that is `%LOCALAPPDATA%\Microsoft\WinGet\Packages\<Publisher>.<Id>_*\...`, which is how
`GODOT` is already resolved everywhere - apply the same pattern to ffmpeg, adb, scrcpy and gh.
Never point an error message at `setup\install.ps1` for a missing tool: it is a whole-machine
script that touches `~/.claude`, and the honest advice is the single `winget install --id <id>
--scope user` line. Note the wider version of this too: **anything winget installed during a
session is invisible to that session**, so verify a fresh install by absolute path rather than
by re-running the command that just failed.

## Replaces or contradicts

Contradicts, in spirit, `~/.claude/CLAUDE.md`'s "ffmpeg and scrcpy on PATH" and INDEX.md's
"Claude has ... ffmpeg" - both true of a fresh terminal and not necessarily true of the shell a
session is holding. Worth rewording to "on the user PATH (a session older than the install will
not see it)".
