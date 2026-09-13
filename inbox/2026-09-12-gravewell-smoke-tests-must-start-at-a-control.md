# Every assertion in a smoke test must start at something the player can touch, because a scene test that calls the simulation's method proves the rule and never the wiring

**Game:** gravewell  **Date:** 2026-09-12  **Belongs in:** TESTING.md / The layers, and what each one catches

## What happened
Gravewell shipped a build in which a finished descent froze the game forever: nothing called
`sim.enter_hold()` and no control listened for the tap the HUD was printing, so the shop, the
upgrade ladder, the goal and every secret were unreachable. The smoke test has a check
literally named "a finished descent can be left". It boots the real scene, and it passed
green through the whole build, because its middle line was `main.sim.redescend()` - the
method, not the button. Every other assertion around it was true. Rewritten to tap the touch
layer and press LAUNCH the way a thumb does, it fails the moment the wiring is removed.

The same build had 204 passing tests over 22 suites. Seven world classes, vaults, keepsakes,
a seven-slot drive: all proven by the unit layer, none of it reachable in the game.

## The rule
In a smoke test, reach the simulation only through a control the player can press: emit the
button's own signal or the touch layer's, never call the `Sim` method the button is supposed
to call. Calling the method is a unit test with a scene attached, and the wiring between them
is the entire thing that layer exists to catch.

## Replaces or contradicts
- **A test that re-derives the rule it is testing passes with the rule deleted.** A room
