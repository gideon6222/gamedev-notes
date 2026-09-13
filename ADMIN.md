# The machinery, one line per knob

For the `studio-admin` skill. Every setting that governs how the studio is managed, where it
lives, and what it does. Read the line, open that file, change it, update this line if the
default moved.

## What runs when

- Every Claude Code session start: `setup\session-start.ps1` (hook in `~/.claude/settings.json`, installed from `setup\settings.merge.json` by `setup\install.ps1`). Pulls this repo, clears stale zero-byte `.git\index.lock` files under `C:\dev` older than 10 min, lists inbox lesson titles, prints the last weekly verdict from `reports\LATEST.txt`. Read-only apart from the locks.
- Every game commit: the game's `scripts\check.ps1` runs `doctor.ps1 -Repo <slug> -Quiet` last. Knowledge-base findings are WARN there, never blocking (`doctor.ps1`, function `Fail`).
- Weekly, Sunday 18:00 local: Windows Task Scheduler task "gamedev-notes weekly check" runs `scripts\weekly-check.ps1` (full doctor, writes `reports\`, no Claude). Registered by `setup\install-schedule.ps1`; `-Remove` removes, `-RunNow` fires it, `-Day`/`-At` move it.
- On demand: `/framework-check` (judgement on the doctor), `/digest` (fold the inbox), `/studio-admin` (this).
- Nothing in Cowork runs on a schedule. The old Cowork weekly task was deleted on 2026-09-12; it burned Fable tokens, needed the PC linked, and left git locks behind.

## The dashboard (`C:\dev\studio-dashboard`, private site on Cloudflare Pages behind Access)

- Shows every robot (the machinery, one card each, defined in `agent\robots.json`), the rules log (inbox lessons by game, waiting or folded), activity, games, and the questions and suggestions Gideon sends from the site.
- The Courier: Task Scheduler task "studio-dashboard agent", every 10 min, `agent\run.ps1`. Collects stats (no tokens), then handles `queue\*.json`: a question goes to Haiku, Sonnet or Opus by `Select-Model` in `agent\process-queue.ps1` (the reason is shown on the site), a suggestion is evaluated by Opus (`agent\prompts\suggestion-evaluate.md`) and, if approved, implemented by Sonnet or Opus (`agent\prompts\suggestion-implement.md`) in this repo and the template, never in a game repo, followed by a full doctor run.
- Feeds: `reports\robots.log` (one line per run, written by `session-start.ps1`, `weekly-check.ps1` and the Courier), git history here (Lesson:, Digest:, Admin: subjects), each game's `build\check-*.log`, `reports\LATEST.txt`.
- A suggestion implemented from the site shows up here as an `Admin:` commit, so name commits that way.

## Thresholds (all in `scripts\doctor.ps1` unless noted)

- Inbox backlog: PASS up to 10, WARN over 10, FAIL over 40 (`Test-InboxBacklog`). The documented digest trigger is ten (`INDEX.md`, `session-start.ps1`).
- Digest age: WARN when lessons are waiting and the last `Digest` commit is over 3 days old (`Test-DigestAge`).
- Lesson format (missing `Belongs in:` or `## Replaces or contradicts`): WARN, never FAIL (`Test-LessonFormat`).
- Topic file size: WARN over 32 KB, FAIL over 35 KB (`Test-TopicFileSize`). The written target is about 30 KB.
- Template drift: WARN for any template script whose content differs, except names listed in the game's `scripts\DIVERGENCE.md` (`Test-TemplateScriptSet`).
- Plan outline: WARN when a game's PLAN.md has no `- [ ]` milestone lines (`Test-PlanOutline`). The dashboard's checklist reads those boxes; the changelog tab reads `src\changelog.gd` or `.ts`.
- Git hygiene: WARN on uncommitted or unpushed work, WARN on a large `.git` (`Test-GitHygiene`).
- Snapshot dirs (`*.pre-fix`, `*-audit`, `*.bak`, `*.old`) are skipped unless `-IncludeSnapshots`.
- Weekly reports kept: 8 (`weekly-check.ps1 -Keep`).

## Concurrency

- Digest lease: `scripts\kb.ps1`, `$LeaseMinutes = 45`. Lease file is `.git\kb-lease`, never tracked. A stale lease is taken over with a notice, never a block.
- `kb.ps1 commit` refuses `-A`, globs, directories and pathspec magic. It accepts a tracked file that is no longer on disk as a deletion, and splits a comma-joined `-Files` string (the `-File` invocation binds it as one).
- Stale `index.lock` (zero bytes, over 10 minutes old): cleared by `session-start.ps1` and `weekly-check.ps1`. A Cowork chat running git against the mounted folder is the usual source; the project rules tell it not to.
- Branches: never `git checkout -b` in `gamedev-notes`; use `git worktree add`. (`CLAUDE.md`, `README.md`.)

## Skills (`skills\<name>\SKILL.md`, junctioned into `~/.claude/skills`, live on save)

game-studio (build loop and routing), new-game, game-plan, game-scaffold, asset-hunt, playtest, ship, record-lesson, digest, framework-check, studio-admin. Each under 300 lines.

## Agents (`agents\*.md`, copied into `~/.claude/agents` by `install.ps1`, so re-run it after a change)

doctor-runner (haiku), lesson-filer (haiku), game-researcher (sonnet), asset-scout (sonnet), playtester (inherit). Routing table and how to verify: `MODELS.md`.

## Permissions and hooks

`setup\settings.merge.json`: the allow list (git, gh, godot, adb, powershell, node, python and the read and edit scope `C:\dev`), the deny list (`C:\dev\keys`, `C:\dev\.env`, force push), `additionalDirectories`, and the SessionStart hook. `install.ps1` merges it into `~/.claude/settings.json`; it does not remove entries it did not add. If Claude Code prompts for a command that should be routine, add its pattern to `allow` and re-run `install.ps1`.

## Where the game side is documented

`INDEX.md` (loaded in every session), `README.md` (file map and game table), the topic files. `AUDIT-2026-09-11.md` and `AUDIT-PROGRESS.md` are history; read them only when a question is about why a rule exists.
