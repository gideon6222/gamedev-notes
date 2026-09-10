# Coreward: the shop as a room, and the instruments on the HUD

**Game:** Coreward (web / three.js) · **Status:** shipped; the shop went panel → styled panel → list → room over four playtest rounds · **Read when:** a shop, upgrade screen or menu that keeps reading as a pop-up; laying out 3D for a portrait phone; sizing labels, gauges and controls on a textured world; a row that is grey for the wrong reason

Coreward's shop began as a panel over the game, was restyled, became a scrolling list on a
painted background, and finally became a second scene: a station room the player stands in,
with the real ship reparented into the middle and the upgrade parts displayed on plinths in
vertical columns. This file keeps that design and the arithmetic that shaped it (a 46-degree
vertical field at a 0.46 aspect is about 22 degrees horizontal; a 0.66-unit plate is about
70 px, a six-character word), together with the HUD lessons from the same game: readouts
beside the thumb, SVG gauges with `pathLength`, needles with mass, a rolled-steel plate with
generated grain, pressed buttons that go in rather than light up, and the shop rows that
looked disabled when they were merely not controls.

**Generalisable takeaways**

- **If the player is meant to feel they are somewhere, the somewhere has to be geometry.**
  A panel over the game is a pop-up however it is styled; a list is a list. Show the real
  object, not a preview, so the shop and the world cannot disagree.
- **Compute the visible width at the distance a thing sits before choosing where to put it or
  what to write on it.** Portrait's horizontal cone is tiny; labels are sized by the pixels
  they will occupy, not by the words you want.
- **Placement beats paint; a control should read as pushed in; enabled/disabled and
  control/content are two different axes.** Say an availability state three ways, order the
  states deliberately and test the order, and take a picture of every screen once.

---

## From panel to room

**A panel over the game is a pop-up however you style it.** Leaving half the world visible behind
a shop says "you are still out there". Hide the game entirely, give the screen a window that looks
out on where the player actually is, and put the exit at the bottom where a door would be.

**And a list is a list however you style it.** That fix was still a scrolling list of rows on a
painted background, and the next note was to make it a room. A second scene - the shop drawn as
somewhere you stand, with the goods on pedestals - costs one extra Scene and camera and reuses
every material the game already has. The rule underneath: **if the player is meant to feel they
are somewhere, the somewhere has to be geometry, not gradients.**

**A 3D shop still needs labels, and their size is decided by the screen.** Coreward's cases are
readable at a glance because each carries a canvas plate on its plinth - label text that belongs to
the case and turns with it, rather than HTML hovering in front of the room. At that camera the
visible width is ~3.5 world units across 375 CSS pixels, so a 0.66-unit plate is about 70 px:
a six-character word and nothing more. That is why they read DRILL and THRUST, not "Drill Bit" and
"Thrusters" - the full name goes in the detail card. **Measure the pixels the label will occupy
before choosing the words.**

**Say an availability state three ways, not one.** Coreward's cases carry it in a strip of light
(colour), the plate's second line (text) and how far the alcove is shuttered (value), so it reads
at a glance AND survives a colour-blind player. Four states: ready, short, sealed, maxed.

**Dim the case, not the object, when the object's material is shared.** The parts in those cases
are the same materials as the parts on the ship - tinting one to show "you cannot afford this"
would have dimmed the same part bolted to the ship parked in the middle of the room. A smoked panel
in front does the job and keeps the shared-object guarantee intact.

**Order the states deliberately and test the ordering.** Sealed beats affordable: quoting a price
for something no amount of money can buy is a lie, and the depth IS the price. Maxed beats
affordability. And name the missing MINERAL ahead of the credits, because credits are what the loop
pays constantly - a mineral the player has never seen is the thing actually stopping them.

**Show the REAL object in the shop, not a preview of it.** Coreward reparents the actual ship into
the station scene rather than building a copy, and the parts in the display cases are the same
geometry and materials that get bolted to the hull. So "what changes in the shop" and "what
changes in play" cannot disagree — not because they are kept in sync, but because there is only
one of them. Any time a shop shows a thing the game also shows, a copy is a second source of truth
that will drift, usually within one session.

**Lay a 3D shop out for the aspect ratio you actually have.** Portrait is ~0.46, so a 46 degree
vertical field is only ~22 degrees horizontal: eight units back shows 6.8 units of height and 3.1
of width. A hangar laid out sideways — the obvious shape for a hangar — puts most of itself off
the edges of a phone. Racking the goods in vertical columns flanking the centre is both what fits
and what a parts wall in a workshop looks like anyway.

## Portrait FOV: the same arithmetic from the other end

**Portrait's HORIZONTAL cone is tiny, and scenery has to be laid out for it rather than for the
number in the fov field.** A 58 degree *vertical* field at a 0.46 aspect is only about 28 degrees
horizontal, so ten metres ahead of the camera the frame is roughly five metres wide, total.
Stillwater's first build scattered reeds five to ten metres either side of the boat and **every
single one was off the edge of the screen** - the lake rendered as an empty grey plane whose only
landmarks were outside the picture, which reads as "the world is unfinished" rather than as a
framing error. The fix is not to drag them closer, which puts weeds around a boat in open water;
it is to place them where the cone has actually widened, far enough ahead that the frame has
spread to reach them. Coreward hit the same arithmetic from the other end when its shop had to be
racked vertically. **Compute the visible width at the distance a thing actually sits, before
choosing where to put it.**

