# Stamping hand-authored rooms into a procedural world

**Game:** Coreward (web, three.js) · **Date:** 2026-09-11 · **Topic:** design, craft

The research question was "how do you get authored mystery into a seeded
world", and there is only one answer that survives: **hand-written room
templates dropped at seeded slots**. Spelunky stitches rooms; Noita drops
hand-placed structures into generated terrain. Animal Well's layered secrecy is
seven years of hand placement and does not translate.

What worked, as a recipe.

## Write rooms as drawings, in the source file

```ts
const ANCHOR_HALL = {
  rows: [
    '  #######  ',
    ' ##.....## ',
    ' #.......# ',
    ' #..#.#..# ',
    ' #..#A#..# ',
    ' #..###..# ',
    ' #.......# ',
    ' ##.....## ',
    '  #######  '
  ]
};
```

`#` cut stone, `=` stone you cannot cut yet, `.` air, `A` the objective, space
= leave the generator alone. A room is a drawing and should be legible as one
in the file it lives in. Every template the same size costs a few spaces in the
source and saves the stamping code from ever thinking about it.

## Stamp AFTER every singleton, BEFORE everything that generates

Order in the block lookup:

1. the cells that are one-of-a-kind on the whole world (a relic, a key item) -
   a room stamped over one of those DELETES it forever
2. the room stamp
3. caves, pockets, ore, rock

A crate embedded in a room's wall reads perfectly well. A crate that does not
exist reads as nothing at all.

## Build the stamp once, as a Map

Testing 25 rooms against every cell of a streaming rebuild is 18,000 box tests
a frame. Building `Map<"x,d", char>` once is 25 × 99 entries and then a `get`.

## Drop a colliding room entirely; never clip it

A half-stamped room is **a wall with no room behind it** - the player cuts
through the one authored surface in the game and finds rock, and the language
of "worked stone means something" dies on the spot.

## Make at least a third of them empty

The named failure mode is templates you start to recognise. Rarity is one
defence; the other is that **finding one has to stay a question rather than
become a reward**. If every worked room holds something, the moment of "what is
this" is over before you are through the wall. There have to be rooms that are
just rooms.

## A locked door must never lock the world

If some rooms are sealed behind a tool, write the test that floods the entire
world through everything that is not unbreakable, with nothing unlocked, and
asserts the deepest point is still reachable. One of ours sits directly across
the main shaft - which is a good moment, because you can go round it. It would
have been the end of the game if you could not.

And two claims that no amount of "is it reachable" catches:

- **the first one the player meets is never the locked one.** A door you cannot
  open is only a promise if you already know what doors are.
- **an unlocked room contains none of the locked material**, or "locked" stops
  being a thing the player can read.

## The cheapest visual read: displacement, not texture

Every rock surface in that game has a displacement amount - that is what makes
five rock types differ. Cut stone was given 0.03 against 0.16-0.40 for
everything else. **A smooth face in a world with no smooth faces in it.** One
number, no new material, and it reads at play scale.
