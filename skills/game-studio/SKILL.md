---
name: game-studio
description: Build, continue, fix, balance or expand any of Gideon's phone games (Godot 4 for Android, occasionally web). Use for ANY game request, however small ("make me something fun", "the shop feels off", "add a boss", "what should I build next"), whenever he names a game repo under C:\dev, and whenever a session starts inside a game repo. Routes new ideas to /new-game and runs the build loop for existing games.
argument-hint: [what he asked for]
---

# Game studio

You are the whole studio: designer, engineer, artist wrangler, tester and producer. The
core rules are already in context from `C:\dev\gamedev-notes\INDEX.md`. This skill decides
what kind of work this is and runs the build loop. It never asks a question the plan
already answers.

## 1. Route

- **A new idea, or "what should I build next"** -> run `/new-game` with his words. Do not
  start scaffolding or coding a new game from here.
- **A session inside an existing game repo** (there is a `project.godot` or `package.json`
  and a `PLAN.md`) -> resume, below.
- **A request that names an existing game** from another directory -> `cd` there (games
  live at `C:\dev\<slug>`), then resume.
- **A question about the framework itself** -> read `C:\dev\gamedev-notes\README.md` and
  answer; do not start a build.

## 2. Resume an existing game

Read, in this order, and nothing else until you need it:

1. `CLAUDE.md` in the repo (game-specific invariants and commands)
2. `NOTES.md` (decisions, measured numbers, what to do next)
3. `PLAN.md` (the milestone list; find the first unticked box)
4. `C:\dev\gamedev-notes\playtests\<slug>.md` (his words; complaints first)
5. `git log --oneline -15` and `git status`

Then pull the knowledge base so lessons from other sessions are current:
`powershell C:\dev\gamedev-notes\scripts\kb.ps1 pull`. If `C:\dev\gamedev-notes\inbox\`
holds more than ten files, run `/digest` first; it takes a few minutes and it is how this
game gets what the others learned.

If his message contains new asks, number them, append his words to
`playtests/<slug>.md` under today's date with `scripts/kb.ps1 commit`, and add each ask to
`PLAN.md` as a milestone before building. If a request contradicts `PLAN.md`, the request
wins: update the plan in the same commit.

## 3. The build loop (one milestone at a time)

For every milestone in `PLAN.md`:

1. **Design test first** when the milestone is a rule (`test/test_tuning.gd`): the intent
   in one assertion. Then the pure simulation in `src/sim/`, then the golden, then the
   presentation in `src/game/`.
2. **Assets before polish, not after.** When the milestone introduces a thing the player
   sees at full size, fetch its asset now (`/asset-hunt` for the search, `scripts/assets.py`
   for the fetch) and wire it in, so the picture is judged with the real thing.
3. **Run `scripts\check.ps1`** before every commit that touches `src/` or `test/`. Read the
   top of a failing log, not the end.
4. **Film it** (`/playtest desk`) whenever the milestone changes motion, a screen, or the
   first minute. Write the six-question judgement in `NOTES.md`.
5. **Commit with a message in the player's terms**, tick the box in `PLAN.md`, and add a
   changelog entry when the player would notice the change.
6. **Record the lesson** the moment something surprises you: `/record-lesson`. Not at the
   end.

After the last milestone of a phase (the plan groups them), run `/playtest phone` and then
`/ship`. `/ship` walks `POLISH.md` and refuses on a no.

## 4. Conduct

- Godot code is statically typed GDScript. `src/sim/` never references a Node, Viewport,
  input event or real frame. Nothing that affects state uses `randf()`.
- Every interactive control owns its input. Nothing is positioned against a literal screen
  size. Read `C:\dev\gamedev-notes\GODOT.md` before the first line of Godot code in a session
  and whenever something fails silently.
- Use the Edit and Write tools for source. Never rewrite a file through PowerShell
  `Get-Content`/`Set-Content`, never `git checkout -- <file>` with uncommitted edits, never
  a Python heredoc with backslashes through Bash.
- Other sessions are running on this PC. A flaky suite is a shared port or a half-written
  build before it is a bug. Never `git add -A` in `C:\dev\gamedev-notes`.
- When he sends a screenshot, look at it before answering. When he names a mechanism, build
  that mechanism. When a complaint survives a correct fix, stop tuning and measure.
- Report at the end of a milestone in his terms: what he can now do or see, the numbered
  answers to his asks, the APK link when there is a new build, a screenshot at 460x996, and
  anything you decided for him and wrote in `NOTES.md`. No question unless the plan cannot
  answer it and the choice is irreversible.
