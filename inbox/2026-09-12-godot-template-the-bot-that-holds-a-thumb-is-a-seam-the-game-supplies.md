# The filmed policy run belongs in the template, and the part only the game knows is one method: `bot_drag_pixels`

**Game:** godot-template (built from wildform's version)  **Date:** 2026-09-12
**Belongs in:** TESTING.md beside the filmed-run rule, and `techniques/filming-a-run.md` for the contract

## What happened

The 2026-09-12 digest folded a rule saying **every game gets one filmed scenario driven by a policy
through the real input handler**. When it was written, exactly one game could do that. Wildform had
the mode, its `replay_player.gd` was 288 lines ahead of the template, and the other four Godot games
had no `replay_player.gd` policy mode at all. **A rule that no scaffolded game inherits is the
failure this framework was repaired for**, so it was ported into `godot-template`.

Wildform's version could not be copied. It reads `sim.target_x`, `sim.steering`, `Policies.steer`
and `Tuning.LANE_HALF_WIDTH * 3.4` - four things only that game knows. The port therefore had to
find the seam rather than move the code.

## The rule

**Split it so the driver is generic and the game supplies one method.**
`scripts/replay_player.gd` owns everything that is the same in every game: the `policy=<name>` arg,
the frame gate, the clamp on how fast a thumb moves (54 px per physics frame, 1080 px in a third of
a second at 60 Hz), building the `InputEventScreenDrag`, and pushing it at the viewport. The game
supplies:

```gdscript
## Required. The drag, IN PIXELS, the real handler would need this frame to get
## where the named policy wants to be. Must not leave the simulation changed.
func bot_drag_pixels(policy: String, mem: Dictionary, span: float) -> Vector2

## Optional. False during an interlude and after the run is over.
func bot_can_drive() -> bool
```

The driver finds the game by `has_method("bot_drag_pixels")` rather than by a class or a node name,
so the seam can live on the main scene or on a rig node, and **it refuses loudly once when nothing
implements it** - silence there is a filmed run of a game nobody is playing, which looks exactly
like a filmed run of a game that ignores input.

Three details are load-bearing, all three learned on wildform:

- **Write the pixel conversion from the handler's own constants, inverted.** The template's
  `drag_by` does `dx / span * Tuning.LANE_HALF_WIDTH * 3.4`, so `bot_drag_pixels` does
  `world_dx * span / (Tuning.LANE_HALF_WIDTH * 3.4)`. A measured fudge factor drifts the moment the
  control is retuned, and a bot that steers almost right films a plausible run of a broken game.
- **Put the simulation back.** `Policies.steer` mutates the sim, so the wanted target is read and
  the old one restored. Left set, the bot takes the shortcut AND films it, which is the exact thing
  the seam exists to stop.
- **Clamp to what a thumb can do in one frame**, or it teleports and the film says nothing about
  whether the control is reachable.

**And the seam gets its own gate.** `test/test_replay_policy.gd` asserts the method exists, that
asking does not move the sim, that a policy which wants nothing asks for nothing, and - the one that
matters - that **the drag the bot asks for, pushed through the real handler, leaves the policy with
nothing left to ask for**. That last one is a property rather than a restatement of the formula, so
it cannot pass with the conversion wrong in both places, and it catches an inverted control without
naming one: a wrong sign moves the avatar the other way and the second ask comes back LARGER.

## Replaces or contradicts

Completes the TESTING.md line folded this morning, "**And every game gets one FILMED scenario driven
by a policy through the real input handler**", which stated the rule while only one game could obey
it. The template now carries the driver, the contract and the gate, so a scaffolded game inherits
all three.

**It does not yet reach the four existing games.** candle-gift, gravewell, stillwater and
wrecking-crew each need their own `bot_drag_pixels`, and none of them has the template's `drag_by`:
each grew its own control seam under its own name, so each is a small bespoke job of inverting that
game's own arithmetic and adding the gate. Wildform has the behaviour already and should be moved
onto the template's contract so there is one shape rather than two. Until then the rule is inherited
by new games and owed by five old ones, and that is worth saying out loud rather than leaving as a
green check.
