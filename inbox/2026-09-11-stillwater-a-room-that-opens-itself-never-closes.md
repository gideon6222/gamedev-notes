# An object that opens itself at build time has no one to close it

**Stillwater, 2026-09-11.** Gideon, from a screenshot: *"it looks like the book is on the
ground but the pages are in the air on the left."* Neither half was the book.

A third openable object was added to a boat that already had two. The other two open when you
use them; this one called `open()` in its **constructor**, because at the time it had no
"open" gesture and its surface needed to be visible for a screenshot. Nothing ever closed it.
So its page - a SubViewport quad, deliberately `shading_mode = UNSHADED` so it stays readable
at night - sat printed on a thwart in the middle of the boat, glowing, through every hour of
the game.

**It was invisible in review for a structural reason: the call that caused it was in a
different function from the one that should have undone it.** Reading `_open_chart` and
`_shut_chart` side by side, they are a matched pair and obviously correct. The bug is in
`_build_chart`, forty lines away, and it is a single line that looks like setup.

**The instrument that found it in one run** prints, for every openable thing in the scene,
its model, its surface, the distance between them, and *whether the surface is on*:

```
logbook   model (-0.26, 0.32, 1.30)  page (-0.24, 0.34, 1.29)  surface_on false
chart     model ( 0.58, 0.49, 2.22)  page ( 0.58, 0.50, 2.22)  surface_on true   <-- shut!
tacklebox model ( 0.14, 0.33, 1.52)  page ( 0.14, 0.54, 1.52)  surface_on false
```

The value of the table is the COLUMN, not the row. One object's state is unremarkable; three
of them side by side makes the odd one out obvious instantly. Worth building the moment a
second instance of anything exists.

**The rule: state that is entered in a builder has no natural exit.** If an object has an
open/closed state, the builder sets the CLOSED one and the only paths in and out are the pair
of functions named for them. A builder that opens something is a `new` with no matching
`free`.

**And the same probe answered the second half of his note** - "planks and sticks sticking up
on the right" - by showing the oars' hit box was the whole 1.3 m oar, which is why they had
been stood on end to satisfy an aim-separation rule. See
[[diegetic-menus-run-out-of-angles]].

Related: [[a-screenshot-proves-one-state]]