## "Unavailable" and "not a control" must not look the same

A shop drew everything untappable in the same dead grey, so the motor you had just bought
looked exactly like the one you could not afford - it said "fitted" in the visual language of
"no". The same styling had been reused for the logbook, which meant every entry in the
collection, the game's main long-term reward, was rendered as a disabled button.

**Enabled/disabled is one axis; control/content is another.** A row that does nothing when
tapped can be an achievement, a record, a heading or a refusal, and only the last of those is
grey. Two booleans, not one.

Worth noting how it was found: **the tests all passed.** They asserted that the rooms opened,
filled, and closed, which they did. Screenshotting each screen and looking at it caught this,
a logbook that could never show a fish under a kilo, and a map printing the same true useless
sentence five times - none of which any assertion was ever going to state. **Take a picture of
every screen you build, once, and look at it.**

## Where a readout sits

**Where a readout sits matters more than what it looks like.** Coreward's fuel, hull and cargo
were bars along the top of the screen. They got a full instrument restyle - segments, ghost
cells, scanlines, numbers - and were still wrong, because the top of the screen is the one place
you are not looking while playing. Moving them to the corner beside the thumb that is already
there did more than any amount of paint. **If a restyle does not fix a "feels out of place"
note, the problem is placement, not surface.**

**A gauge you check under pressure must not move for reasons unrelated to the check.** A
tachometer ring was added around a fuel dial on request and removed the next round: it swept
every time the player moved or dug, which turned a glance at the one reading that decides
whether to turn round into something you had to parse. Movement on an instrument has to be
earned by being read.

## Instruments: gauges, needles, plate, grain, pressed buttons

**For analog gauges in the DOM, use SVG and `pathLength="100"`.** It renormalises a path so its
length is exactly 100 regardless of the real geometry, so "show 62 per cent" is
`stroke-dasharray: 62 100` and nothing needs to know the radius. Needles are one transform
each. It stays crisp at any pixel density with no redraw, and the drawn fraction is directly
readable from a test - which is what lets an assertion follow a value from a bar to a dial
without becoming a lie.

**Generate tick marks, never hand-place them.** Thirty lines of SVG is thirty chances to be half
a degree out, and every one has to be redone for the second dial. The geometry is four lines of
trigonometry.

**Give a needle mass.** Easing it toward its reading instead of snapping is most of what
separates an analog gauge from a bar with a pointer on it. Damp each one to what it shows: a
fuel needle only ever falls slowly, a load needle is chasing something that changes in a tenth
of a second.

**A HUD sitting on a textured world needs a material of its own.** Translucent fills with soft
corners are a clean overlay and the wrong one over photographed rock: the controls end up the
only part of the screen made of nothing. One plate does it - a rolled-steel gradient, a small
hard corner, a bright top edge and a dark bottom one, and a generated grain over the top. Draw
the grain as fine speckle plus a coarse mottle plus a HORIZONTAL STREAK; the streak is what
gives it a rolling direction, and without it noise reads as television static rather than as
metal. Sixty-four pixels, tiled, built once at boot from a deterministic hash so screenshots
stay comparable - zero bytes shipped.

**Grain wants to be felt, not seen.** The first pass was three times too strong, and the tell
is simple: you notice the texture before you notice the panel.

**A pressed control should read as pushed IN, not lit up.** Coreward's d-pad flooded cyan on
touch, which made it the loudest thing on screen at exactly the moment a thumb was covering it.
Inverting the bevel and dropping it a pixel says the same thing and gets out of the way.

## What the HUD says about pressure

**An upgrade you cannot see is one the player buys on trust.** Coreward's Scanner only changed
a light radius; the camera framed a fixed number of rows, so the whole screen was always inside
the lit circle. Giving it the *framing* — and then a headlight cone whose length tracks it, and
then a relic-finder whose range is that radius — turned the most invisible purchase on the
shelf into three reasons to buy one thing. **Three reasons to buy one upgrade beats three
upgrades with one reason each.**

**Give each pressure its own channel.** One red vignette driven by `max(hull, heat)` was fine
while heat was the only thing that emptied the hull. The moment a second source existed, the
screen was saying "heat" for something that was not heat.

**A number beats a bar when the player needs to understand causation.** Putting `HULL −3.4/s`
on the hull bar while heat drains it was the single most effective part of that fix. A coolant
flush takes it to `−0.7/s` in front of you, which is the clearest possible statement of what a
purchase bought.

**Put the gauge on the thing it is eating, and do not let it cover that thing.** The heat gauge
lives inside the hull bar. At full height it hid the hull level entirely — the gauge was
obscuring what it explains. Seven pixels of nineteen, along the bottom.

**Draw the player's own goal into the world.** A faint line across the rock at your previous
deepest reach is a target *you* set, as opposed to the core, which the game set. Freeze it at
the record you had when the run started — a line that retreats ahead of you is not a line you
can cross — and fade it once passed, or a moment becomes scenery.

**Put a modifier where the thing is already named.** A planet trait rides on the name chip in
the HUD, because that is the only always-visible place the planet is named. A modifier you must
open a menu to remember is one you play without.

## DOM footnote

**One scroll region per screen.** Giving an inner list its own `overflow-y` inside a flex column
quietly clips it at the fold — an entire category looked like it held one item, and another looked
like it did not exist.
