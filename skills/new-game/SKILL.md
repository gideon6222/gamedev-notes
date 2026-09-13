---
name: new-game
description: Turn an idea for a phone game into a fully planned, scaffolded, built and shipped game with one approval gate. Use when Gideon describes a game he wants, asks for "a game where...", or asks what to build next. Expands the idea, picks Godot or web, researches, writes PLAN.md, gets approval, then scaffolds, builds, test-plays and ships.
argument-hint: <the idea, in his words>
---

# New game: from a sentence to a shipped build

`$ARGUMENTS` is the idea. Everything before the gate is thinking and research; nothing is
created on disk except the plan. After the gate there are no more questions.

## 1. Read before designing (ten minutes that decide the game)

Run `/framework-check` first, before planning, and fix what it reports.

- `C:\dev\gamedev-notes\PLAYER.md`: what he plays first, the seven recurring complaints,
  how he wants to work.
- `C:\dev\gamedev-notes\CRAFT.md`: skim every heading, read the sections the idea touches.
- `C:\dev\gamedev-notes\techniques\README.md`: is there a technique this game will reuse?
- `C:\dev\gamedev-notes\playtests\`: the file for the most similar past game.
- Run `powershell C:\dev\gamedev-notes\scripts\kb.ps1 pull` first, and `/digest` if the
  inbox holds more than ten files, so this plan starts from everything the last sessions
  learned.

## 2. Expand the idea

Write, for yourself, before any search:

- **The fantasy in one sentence** and the core loop in one sentence (verb, resource,
  decision, consequence).
- **What the player controls continuously.** If the answer is "nothing", redesign until
  there is one.
- **Every suggestion in his message, expanded.** He wants each one taken further, not
  trimmed. For each: what it is at its best, what it needs, what it connects to.
- **Stakes**: what doing nothing costs, what the greedy option risks, what is at stake in
  the first minute.
- **The thing you keep**: the collection, ladder or record that does not decay.
- **The second month**: what the game grows into when it is working.
- **Three more ideas he did not mention** that the loop would make fun, marked as yours.

## 3. Pick the engine

Godot unless the game genuinely wants to be a link someone opens without installing, or
is so light that 3D and native features would be waste. Say which and why in one line of
the plan. Real 3D by default.

## 4. Research and plan

Run `/game-plan` with the expanded idea. It searches, runs the asset scout, and writes
`C:\dev\plans\<slug>\PLAN.md` (and `REFERENCE.md` when there is a reference game). Choose
the slug now: lowercase, hyphenated, two words at most, not already under `C:\dev`.

## 5. The gate

Show him the plan: the summary block at the top of `PLAN.md` verbatim (fantasy, loop,
engine, the first minute, the systems list, the asset shortlist with licenses, the
milestone phases, your three additions), then the one question: **"Build it as planned, or
change anything first?"** Wait. Apply his edits to the plan file. This is the only question
in the whole process.

## 6. Build without stopping

1. `/game-scaffold <slug> "<Name>"` creates the repo, secrets, CI and proves the fresh copy
   passes its gate. The plan moves into the repo.
2. `/game-studio` runs the milestone loop through phase one (the first playable), filming
   as it goes.
3. `/asset-hunt fetch` brings in every asset the plan lists, with credits.
4. `/playtest desk` then `/playtest phone`.
5. `/ship`, which walks `POLISH.md`. If the list has a no, fix it, do not ask.
6. Report: the APK link, a screenshot at 460x996, the changelog, what he should try first,
   and what phase two contains. Then keep going into phase two unless he says stop.

Record lessons with `/record-lesson` throughout, including "the plan said X and the build
showed Y", which is the most valuable kind.
