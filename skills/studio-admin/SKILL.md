---
name: studio-admin
description: Change how the game studio is managed (thresholds, the lease, the weekly check, skills, agents, model routing, hooks, permissions) without re-reading the whole knowledge base. Use when Gideon says "change the management", "make the check less strict", "the digest should...", "add an agent", "why does it keep flagging X", "what runs when", or anything about the framework's own machinery rather than a game.
argument-hint: <the change he wants, or a question about the machinery>
---

# Studio admin

This is the chat for changing the machinery. Read `C:\dev\gamedev-notes\ADMIN.md` first:
it is a map of every knob, one line each, and where it lives. Read the file the map points
at, and nothing else, then make the change. Do not read the topic files (CRAFT, GODOT,
TESTING and so on) for this: they are about games, and this skill is about the framework.

## Rules of the room

1. Work in `C:\dev\gamedev-notes` directly for a one-file change. For anything touching
   more than two files, or `doctor.ps1`, use a worktree
   (`git worktree add C:\dev\gamedev-notes-admin -b admin/<topic>`), and remove it when
   merged. Never `git checkout -b` in place.
2. After editing any `.ps1`, parse-check it and run it once against something harmless
   before committing: `doctor.ps1` with `-Repo godot-template -Quiet`, `kb.ps1 status`,
   `weekly-check.ps1` as is. A parse pass alone has passed broken scripts here twice.
3. Commit by name with `scripts\kb.ps1 commit -Files ... -Message "Admin: ..."`. Push is
   part of that. If the change is to a skill, it is live everywhere the moment it is saved
   (the skills folder is junctioned). If it is to an agent, or to
   `setup\settings.merge.json`, run `setup\install.ps1` so it reaches `~/.claude`.
4. Loosen before you add. When he says something is flagged too often, the first question
   is whether the check should be a WARN, run less often, or read from `reports\LATEST.txt`
   instead of re-running. Only add a check for a fault that has actually happened.
5. A gate must not fail for something the gated repo cannot fix, and a check that passes
   because nothing happened is the fault this system exists to catch. Both still hold.
6. Answer questions about the machinery from `ADMIN.md` and the file it names. If the
   answer is not there, find it, then add the line to `ADMIN.md` so the next question is
   cheaper.
7. If the change alters what a session sees at startup, what a skill does, or which model
   does what, update `MODELS.md` or `ADMIN.md` in the same commit. They are the map, and a
   stale map is how this chat ends up reading everything again.

## Model

Sonnet is enough for this skill. Start it as `claude --model sonnet` in
`C:\dev\gamedev-notes`, or say `/model sonnet` first. Use Opus only when the change is to
`doctor.ps1`'s logic or to a concurrency rule.

## Report

One short message: what changed, file by file, and what he has to run (usually nothing, or
`install.ps1` once). Prose, no semicolons, no em dashes.
