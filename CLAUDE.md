# Working inside gamedev-notes

This repo is shared by every game session on this machine. When a session is running in
this directory it is either digesting the inbox, editing the framework, or reading.

- **Never `git add -A` here.** Stage by name, or use `scripts/kb.ps1 commit -Files ...`.
- `git pull --rebase --autostash` before any edit to a topic file, and push immediately
  after. If a push is rejected, pull, rebase, push again; never force.
- `CRAFT.md`, `GODOT.md`, `TESTING.md`, `ASSETS.md`, `POLISH.md`, `PLAYER.md`, `WEB.md` and
  `INDEX.md` are edited by `/digest` or by Gideon's explicit request only. A build session
  writes to `inbox/` and `playtests/`.
- `playtests/*.md` are append only. `archive/` is never edited.
- Keep every topic file under about 30 KB. When a section grows, condense it or move the
  detail to `techniques/`.
- Prefer a measurement to a caution. Delete a guess when a number replaces it.
- Line endings are LF (`.gitattributes`). Do not rewrite files through PowerShell
  `Get-Content`/`Set-Content`.
- `skills/*/SKILL.md` are live: `~/.claude/skills/<name>` is a junction to them, so an edit
  here changes every session's skill immediately. Keep each under 300 lines and put
  reference material in the topic files, not in the skill.
