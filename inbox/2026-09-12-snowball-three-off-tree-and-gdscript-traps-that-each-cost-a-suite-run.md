# Three off-tree and GDScript traps that each cost a suite run: lambdas capture by value, JSON needs full precision for state floats, and nothing is in the tree during initialize.

**Game:** snowball  **Date:** 2026-09-12  **Belongs in:** GODOT.md / Headless lifecycle, which is where the time goes (the first two) and TESTING.md / Rules for the suites (the third)

## What happened
GDScript lambdas capture local primitives BY VALUE. A test wrote `var edges := 0` and connected `func(...): edges += 1` to a signal; the lambda incremented its own copy and the assertion read 0 forever ("leaning into the edge for ten seconds never touched it") while the signal fired 16 times. Capture through an Array (`var edges := []; edges.append(true)`) or a Dictionary, which are references.

`JSON.stringify(data)` with the default `full_precision = false` prints floats with limited digits, so a saved `best_r` of 1.371412 came back 1.37141 and a round-trip test that compared the dictionaries failed on a real difference. Pass `full_precision = true` for any float that is state (and `sort_keys` changes key ORDER, so compare dictionaries by key, never as `str(dict)`).

Nothing is in the tree during `SceneTree._initialize()`, so `AudioStreamPlayer.play()` raises "Playback can only happen when a node is inside the scene tree" (an engine error the harness counts as a failure, 121 per test), `_ready` never runs on a node added there (an audio pool built in `_ready` stayed empty), and `is_visible_in_tree()` is false for everything. Guard playback with `is_inside_tree()`, build in an explicit idempotent `setup()` the shell calls after `add_child`, and walk the visibility chain by hand in a smoke test.

## The rule
Capture test counters through a reference type (Array or Dictionary), stringify state floats at full precision and compare dictionaries by key, and treat "off-tree" as a mode every node under the shell must survive: no playback, no `_ready`, no `is_visible_in_tree()`.

## Replaces or contradicts
Carry the result in a Dictionary or an Array, which are reference types.
