---
name: framework-check
description: Check that the framework itself still holds - the knowledge base, the template and every game repo under C:\dev. Runs scripts\doctor.ps1 and acts on what it reports. Use at the start of a new game and before any ship, when Gideon says "check the framework", "is the setup still right", "audit the knowledge base", "something feels off with the build setup", "is anything drifting", or after a session that touched the template, a script, a skill or the inbox.
argument-hint: [game] | fix | quiet
---

# Framework check

**`scripts\doctor.ps1` is the gate. This skill is the judgement.** The script decides what
is true; it has no opinion about what to do next. You decide which failures are yours to fix
in this session, which are his to decide, and which are a rule that needs rewriting so the
failure cannot recur. Do not restate the script's findings back to him - act on them.

The script exists because of one line in `AUDIT-2026-09-11.md`: most rules here were written
as advice about a convention rather than as a test that fails, so a session that had not read
the line repeated the bug. Everything doctor checks was a real defect that a correct,
written-down rule failed to prevent.


Every game's `scripts\check.ps1` already runs `doctor.ps1 -Repo <slug> -Quiet`
as its last step, so the mechanical half fires before every commit without
anyone asking for it. That pass skips cross-references, template content drift,
sim purity and git hygiene for speed. This skill is the full pass and the
judgement on top of it: run it at the start of a game, before a ship, and
whenever the quiet run has been failing and nobody has looked at why.

## 0. Read the last routine result first

`scripts\weekly-check.ps1` runs the full doctor every Sunday on a Windows scheduled task
and leaves `reports\LATEST.txt`. Read it (or ask the `doctor-runner` agent for `latest`).
If it is under nine days old and shows `0 fail`, and nothing in the inbox or the template
has changed since, that IS the check: say so in one line and go on with the work. Only
run the doctor yourself when the report is stale, shows a FAIL, or you have just changed
something it looks at.

## 1. Run it

Delegate the run to the `doctor-runner` agent (Haiku) with `full`, a game name, `fix` or
`quiet`. It returns the summary and the WARN and FAIL lines verbatim and costs almost
nothing. Reading a 1200-line script's output in the main session is what this skill's
judgement is for, not its context. Running it by hand when you must:

```powershell
powershell C:\dev\gamedev-notes\scripts\doctor.ps1
```

`$ARGUMENTS`:

- a game name -> `-Repo <name>`, narrowing the per-repo checks to that game.
- `fix` -> add `-Fix`. It applies only what is unambiguously safe and reversible (today:
  creating a missing `build/.gdignore`) and names each change. Everything else is yours.
- `quiet` -> add `-Quiet`, for a hook. It prints only WARN and FAIL and skips the slow
  checks. Never report "clean" off a `-Quiet` run; run it in full before you say that.

Exit code 1 means at least one FAIL. Read every line: each FAIL ends with its fix.

## 2. Read the output as three kinds of finding

**A FAIL that says the check inspected nothing** - no repos found, a glob that matched no
files, a file that could not be read, a pattern that no longer matches how the docs are
written. This is a fault in `doctor.ps1` or in where things live, not in the game. Fix the
script or the layout. Never make one of these quiet by narrowing what it looks at: a check
that passes because nothing happened is the fault this whole script exists to catch.

**A FAIL with a determined fix.** Do it now, in this session, then run doctor again:

- a missing `build/.gdignore` -> `-Fix`.
- a missing required file or template script -> copy from `C:\dev\godot-template` and adapt
  it to the game. Read the copy afterwards; `rects.gd` in particular has carried hard-coded
  node names from the game it was written in.
- a `version/code` that disagrees with the changelog -> set it in **every** preset. Only ever
  raise it. If a build with a higher code has already gone to Play, the changelog is the
  thing that is wrong, not the preset.
- a broken cross-reference, a missing index row, a `Belongs in:` pointing at nothing -> edit
  the doc. One line each.
- a `.gitignore` on the bare `build/` form -> replace with `build/*` then `!build/.gdignore`,
  then check `git status --short` for output files that were being tracked all along.
- a hand-written suite list in `run_tests.gd` -> replace with the glob runner from the
  template, **then run the suite** and compare the test count against the last known one. A
  runner that finds more suites than the array did has been hiding them.

**A FAIL or WARN that needs a decision.** Do not guess at these; they go in the report:

- template drift (WARN): a game may legitimately diverge. Read the diff and say which side
  is right. A fix made in the template and never forward-ported looks identical from here to
  a deliberate divergence, and only reading tells them apart. Once a difference is read and
  accepted, list the script in that game's `scripts\DIVERGENCE.md` and the line stops naming
  it. Do not list a script there to silence an owed forward-port.
- an engine reference inside `src/sim`: moving it is an architecture change. Say what it is,
  where it should live, and what it would cost.
- a `.git` over the size warning, a game missing half the template, a port that has to change
  in three files at once.

## 3. Backlog and staleness are a `/digest`, not a hand-edit

An inbox backlog, a stale digest, a topic file over its size limit and a lesson missing
`## Replaces or contradicts` are all one job: run `/digest`. Do not fold lessons in by hand
from here, and do not edit a topic file to shrink it - `/digest` is the only thing that
writes to them, and two sessions editing them at once is what the rule exists to prevent.

The Courier normally runs that `/digest` unattended, so a backlog still standing when you
look is a finding about the dashboard agent at `C:\dev\studio-dashboard` and not about the
sessions that wrote the lessons. Clear it by hand, and report it that way.

If lessons are missing `Belongs in:` or `## Replaces or contradicts`, fix the files before
digesting them. That field is the only mechanism in the base that catches a lesson
contradicting an existing rule, and four contradictions once stood live in the topic files
because it was missing from most of the inbox.

## 4. File a lesson when a rule did not hold

A FAIL is evidence about the rule as much as about the repo. Run `/record-lesson` when:

- the same class of failure shows up in more than one repo. That is not five mistakes, it is
  one rule that does not reach a session at the moment it matters.
- the fix belongs in `godot-template/` rather than in the game. A rule that a scaffolded game
  inherits as a failing test is worth more than the same rule written in a topic file.
- doctor missed something you found by hand. Add the check, and say in the lesson what the
  check would have caught.
- a check fired on something that was correct. Fix the check and record why, so the next
  session does not "fix" a false positive into the repo.

Write the lesson with a measured number where there is one, and commit it with
`scripts\kb.ps1 commit`. Never edit a topic file from this skill.

## 5. Never make a check pass by lowering it

Raising an assertion floor to meet a smaller suite, narrowing a glob until it matches only
what already exists, deleting a check that is inconvenient, or excluding a repo to get a
green run - each of these turns the gate back into the advice it replaced. If a check is
genuinely wrong, change what it asserts and say so in the report. If it is right and the
work is large, leave it failing and put it in the report.

## 6. Report to him

One message, in his terms, not the script's:

- **What is broken and what it costs him.** "Stillwater's version code is 1 after three
  releases - Play would reject every upload after the first." Not "version/code mismatch".
- **What you fixed**, one line each.
- **What needs him**, as a question with your recommendation attached, one decision per line.
- **The count**: how many checks pass, how many fail, and whether the number moved since the
  last run.

If everything passes, say so in one line and get on with the work he asked for. He does not
want a report about a clean check; he wants the game.

## When this runs on its own

`/new-game` runs this before planning, and it is worth running before a ship and after any
session that touched the template, a script, a skill or the inbox. A SessionStart hook can
run it with `-Quiet` and gate on the exit code. If it is ever wired into a hook that blocks,
make sure a FAIL a session cannot fix does not stop the session from working - say the
number, and let the work continue.
