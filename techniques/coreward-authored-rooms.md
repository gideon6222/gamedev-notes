# Authored mystery in a seeded world: room templates, locked doors, and a map you can read

**Coreward, 2026-09-11.** The research question was "how do you get authored mystery into a
seeded world", and only one answer survives: **hand-written room templates dropped at seeded
slots.** Spelunky stitches rooms; Noita drops hand-placed structures into generated terrain;
Animal Well's layered secrecy is seven years of hand placement and does not translate.

**Read when:** a procedural world needs places that feel made rather than rolled; a fog-of-war
or survey map that reads as broken; a locked-behind-a-tool gate in a generated world.

**Takeaways:** (1) a room is a drawing and belongs in the source file as one; (2) a half-stamped
room is a wall with no room behind it, so drop colliding rooms entirely; (3) unknown ground
drawn as ruled squares is an invitation, and drawn as black is a rendering bug.

---

## Write rooms as drawings, in the source file

```ts
const ANCHOR_HALL = {
  rows: [
    '  #######  ',
    ' ##.....## ',
    ' #..#.#..# ',
    ' #..#A#..# ',
    ' #..###..# ',
    ' ##.....## ',
    '  #######  '
  ]
};
```

`#` cut stone, `=` stone you cannot cut yet, `.` air, `A` the objective, space = leave the
generator alone. A room should be legible as a drawing in the file it lives in. Every template
the same size costs a few spaces in the source and saves the stamping code from ever thinking
about it.

## Stamp AFTER every singleton, BEFORE everything that generates

Order in the block lookup: (1) the cells that are one-of-a-kind on the whole world - a relic, a
key item, which a room stamped over DELETES forever; (2) the room stamp; (3) caves, pockets,
ore, rock. A crate embedded in a room's wall reads perfectly well. A crate that does not exist
reads as nothing at all.

## Build the stamp once, as a Map

Testing 25 rooms against every cell of a streaming rebuild is 18,000 box tests a frame.
Building `Map<"x,d", char>` once is 25 x 99 entries and then a `get`.

## Drop a colliding room entirely; never clip it

A half-stamped room is **a wall with no room behind it** - the player cuts through the one
authored surface in the game and finds rock, and the language of "worked stone means something"
dies on the spot.

And the test for the drop rule has to read the OUTPUT, not re-derive the rule: a test that walks
the same slots applying the same filter passes with the filter deleted. Export the placement
(`roomPlan()`) and assert against it - every room on the plan is stamped cell-for-cell, and no
two rooms on the plan overlap. A derived predicate is the same trap one level down: identifying
"was this room placed" by whether its centre cell is stamped is also true of a room that was
dropped, because the room it collided with covers that cell.

## Make at least a third of them empty

The named failure mode is templates you start to recognise. Rarity is one defence; the other is
that **finding one has to stay a question rather than become a reward.** If every worked room
holds something, the moment of "what is this" is over before you are through the wall.

## A locked door must never lock the world

Write the test that floods the entire world through everything that is not unbreakable, with
nothing unlocked, and asserts the deepest point is still reachable. Two claims no reachability
test catches:

- **the first one the player meets is never the locked one.** A door you cannot open is only a
  promise if you already know what doors are.
- **an unlocked room contains none of the locked material**, or "locked" stops being readable.

## The rule applies to furniture as well as doors

Coreward buried nine objectives as single unbreakable cells across only three columns. A cell
that never breaks is a permanent plug in its column: **six of the nine became unreachable by
digging to them**, and a long-play probe read it as a balance problem for four simulated hours
before the actual cause - impassable geometry, not difficulty - was found. **Anything permanently
impassable that sits INSIDE the route to later content will block that content**, the same "never
let a locked door lock the world" rule applied to furniture rather than doors.

A "you cannot cheat your way to this" rule only needs to hold until the thing is CLAIMED:
unbreakable while unclaimed, merely very hard (3x the local rock) after, because a claimed
monument in the way is one the player may move. Write the test that drives the player to **each**
instance in turn, never to one - the first nine-for-one probe would have missed the other five.

## The cheapest visual read: displacement, not texture

Every rock surface has a displacement amount - that is what makes five rock types differ. Cut
stone was given 0.03 against 0.16-0.40 for everything else. **A smooth face in a world with no
smooth faces in it.** One number, no new material, and it reads at play scale.

## The map: ruled squares, not black

A fog-of-war map drawn the obvious way - explored ground painted, everything else left as the
background colour - reads as **the map failing**, not as somewhere you have not been. On a phone
half a panel of flat black looks like a rendering bug or a screen that has not finished loading.

Two cheap changes, both drawn across the WHOLE world rather than only the explored part:

1. **A survey grid** at the map's own tile pitch, about 13% alpha. Unknown ground becomes empty
   squares on a chart, and an empty square on a chart is an invitation.
2. **A ruler** - a heavier rule and a depth label every 50 m. A world seen 120 m at a time needs
   a scale somewhere other than the header.

Same pixels, opposite reading: "nothing here" became "not surveyed yet".

**And a rendering trap found doing it.** Explored tiles were painted at `globalAlpha = 0.3` with
a fractional overlap to close the seams. Every overlap double-blends, so each seam came out
BRIGHTER than either tile, drawing a grid over the explored ground by accident, only where tiles
happened to be adjacent. It looked good, which is how it survived a first glance. **Darken the
colour in the maths and fill opaque** (`rgb(r*f, g*f, b*f)`), then draw the grid deliberately.

**Show a surveyed percentage.** The research on procedural mystery is specific that it degrades
into emptiness when there is no way to track partial progress against it, and one number in the
corner of the map is the cheapest possible version of that.

## Proving the map drew at all

Three versions of the test, two worthless, each checked by deleting the layer:

- **count pixels that are not the background** - passed with the layer deleted, once the survey
  grid was drawn across the whole canvas on purpose.
- **count pixels in the layer's colour range** - passed too; three full-width 50 m ruler lines
  cleared the threshold on their own.
- **a difference, at known positions** - read the brightness at the centre of a surveyed tile
  and at the centre of an unsurveyed one, on the same canvas at the same scale, and require a
  gap. Nothing but the wash can satisfy that. Exclude tiles containing a tunnel cell from both
  samples so the brighter tunnel layer cannot answer for it, and take the MEDIAN of a sampled
  layer rather than the brightest - the player's marker is drawn on top of a dug cell by
  definition, so one amber dot is the maximum.

**A measurement taken over a whole picture can be satisfied by the wrong part of the picture.**
When a pixel assertion passes with the feature deleted, the fix is never a bigger threshold - it
is a narrower question: a named position, a control sample, or a statistic a handful of pixels
cannot move.
