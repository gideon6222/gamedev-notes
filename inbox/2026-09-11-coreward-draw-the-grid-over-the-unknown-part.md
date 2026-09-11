# Unexplored map should be ruled squares, not black

**Game:** Coreward (web, three.js) · **Date:** 2026-09-11 · **Topic:** design, polish

A fog-of-war map drawn the obvious way - explored ground painted, everything
else left as the background colour - reads as **the map failing**, not as
somewhere you have not been. On a phone, half a panel of flat black looks like a
rendering bug or a screen that has not finished loading.

Two cheap changes fixed it, and both are drawn across the WHOLE world rather
than only the explored part:

1. **A survey grid** at the same pitch as the map's own tiles, at about 13%
   alpha. Unknown ground becomes empty squares on a chart, and an empty square
   on a chart is an invitation.
2. **A ruler** - a heavier rule and a depth label every 50 m. A world seen 120 m
   at a time needs a scale somewhere other than the header.

Same pixels, opposite reading: "nothing here" became "not surveyed yet".

## And a rendering trap found doing it

The explored tiles were painted at `globalAlpha = 0.3` with a fractional overlap
to close the seams between adjacent rects. Every overlap **double-blends**, so
each seam came out BRIGHTER than either tile - which drew a grid over the
explored ground by accident, only where tiles happened to be adjacent.

It looked good, which is how it survived a first glance. It was still an
accident and it was inconsistent.

**Darken the colour in the maths and fill opaque** (`rgb(r*f, g*f, b*f)`), then
draw the grid deliberately. Opaque fills have no seam to close and no accident
to inherit.

## The third thing worth stealing

Show a **surveyed percentage**. The research on procedural mystery is specific
that it degrades into emptiness when there is no way to track partial progress
against it, and one number in the corner of the map is the cheapest possible
version of that.
