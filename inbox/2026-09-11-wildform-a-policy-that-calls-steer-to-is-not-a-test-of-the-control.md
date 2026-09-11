# A policy that calls `steer_to()` is not a test of the control, and that is how a game ships inverted

**Game:** wildform  **Date:** 2026-09-11  **Belongs in:** `TESTING.md` beside the policy
rules, and `CRAFT.md` under controls and touch.

## What happened

First build he actually played, after five releases:

> the dinosaurs run backwards and the controls are backwards

Both were one bug. The track was drawn along +Z. A Godot camera looking toward +Z has its
right-hand basis vector pointing at **-X**, so world +X appeared on the LEFT of the screen:
every drag moved the creature the wrong way. The same wrong axis meant the creature models
were rotated to face against the direction of travel.

`CRAFT.md` already says this, in as many words: *"Check a chase camera's handedness with the
NDC test, and pick the axis convention so no sign flip sits near the input (draw the street
along -Z so screen right IS world +X)."* And `PLAYER.md` records that Captain Run **shipped
inverted for its whole life**.

## Why every tool on the desk missed it

This repo had, at the time of that build: a whole-run golden over five scripted policies, 86
tests, 4,800 assertions, a smoke test that boots the real scene, filmed contact sheets of the
first minute, and screenshots of every screen at the phone's aspect. None of them could see it.

**Every scripted policy drives the game by calling `steer_to()` directly.** That function
takes a world X and the simulation moves the creature to that world X, correctly, in every
test. The bug lived entirely in the two steps either side of it: the drag handler turning a
thumb into a delta, and the camera turning a world X into a screen X.

> **A policy that sets the value the control would set is not a test of the control.**

And the filmed runs did not catch it either, because a contact sheet of a creature sliding
left while nobody is watching a thumb looks exactly like a creature sliding left on purpose.
**The one thing no bot in this studio does is hold a thumb.**

## The test that does catch it

Two assertions, both cheap, both headless:

```gdscript
# 1. Drive the REAL handler with a REAL event.
var drag := InputEventScreenDrag.new()
drag.relative = Vector2(220, 0)          # a drag to the RIGHT
main._on_touch(drag)
assert(main.sim.target_x > before)

# 2. And demand that +X actually IS screen-right.
assert(main._cam.transform.basis.x.x > 0.5)
```

The second is the NDC test written as arithmetic, so it needs no GPU, no tree and no frame -
the camera's own right vector is the entire claim. It reported **-1.00** before the fix.

A third, for anything with a facing: assert the ART's forward, not the node's. This pack's
models look along local +Z, which is the opposite of Godot's convention, so asserting on
`-basis.z` would have demanded the creatures run backwards. And **normalise the vector** - a
basis carries the model's scale, so the dot product read 0.19 for a creature facing perfectly
forwards.

## The rules

1. **Name the direction of travel as one constant** and derive the camera, the track, every
   entity placement and every facing from it. One place to be wrong instead of nine.
2. **Every game gets one test that drives a real input event through the real handler and
   asserts where the avatar ends up ON SCREEN.** Not in world coordinates - world-coordinate
   assertions pass on inverted controls, which is the whole point.
3. **A suite made entirely of policies is a suite that tests only the simulation.** Whatever
   is between the finger and the sim, and between the sim and the pixels, has no coverage at
   all unless something drives those seams specifically.

## Replaces or contradicts

Nothing - it is the third time this studio has met this exact fault, which is the finding.
`CRAFT.md` had the rule and `PLAYER.md` had the precedent, and neither prevented it, because
the rule was written as advice about a convention rather than as a test that fails. It is a
test now.
