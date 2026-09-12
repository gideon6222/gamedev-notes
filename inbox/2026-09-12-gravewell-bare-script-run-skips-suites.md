# A bare `godot --headless --script res://test/run_tests.gd` can run fewer suites than CI, because a glob runner discovers through the import cache: run `check.ps1`, and read the suite list, not only the count

**Game:** gravewell  **Date:** 2026-09-12  **Belongs in:** TESTING.md / Rules for the suites

## What happened
Every ad-hoc run in a long session reported "195 tests, all passing" over 20 suites. The
first `check.ps1` run of the same tree reported 204 tests over 22. The two extra suites,
`test_controls.gd` and `test_sim_boundary.gd`, had been committed for weeks and were
passing: their `.uid` files had never been generated in this working tree, and the runner
finds suites with `DirAccess.open("res://test")`, which answers from the import cache
rather than from the disk. `check.ps1` runs `--import` first, which generated both `.uid`
files and made the suites appear. CI was never blind, because it imports before it tests.
Nothing failed, and a green "all passing" was reported all session over a set that was
two suites short.

## The rule
A glob-based suite runner reports what the import cache knows about, so run the gate rather
than a bare `--script` before believing a green, and make the runner print its suite list
so a shrinking set is visible next to the count. An untracked `.uid` beside a tracked
`.gd` is the tell.

## Replaces or contradicts
nothing
