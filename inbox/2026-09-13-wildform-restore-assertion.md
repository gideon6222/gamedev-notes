# A restore assertion placed after a loop of unrestored calls asserts nothing

**Game:** wildform  **Date:** 2026-09-13  **Belongs in:** TESTING.md / assertions that cannot fail

## What happened

wildform ported the template's generic bot seam. `Main.bot_drag_pixels(policy, mem, span)` asks a scripted policy where it wants to steer and must put the simulation back exactly as it found it, because the whole point of the seam is that the bot drives through the real touch handler rather than taking the shortcut. wildform's `Sim.steer_to()` writes TWO fields, `target_x` and `steering`, so the seam restores both.

`test/test_replay_policy.gd` reached a frame the policy wanted to steer on by calling `bot_drag_pixels` in a loop (up to 600 frames), then read `was_steering = main.sim.steering`, asked once more, and asserted the field was unchanged.

Verified by reintroducing the bug (the studio rule): deleting `sim.steering = was_steering` from `bot_drag_pixels` left the suite GREEN. The reason is that every ask inside the search loop had already left `steering` true, so `was_steering` was read as true and the assertion compared true to true. The loop poisoned the very state the check was made of.

The fix: set the field to a known value immediately before the call under test - `main.sim.steering = false`, then ask, then assert it is still false. With that one line the same reintroduced bug fails loudly. The companion `target_x` half was already covered by a different assertion ("asking twice with the world unchanged must give the same answer"), which is why only one of the two restores was silently untested.

Three other reintroduced bugs in the same file did go red without help: dropping the `target_x` restore, inverting the sign of the pixel conversion, and dropping `not sim.over` from `bot_can_drive()`.

## The rule

When a test asserts that a call LEAVES something alone, set that something to a value of your own choosing on the line before the call. Never read the "before" value out of state that the test's own setup loop has been writing to - a setup that drives the same method under test leaves it already holding the answer, and "unchanged" is then true of a seam that restores nothing.

## Replaces or contradicts

nothing
