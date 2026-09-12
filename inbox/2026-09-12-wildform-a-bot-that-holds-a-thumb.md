# A bot that holds a thumb: drive the filmed run through the real touch handler, not through the sim

**Game:** wildform  **Date:** 2026-09-12  **Belongs in:** `TESTING.md` under filmed runs and
policies, and `techniques/` as the recipe below.

## What happened

This studio's scripted policies all drive a game by calling its steering function directly.
That is what let wildform ship with inverted controls through five releases, and the lesson
filed then named the gap exactly: *"the one thing no bot in this studio does is hold a thumb."*

It is about thirty lines to close, and closing it paid immediately.

The replay autoload gained a `policy=<name>` mode. Each physics frame it asks the policy where
it wants to be, **puts the sim's steering state back the way it was**, converts the difference
into pixels using the touch handler's own arithmetic inverted, and pushes a real
`InputEventScreenDrag` at the viewport:

```gdscript
var was_target := sim.target_x
var was_steering := sim.steering
Policies.steer(_policy, sim, _policy_mem)
var wants := sim.target_x
sim.target_x = was_target          # undo it - the point is to go through the handler
sim.steering = was_steering

var px := (wants - was_target) * span / (Tuning.LANE_HALF_WIDTH * 3.4)   # the handler's own maths
px = clampf(px, -MAX_DRAG_PIXELS, MAX_DRAG_PIXELS)                       # 54 px/frame = a brisk thumb
var d := InputEventScreenDrag.new()
d.relative = Vector2(px, 0.0)
get_viewport().push_input(d, true)
```

Two details are load-bearing. **Write the pixel conversion from the handler's own constants**,
inverted, so a change to the control changes the bot with it rather than silently desyncing.
And **clamp to what a thumb can actually do in one frame** - unclamped it teleports, and a film
of a teleporting creature tells you nothing about whether the control is reachable.

## What it caught on the first run

A filmed 75-second run showed the evolution transform **covering the whole screen for 5.08
seconds, three times** - a fifth of the run unreadable. Every one of 4,800 assertions passed
through that, because they all drove the sim and none drove the picture. The player had already
reported the game as "difficult to understand what is going on" and this was a large part of
why.

## The rule

**Every game gets one filmed scenario driven by a policy through the real input handler**, not
only replays of recorded touches and not only policies that call the steering function. It is
the only artefact that exercises the whole chain - finger to handler to sim to camera to pixels
- for minutes at a time, and it is cheap: one mode on the replay player, reusable for every
scenario the game already has.

Recorded touch replays do not replace it. They are fixed sequences that stop being valid the
moment the layout moves; a policy adapts, so one line of `-UserArgs policy=reader` films any
build for as long as you like.

## Replaces or contradicts

Completes `2026-09-11-wildform-a-policy-that-calls-steer-to-is-not-a-test-of-the-control.md`,
which diagnosed the gap and prescribed two assertions. The assertions catch an inverted axis at
one instant; this catches everything that goes wrong over a minute of play, and the two
together are what that lesson was reaching for.
