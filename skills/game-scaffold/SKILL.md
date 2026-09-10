---
name: game-scaffold
description: Create a new game repo from the template with the right settings, files, GitHub repo, secrets, CI and a first green build, with no manual steps. Use right after a plan is approved, or when Gideon asks to "start a new repo" or "set up a game project".
argument-hint: <slug> "<Name>" [--web] [--private]
---

# Scaffold a game

One script does the whole thing. Do not do the steps by hand; if the script cannot do
something, fix the script and record the lesson.

```powershell
powershell -ExecutionPolicy Bypass -File C:\dev\gamedev-notes\scripts\new-game.ps1 `
  -Slug <slug> -Name "<Name>" -Description "<one line from the plan>"          # Godot
powershell -ExecutionPolicy Bypass -File C:\dev\gamedev-notes\scripts\new-game.ps1 `
  -Slug <slug> -Name "<Name>" -Stack web                                        # web
```

What it does for Godot: copies `C:\dev\godot-template` without `.git`, `.godot`, `android`
and `build`; renames every placeholder (`godot-template`, `godottemplate`, `Godot Template`,
`com.gideon.godottemplate`) and fails if any survive; resets `changelog.gd` to 0.1.0; writes
`README.md`, `CLAUDE.md`, `NOTES.md` and `PLAN.md` from `setup/game-stubs` (taking the plan
from `C:\dev\plans\<slug>\` when it exists, with `REFERENCE.md`); `git init -b main` and a
first commit; runs the headless suites so a fresh copy proves its own gate; creates
`github.com/gideon6222/<slug>` with `gh`, pushes; sets `ANDROID_DEBUG_KEYSTORE_B64`,
`ANDROID_UPLOAD_KEYSTORE_B64` and `ANDROID_UPLOAD_KEYSTORE_PASSWORD` from `C:\dev\keys`;
prints the first CI run.

For web it copies the newest web game's tooling, assigns fresh ports, creates the repo and
enables GitHub Pages through the API (`build_type=workflow`).

## After the script

1. `cd C:\dev\<slug>` and `gh run watch` until the first run is green. A red first run
   means the template drifted: fix it in the template AND the copy, and `/record-lesson`.
2. Open `PLAN.md` and `NOTES.md`; the "Open decisions" section of the plan moves into
   `NOTES.md` verbatim.
3. Fill `CLAUDE.md`'s "This game" section from the plan: the one-sentence design, the
   file map additions, the game-specific invariants. Leave the shared sections alone; they
   import from the notes.
4. Set the phone-facing preset values the plan calls for in `export_presets.cfg`:
   `version/name`, icons (`launcher_icons/adaptive_*` once the icon exists), and
   `permissions/vibrate=true` if the game uses haptics. Commit.
5. Install the shell if the plan chose Maaack's template:
   `python C:\dev\gamedev-notes\scripts\assets.py get addon Maaack/Godot-Game-Template --into addons`
   then enable it in `project.godot`. First game using it: verify the harness still boots
   the real scene and `/record-lesson` what integration cost.
6. Commit, push, and start `/game-studio`.

## If gh is not signed in

The script stops before creating anything remote. Tell him the one command
(`gh auth login`, browser flow) and re-run with the same arguments; the local copy is
refused because it exists, so pass `-NoRepo` the first time only if he is away, then
create the remote later with `gh repo create gideon6222/<slug> --public --source . --push`
and set the secrets with `gh secret set NAME < file`.
