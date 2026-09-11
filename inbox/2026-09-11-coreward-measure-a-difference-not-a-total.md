# To prove a canvas layer drew, measure a difference - not a total

**Game:** Coreward (web, three.js) · **Date:** 2026-09-11 · **Topic:** testing

Testing that a canvas screen actually rendered. Three versions, two worthless,
and all three were checked the same way: by deleting the layer and seeing
whether the test noticed.

**v1 - count pixels that are not the background.** Passed. Then the design
gained a survey grid drawn across the WHOLE canvas on purpose, including the
unexplored part - and the count stopped meaning anything. A screen that had
drawn nothing but its own graph paper would have passed it.

**v2 - count pixels matching the layer's colour range.** Also passed with the
layer deleted. Three full-width 50 m ruler lines are wide, coloured enough to
fall inside the range, and cleared the threshold on their own.

**v3 - a difference, at known positions.** Read the brightness at the centre of
a tile the player HAS surveyed and at the centre of one they have not, on the
same canvas at the same scale, and require a gap:

```ts
expect(lit - dark,
  `a surveyed tile reads ${lit} and an unsurveyed one ${dark} - the wash is not drawn`)
  .toBeGreaterThan(6);
```

Nothing but the wash can satisfy that. Tiles containing a tunnel cell are
excluded from both samples so the brighter tunnel layer cannot answer for it.

## A related trap in the same test

Checking the tunnel layer by sampling every dug cell and taking the BRIGHTEST
one also passed with every tunnel deleted - the player's ship marker is drawn on
top of a dug cell by definition, so one amber dot was the maximum. **Use the
median.** A median cannot be moved by the two or three cells a marker covers.

## The rule

**A measurement taken over a whole picture can be satisfied by the wrong part of
the picture.** When a pixel assertion passes with the feature deleted, the fix is
never a bigger threshold - it is a narrower question: a named position, a
control sample, or a statistic that a handful of pixels cannot move.

See also `a-case-is-not-a-point`, `the-fix-that-never-ran`,
`a-rare-thing-cannot-be-tested-by-sampling`.
