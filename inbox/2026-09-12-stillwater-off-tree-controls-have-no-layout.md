# Off-tree a Control's `get_global_rect()` is offsets, not pixels, and a container's children have zero size, so a pure-suite test must assert on which control was chosen rather than on a point being inside it, and leave "inside" to the smoke suite or a film.

**Game:** stillwater  **Date:** 2026-09-12  **Belongs in:** GODOT.md / next to the existing invariant that `global_transform` is IDENTITY and `get_viewport()` is null in the hand-stepped headless harness

## What happened
A pure-suite test instantiated main.tscn without adding it to a tree (the template's test_replay_policy.gd pattern, 1.3 s to boot) and asserted that the bot's press point lay inside the title's Continue button with `Rect2.has_point`. It failed: the button's `get_global_rect()` was `[P: (150, -760), S: (0, 0)]`. Off-tree, a VBoxContainer never lays out its children, so a container child has ZERO size, and anchored controls report their raw offsets (negative, measured from an unresolved parent) rather than screen positions - the HUD's cast button read `P: (-306, -464)`. Every control still has a rect, so nothing errors; the test simply asserts against numbers that mean nothing. The fix was to assert what the test actually claims (the bot reached for the title's button and not the cast button under it: distance to that button's centre under 1 px, distance to the other's over 1 px), which holds off-tree and in-tree alike; a check that needs the REAL rect (a press landing inside a button through the viewport) belongs in the smoke suite, which adds the scene to the root, or in a film.

## The rule
Off-tree a Control's `get_global_rect()` is offsets, not pixels, and a container's children have zero size, so a pure-suite test must assert on which control was chosen rather than on a point being inside it, and leave "inside" to the smoke suite or a film.

## Replaces or contradicts
for a control that is perfectly well built; `global_transform` returns IDENTITY silently; and
