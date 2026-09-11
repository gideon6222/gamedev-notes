# A harness that measures positions cannot judge a composition

**Coreward, 2026-09-10, round six.**

Built a Playwright harness that projects every object in a 3D shop into screen
pixels and compares it against the HTML chrome laid over the same canvas. It
found the real fault in one run: the room was framed for the whole canvas while
the tray covered 40% of it, so the front row of display cases landed at y 461
with the tray starting at 470.

Then it passed a layout with two of five name plates hanging half off the
screen.

**Why: it compared projected CENTRES against a 24-pixel margin, and the plates
are 136 pixels wide.** Every centre was comfortably inside a frame that two
plates were falling out of. The same blind spot passed a terminal a third of
which was off the left edge.

Five more faults only a screenshot could state, all in the same room, all after
the numbers had gone green:

- a light pool sized off its tube's LENGTH in both axes, fogging a whole counter
- imported wall panels one metre tall sitting on the deck, so everything above
  waist height floated in black with nothing for a light to land on
- the ambient left at a workshop's 1.15, drowning every neon in the room
- a selection panel that was a hard-edged rectangle, visible behind all five
  cases at once
- the DOM printing a label directly on top of the 3D sign already saying it

## What to do

**Keep both, and know what each is for.** The numbers say what is provably
wrong - a thing under a tray, a light count over budget, a case that is not in
the scene. The picture says what is actually wrong. This round needed six passes
of the second after the first had gone green.

**Measure BOUNDS, not origins.** `new THREE.Box3().setFromObject(mesh)`, project
all eight corners, take the screen-space rect. It is four more lines and it is
the difference between a test that would have caught this and one that shipped
it. Anything that carries text needs this: a label's origin is nowhere near its
edges.

**Demand a margin, not a boundary.** `x > 0` passes for a plate flush with the
edge, which reads as unfinished. Six pixels is enough to make the assertion mean
what you meant.

Related: [[check-the-converted-file-not-the-command]] is the same shape one
level down - the tool succeeded, the output was unusable, and nothing looked.
