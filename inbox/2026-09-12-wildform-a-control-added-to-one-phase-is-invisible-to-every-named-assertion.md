# A control added to one phase and forgotten in the other is invisible to every assertion that names a control

**Game:** wildform  **Date:** 2026-09-12  **Belongs in:** `TESTING.md` under smoke tests and
what a harness cannot see, and `POLISH.md` beside the screen-by-screen line.

## What happened

A DAILY button was added to the den, beside the RUN button. The phase switch hides the den's
controls when a run starts, as a list:

```gdscript
_start_button.visible = not running
_den_banner.visible = not running
_den_touch.visible = not running
```

The new button was never added to that list, so it was drawn as a **solid blue slab across the
type pips for every second of play**. It was in the first screenshot ever taken of it, and in
every screenshot after that, and it took a release to notice.

The suite could not see it. The smoke test had grown to two hundred assertions and not one of
them could fail on this, because **every assertion names a control** - `_start_button`,
`_ring`, `_pips`, `_hud` - and this was a control nobody had named yet. A new control is
exactly the thing a suite written as a list of names has no opinion about.

## The rule

**Write the phase check as a partition over whatever the UI actually holds, not as a list of
the controls you remember.** Walk the UI root's children, flip the phase, and fail on anything
drawn in both that is not on a deliberately short allow-list:

```gdscript
const IN_BOTH_PHASES := ["Hud", "Pause", "Credits", "Flash", "PauseButton"]
```

Then a control added to either phase from now on fails the moment it is added, and the
allow-list is a decision somebody has to make in writing rather than a thing that happens by
omission. Check the other direction in the same pass: a control drawn in **neither** phase is
dead weight nobody would notice either.

Two details that are load-bearing:

- **`is_visible_in_tree()`, not `visible`.** A control inside a hidden sheet has
  `visible == true` and draws nothing. The first version of this check used `visible` and
  reported twenty-one false positives from inside the pause sheet.
- **Only the layer the phase actually governs** - the UI root's own children, `get_children()`
  and not `find_children("*", "Control", true, false)`. A panel's contents are governed by the
  panel, not by the phase.

## And name every node

The same check reported the purse readout as **`@Label@56`**, because it had never been given
a `name`. An unnamed node is `@Label@56` in every error, every remote-inspector tree and every
report that will ever mention it, and the one time it matters is the time you are trying to
work out what a failing check is talking about. It costs one line at construction.

## Replaces or contradicts

Nothing. It is a sharper instance of the existing rule that a suite made only of things you
thought to assert has no coverage of the things you did not - the same shape as "a policy that
calls `steer_to()` is not a test of the control". The fix is the same shape too: assert over
the whole population, not over the members you remembered.
