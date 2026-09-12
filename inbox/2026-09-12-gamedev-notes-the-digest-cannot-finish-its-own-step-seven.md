# `/digest` cannot run its own step 7: `kb.ps1 commit` refuses a file it has just deleted, so a fold and its inbox removal can never be one commit

**Game:** gamedev-notes (the framework itself)  **Date:** 2026-09-12
**Belongs in:** GODOT.md / Toolchain (beside the other script traps), and `scripts/kb.ps1` plus
`skills/digest/SKILL.md` need the fix in the same commit

## What happened

The 2026-09-12 digest folded 22 lessons and then could not complete step 7, which reads:

> Delete each folded inbox file with `git rm`, then commit everything by name:
> `kb.ps1 commit -Files CRAFT.md,GODOT.md,inbox\<a>.md,... -Message "Digest: <n> lessons"`

`kb.ps1 commit` validates every `-Files` entry with
`if (-not (Test-Path -LiteralPath $f)) { throw "no such file: $f" }`. A file that `git rm` has just
deleted does not exist, so naming it throws. The guard is correct about blanket adds and patterns
and wrong about deletions, which are the one kind of change whose path is *supposed* to be gone.
**The documented procedure has never been executable as written**, and nobody noticed because the
step is done by hand at the end of a long session and a second plain `git commit` looks like
finishing the job rather than working around a broken tool.

The second half is smaller and cost the same kind of time. Read-only `git status` run from the
Linux-side shell leaves a zero-byte `.git/index.lock` behind that the sandbox cannot unlink
(`Operation not permitted`), and that lock then blocks every git write in the repo including
`kb.ps1 commit`. Two repos were locked this way in one session, and the error a human sees is
"Another git process seems to be running", which points at the wrong thing entirely.

## The rule

**A guard that refuses a dangerous pathspec must still permit a deletion.** Check
`Test-Path` only for paths git does not already know are deleted: take the set from
`git diff --cached --name-only --diff-filter=D` and `git status --porcelain`, and reject an
unknown, non-existent path rather than every non-existent path. Then fix
`skills/digest/SKILL.md` step 7 in the same commit, because a skill that prescribes a command the
script rejects sends every future digest down a hand-rolled path.

**And a procedure is not verified until it has been run end to end once.** Every other rule in this
base earns its place by having failed. This one was written, reviewed, and never executed, which is
the same defect as a test nobody has watched go red.

## Replaces or contradicts

`skills/digest/SKILL.md` step 7, quoted above, which cannot work as written. The fix is in
`scripts/kb.ps1` rather than in the skill if the guard is relaxed, and in both if it is not.

Does **not** contradict `CLAUDE.md`'s "Never `git add -A` here. Stage by name, or use
`scripts/kb.ps1 commit -Files ...`" - that rule is right and is the reason the guard exists. The
point is that the guard currently forces a digest outside the safe path to do the one thing the
skill tells it to do.
