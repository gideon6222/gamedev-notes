# Replacing menus with objects in a room runs out of ANGLES before it runs out of ideas

**Stillwater, 2026-09-11.** Four screens became four things you look at in a rowing boat -
the logbook, the tackle box, a chart, and the oars that row you to the shop. The design was
right and the last two were most of the work, for a reason that was not obvious until it bit:

**The seat is a fixed point, so every interactable competes for angular space.** This game's
own rule is that no two things may sit within 12 degrees of each other from the seat,
otherwise the crosshair cannot pick between them. Seven objects in a four-metre boat is
already tight, and the eighth failed against three different neighbours in a row.

**An object's hit box is its whole silhouette, so LONG things are expensive.** A pair of oars
is 1.34 m. Stowed flat along the port side - where oars actually live - the box spanned half
the boat and sat six degrees from the livewell. Every position along that side failed the
same way, because the problem was the length and not the place. Stood on end in the bow the
footprint is a hand's width and it passed first try.

**Plan the angular budget the way you would plan a screen layout.** Before adding a thing to
a diegetic menu, ask what it costs in degrees from the one place the player sits, not where
it looks natural. Short and upright is cheap; long and flat is not.

**And three smaller things worth keeping, all from the same afternoon:**

- **Give the game ONE `close_any_room()` and one `any_room_open()`.** The smoke suite broke
  twice in an hour because a check that opens each interactable in turn kept its own list of
  what might need closing, and the list went stale each time a room was added. The suite's
  failure mode is vicious: the next six checks fail looking for a cast button and a distance
  meter, and nothing points at the check that actually left the door open.
- **When a menu becomes a surface in the world, check its READING DISTANCE with arithmetic.**
  Visible width is about `d * tan(fov/2) * aspect * 2`; on a portrait phone the aspect term is
  0.46 and murders you. A 1.06 m chalkboard needs 2 m of standoff, and at 0.9 m the left half
  of every line was off the screen.
- **Normalise object scale by measured bounds, not per-prop guesses.** A shop counter with a
  hand-picked scale per item had a crate three times the reel beside it. One line - scale so
  the largest dimension is N - fixed it for every prop, including ones not added yet.

Related: [[a-screenshot-proves-one-state]], [[measure-do-not-guess]]
