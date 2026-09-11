# A test that samples for a rare thing passes when the rare thing simply misses

**Coreward, 2026-09-10.** An ore that exists only below 372 m, at 0.12% of
cells. The test:

> the first world does not contain solmarrow

Verified by rule 11 - reintroduce the bug - by moving solmarrow's floor from
372 m to 20 m. **The test still passed.** The tutorial world is 754 cells, about
494 of them below 20 m, and 0.12% of 494 is 0.6 expected cells. Roughly half the
time the mutation generates none at all and the assertion is satisfied by the
rare roll missing, which is the thing it was supposed to catch.

The rarer the content, the weaker a sampling test gets - which is exactly
backwards, because rare content is where a generation bug hides longest.

## What to do instead

**Test the invariant, not the sample.** The real guarantee was "no cell above a
material's floor ever holds it", which is absolute and cannot be satisfied by
luck:

```js
for (const [x, d] of everyCell(worlds)) {
  const o = oreAt(x, d);
  if (o && d < o.min) fail(o.id + ' at ' + d + ', above its floor of ' + o.min);
}
```

**And split the guard by what it can actually see.** The invariant belongs to
the generator; the floor VALUES belong to a golden of the table. Neither test
can catch the other's bug and both are cheap. With the split in place, moving
one ore 350 m shallower failed eight different unit tests immediately.

**If you must assert on a sample, assert on a lot of it, and on a rate.** "Over
four worlds, solmarrow is under 0.4% of cells" is a claim a sample can support.
"This one world does not contain it" is not.

## The general shape

This is the third time in one project that a check passed because nothing had
happened rather than because the right thing had: a broken asset search that
returned zero results, a probe that mined outside the world, an image converter
that produced blank files. Each time the tool was fine and **the test could not
tell "correct" from "empty"**.

Related: [[a-case-is-not-a-point]], [[the-fix-that-never-ran]].
