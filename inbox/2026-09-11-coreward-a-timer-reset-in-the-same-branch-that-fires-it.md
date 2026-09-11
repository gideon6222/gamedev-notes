# A timer that resets in the same branch that fires it runs your code once

**Game:** Coreward (web, three.js) · **Date:** 2026-09-11 · **Topic:** testing, engine traps

A very common shape for "do this a few times a second, not every frame":

```ts
R.timer -= dt;
if (R.timer <= 0) {
  R.timer = 0.35;
  recomputeTheExpensiveThing();
}
```

New work was added NEXT TO that block rather than inside it, guarded on what
looked like the same condition:

```ts
if (R.timer <= 0 && !atSurface()) {      // <-- runs once, ever
  recordWhatTheLampHasShownYou();
}
R.timer -= dt;
if (R.timer <= 0) {
  R.timer = 0.35;
  ...
}
```

`R.timer` is reset to 0.35 in the same frame it expires, so at the TOP of the
block it is only ever `<= 0` on the first frame of the session. The new code ran
once and never again.

**Why it was hard to see:** the feature was a map filling in as you explore. A
map that records one sample and stops looks exactly like a map you have not
explored yet. There is no error, no warning, and the feature is "working" in the
sense that something did appear on it.

## The lesson

**Periodic work belongs inside the branch that does the reset, not beside it.**
If two pieces of code want the same tick, they share one `if`. A second `if`
testing the same variable is testing it at a different point in its cycle.

## And the test that catches it

Not "did anything get recorded" - one sample satisfies that. Assert the **span**
of what was recorded against the distance travelled:

```ts
// 40 m of descent is ten four-metre tile rows. A recorder that fired once
// leaves the three the lamp reaches from a single point.
expect(trail.hi - trail.lo).toBeGreaterThanOrEqual(8);
```

Verified by putting the original code back: it reported `rows 0..0`, which named
the bug in the failure message.
