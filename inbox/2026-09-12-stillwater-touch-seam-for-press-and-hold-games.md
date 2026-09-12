# A game played by pressing supplies bot_touch_pixels (a point for down, Vector2.INF for up) beside bot_drag_pixels, reads its verbs from a read-only Policies.wants that act also applies, and the driver lifts the thumb whenever it may not drive.

**Game:** stillwater  **Date:** 2026-09-12  **Belongs in:** techniques/filming-a-run.md / The live-policy seam: `policy=<name>` and `bot_drag_pixels`

## What happened

The filmed-policy seam in godot-template (`scripts/replay_player.gd policy=<name>`) only knew how to DRAG: the game supplied `bot_drag_pixels(policy, mem, span)` and the driver pushed an InputEventScreenDrag. Stillwater is played entirely by pressing and holding one button (hold to load the cast, let go to throw, press to strike, hold to reel, a second button to put a fish back), so a faithful port would have been a `bot_drag_pixels` returning zero forever - the exact inert seam the gate exists to catch. The template driver now also accepts an optional `bot_touch_pixels(policy, mem, size) -> Vector2` from the game: where the thumb is DOWN this frame in viewport pixels, or `Vector2.INF` for up. The driver turns the EDGES into real InputEventScreenTouch presses and releases on finger index 1 (finger 0 stays the drag thumb, because the GUI routes a drag to whichever control its finger went down on), lifts the thumb whenever `bot_can_drive()` refuses (left down through a cinematic, the next press it wants is one it already holds, no event fires, and the run stalls under a thumb that never lifts), and treats a point that moved to a different control as a lift now and a press next frame. Game side, Stillwater split `Policies.act` into a read-only `Policies.wants(...) -> verb` plus `Policies.apply(verb, sim)`, so the filmed bot reads the same verb the balance bots act on without touching the sim; a one-frame press (strike, keep) is a point now and INF next frame via a `bot_lift` key in `mem`, so a second press on the same button (strike, then hold to reel) is a new press rather than a thumb that never lifted; the bot reads the button's caption ("No room", "Too big") and takes the other button, like a player; and the title's own entry button is pressed once rather than bypassed. A pushed InputEventScreenTouch on index 1 does press a Button through `Viewport.push_input(ev, true)`: the film shows the bot crossing the gate, casting, striking on the float with the caption reading Strike, and holding Reel through a fight with the distance meter live. The gate is `test/test_replay_policy.gd` in the pure suite: it boots main.tscn off-tree (1.3 s), drives ANGLER through the buttons' own signals until a fish is landed, asserts a bot that never strikes lands nothing, that asking never changes `state_snapshot()`, and that a loaded rod stays under the thumb until the policy throws.

## The rule

A game played by pressing supplies `bot_touch_pixels` (a point for down, `Vector2.INF` for up) beside `bot_drag_pixels`, reads its verbs from a read-only `Policies.wants` that `act` also applies, and the driver lifts the thumb whenever it may not drive.

## Replaces or contradicts

**In techniques/filming-a-run.md, lines 107-110:**
"**Owed, not yet paid.** candle-gift, gravewell, stillwater and wrecking-crew each grew their own control seam under their own name, and none has the template's `drag_by`: each needs its own small bespoke `bot_drag_pixels` and gate. Wildform has the behaviour already and should move onto the template's shared contract so there is one shape rather than two."

**In TESTING.md, lines 67-68:**
"Wildform has the behaviour bespoke; candle-gift, gravewell, stillwater and wrecking-crew still owe their own seam."
