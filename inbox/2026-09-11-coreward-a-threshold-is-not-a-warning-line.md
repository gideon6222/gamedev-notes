# The threshold an action unlocks at is not the level the alarm goes off at

**Game:** Coreward (web, three.js) · **Date:** 2026-09-11 · **Topic:** design, polish

A resource meter with two constants that got collapsed into one:

- `BALLAST_SAFE = 0.7` - the level at which a **repair action becomes
  available**
- the level at which the reading turns **red and the button pulses**

Both readouts were written against `BALLAST_SAFE` because it was the constant
that existed. The result: a tank at a perfectly ordinary 60% drew red, and the
HUD button sat there pulsing for most of the meter's normal operating range.

**An alarm that is on most of the time is not an alarm.** It is decoration, and
worse than decoration, because it trains the player to ignore the one channel
that was supposed to interrupt them.

## The fix, and how to pick the number

A second constant, and pick it from **how much time the warning buys**, not
from where the bar looks nice:

```
BALLAST_LOW = 0.35   // about three runs of warning at ordinary drain
```

Enough to do something about it, not so much that it is wallpaper before it
matters. The comment says that, because the next person to look at 0.35 will
otherwise round it to a half.

## The general shape

When a single number is doing two jobs, ask what each job's number is *for*:

| job | chosen from |
|---|---|
| an action unlocks | what the action should cost / how rare it should be |
| an alarm fires | how much time the player needs to react |
| a colour changes | where the reading stops being ordinary |

They are almost never the same value, and a shared constant makes the
disagreement invisible. Related: **one source of truth per FACT**, not per
number - two different facts that happen to have had the same value are two
constants.
