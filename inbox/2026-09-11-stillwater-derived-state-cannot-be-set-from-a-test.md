# A test that writes DERIVED state measures nothing, and reads as the feature being missing

**Stillwater, 2026-09-11.** Three checks in one afternoon failed the same way, and each one
looked like a broken feature rather than a broken test.

```gdscript
main._dread = 1.0                      # recomputed by _sync_mood on the next call
main._boat_pose.origin += Vector3(12, 0, -7)   # recomputed by _sync_boat_pose
```

Both are outputs, not inputs. The assignment survives until the next frame of the thing that
derives them - which is the very next line, because the check then advances the game to
observe the effect. So the measurement reports the *unchanged* value, and reports it as a
number:

> the sky over the quarry is the same as the sky over the reeds (0.01 against 0.01)

That is indistinguishable from the feature not existing. I nearly went and re-plumbed a
shader that was already correct.

**Drive the INPUT the derivation reads.** `_dread` comes from `sim.lure_depth` and the state,
so the fix is to set those and let the game arrive at the dread itself - which also tests the
derivation, for free:

```gdscript
main.sim.state = Sim.WAITING
main.sim.lure_depth = Audio.DREAD_FULL
for i in 600:
    main._sync_mood(1.0 / 12.0)
```

**When the input has no scenario, assert the RELATIONSHIP instead of faking the input.** The
boat never actually moves in world space - the lake is re-dressed around it - so "the foam
follows the boat" was a test of something the game does not do. What is load-bearing is that
the foam collar sits *ahead* of the boat's origin along her own axis, which catches the
mistake genuinely available there: Godot's node forward is -Z, and taking that sign the wrong
way rings the water astern of the transom while still looking plausible in a screenshot taken
over the bow.

**And the tell that it is this bug and not a real one: the two numbers are equal.** A feature
that is wired but wrong gives you two different wrong numbers. Two *identical* numbers, when
you have just set one of them yourself, means your write never landed.

Related: [[an-instrument-is-code-and-can-be-wrong]], [[measure-do-not-guess]]
