# Gideon's PC

This machine is Gideon's home game studio. Phone games are built here with Claude Code and
played on his Galaxy S26 Ultra. Everything about how that works lives in
`C:\dev\gamedev-notes`; its core is imported below and every game repo imports it too.

@C:/dev/gamedev-notes/INDEX.md

If the block above did not load (the `/context` command lists memory files), read
`C:\dev\gamedev-notes\INDEX.md` before doing any game work.

- Games live at `C:\dev\<slug>`. Any request about a game, however small, goes through the
  `game-studio` skill; a new idea goes through `new-game`.
- Tools: Godot at `$env:GODOT`, `gh` signed in, `adb` in `C:\dev\toolchain\android-sdk\platform-tools`,
  `ffmpeg` and `scrcpy` on PATH, node and python. Keys in `C:\dev\.env`, never committed.
- Several Claude sessions run at once on this PC. Never `git add -A` in `C:\dev\gamedev-notes`;
  write lessons to its `inbox/` with `scripts/kb.ps1`.
- Use the Edit and Write tools for source files. Never rewrite a file through PowerShell
  `Get-Content`/`Set-Content` (it corrupts non-ASCII bytes).
- He prefers clear prose, no semicolons, no em dashes, numbered answers to numbered asks.
