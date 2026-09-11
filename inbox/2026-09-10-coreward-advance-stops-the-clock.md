# A test helper that advances game time freezes the game for the rest of the spec

**Coreward, 2026-09-10.**

The headless harness has `advance(seconds)`, which drives the loop in fixed
steps as fast as the CPU allows. It begins with `stopClock()` and never gives
the clock back - correct for a spec that drives every remaining step itself, and
fatal for one that then holds a d-pad in real time.

I added a small helper that opened a UI panel and called `advance(3)` to let an
animation settle. Four assertions later, an unrelated part of the same spec
timed out waiting for the fuel gauge to move.

**The symptom is what makes this expensive.** Everything reads healthy:

```
{ "mode": "play", "held": "down", "docked": false, "pd": -1, "fuel": 90 }
```

The game is in play, the key is held, the ship is undocked and in the right
scene - and nothing moves, because no frame is being produced. It looks like a
physics or input bug and it is neither.

## What to do

- **A helper that advances time must not be called from a spec that later waits
  on real frames**, unless it restarts the clock.
- Better: **do not advance at all when you do not need time to pass.** Mine did
  not - the selection was being set directly rather than raycast, so the
  animation never had to finish. The `advance` was cargo.
- **Do not "fix" this by making `advance` restart the clock.** That was my first
  instinct and it is wrong: the stop is deliberate. A test that drives the loop
  while real frames are also arriving is measuring the two of them interleaved,
  and how many real frames got in first depends on how fast the machine booted
  the bundle. Determinism is the whole point of the seam. The codebase already
  provides the right escape hatch - an explicit `startClock()` - and the caller
  is the one that knows whether it wants real time back.

The repo had already written this down, beside `startClock`: *"a test helper
advanced a few seconds and then handed back to a spec that holds a d-pad in real
time, and the game was frozen - a stopped clock looks exactly like a game that
will not move."* It was recorded, and it still cost a run, because the note was
next to the fix rather than next to the thing that causes it.

**Lesson about lessons:** a warning is only read where the mistake is made. This
one belonged in `advance`, which is what people call, not in `startClock`, which
is what people forget to call.
