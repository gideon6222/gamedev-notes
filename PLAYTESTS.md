# PLAYTESTS.md

What Gideon actually said about each game, in his words, dated. Complaints are the most
valuable entries here. Append, never rewrite.

---

## Coreward — github.com/gideon6222/coreward

Live at https://gideon6222.github.io/coreward/

Dig toward a planet core, sell ore at the surface pad, buy upgrades, break the core and the
planet explodes, launch to a harder planet. Fuel and hull heat are the two pressures pushing
you back up.

### 2026-09-06 — first run
"the game looks like it runs great"

Confirmed working on the S26 Ultra in Chrome and installed as a PWA. No performance or
rendering complaints.

### 2026-09-06 — first real session, reached 75m

"I can afford upgrades pretty early on for fuel and cooling so neither is a risk."
Both pressure systems were defused before they ever applied pressure. Lesson: if a resource
is meant to create tension, its mitigating upgrade must not be affordable on the first or
second haul. Price the counter-upgrade against the depth where the threat actually begins.

"Right now it doesnt say it costs anything, so it feels free."
The Return button charged fuel but never displayed the cost, so it read as a free teleport
and erased the entire journey home. Lesson: an escape hatch with an invisible cost is the
same as no cost. Either show the price on the button or do not offer the button.

His redesign, which is better than what I built: no return button at all. Running out of fuel
gets you towed back and the tow takes half your cargo. A Tow Insurance upgrade reduces the
cut. Autopilot is a separate, later, expensive upgrade that unlocks a fast ride home, and
further levels make it cheaper in fuel. This turns the failure state into the default way
home and makes the escape hatch something you earn.

"It is difficult to judge the price of the different blocks you are mining."
Cargo counted units, so a lump of dirt and a ruby occupied the same slot and the haul value
was invisible until you sold it. Lesson: if the player cannot compare two things on screen,
the choice between them is not really a choice.

His fix: cargo measured in weight, rarer minerals heavier but with a large price jump, dirt
nearly weightless and nearly worthless, plus a manifest showing count per mineral and total
sale value. The point is to make hunting deposits the game, rather than tunnelling.

"The ship should turn to face the direction it is digging in."

Wanted better mineral visuals, reading as actual mineral deposits, and a visible progressive
breaking effect on blocks that take more than an instant to dig.
