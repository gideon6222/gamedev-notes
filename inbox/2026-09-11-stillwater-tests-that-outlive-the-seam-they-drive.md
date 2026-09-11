# When a control changes, the tests that drove the old one keep passing and stop testing

**Stillwater, 2026-09-11.** The fight changed from tapping to holding. `Sim.tap()` kept its
name and became a documented no-op while FIGHTING:

```gdscript
FIGHTING:
    # NOTHING. The fight is held, not tapped - see `set_reeling`.
    pass
```

A smoke check called "a lost fish returns the player to the boat" drove the fight like this:

```gdscript
for i in int(round(25.0 / step)):
    main.sim.tap()
    main.sim.tap()
    main.advance(step, step)
_t.eq(main.sim.state, Sim.LOST, "holding the thumb flat out never ends the fight")
```

It was applying **no input at all** and waiting to see whether a fish would lose itself. It
passed for as long as the old numbers happened to let a fish escape unaided, then failed the
day the escape margin widened - which is the first time anyone learned it had stopped
testing anything.

It was also asking its question **in the tutorial band**, which is built to forgive exactly
the mistake the test was trying to make. Once it was driving real input, it still could not
break a line there, correctly. A claim has to be measured in water where it is supposed to
hold.

Two more in the same suite, found by the same sweep:

- A check that "loading a cast does not bend the rod" measured TOTAL bend, which includes the
  rod trailing the boat's swell. It passed or failed on where the swell happened to be when
  it ran, and it broke because a change to the FIGHT altered how many frames the earlier
  checks took and left the boat on a different part of its cycle. The claim is a
  **difference** - bend at low charge against bend at full - not an absolute.
- A latency check asserted that one frame of holding raises the tension. By then the fight
  had settled at its settle point, where holding changes nothing, so correct behaviour failed
  the test. Release first, then measure.

**The rule:** when an input seam changes, grep the tests for the OLD seam before changing
anything else. A no-op that keeps its name is worse than a deleted one - a deleted method
fails loudly, a no-op lets every caller keep passing while measuring nothing. If a stand-in
must survive for a while, make it increment a counter the tests can assert on.

Related: [[a-construct-that-cannot-fail-is-untested]], [[delete-the-stand-in-in-the-same-commit]]
