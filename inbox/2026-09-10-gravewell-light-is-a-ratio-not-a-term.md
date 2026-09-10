# A lighting complaint is about a RATIO, so measure two places, not one

**Game:** Gravewell. He wrote: "the light seems to be coming from the back of the ship in a
small beam."

The instinct is to go and look at the beam. The beam was fine. What was wrong was that the
air BEHIND the ship measured 150 of 255 while the rock the beam was pointing at measured 103.
The brightest thing on screen was behind him, so the lamp read as pointing backwards.

**The method that worked, in order:**

1. Sample the screenshot with PIL rather than judging by eye. Four points ahead, four behind,
   four up the shaft. Twenty lines of Python beats a paragraph of description and it makes
   "better" a number you can compare across rounds.
2. Isolate the suspect terms by REPLACING them, not by reading them. Two shots with
   `flood -> 1.0` and `shadow -> 1.0` said in one pass that the black stretch of shaft was
   the shadow term. A probe then said the shadow was right: the column above the ship was
   only open for four cells. The bug was in my mental model of the geometry, not in the code.
3. Only then change gains, and re-measure the same points.

**Numbers that came out of it (Gravewell, one lamp, three terms each on rock and air):**
forward pool ~100, tunnel behind ~25, air in the shaft ~50. A forward:behind ratio around
3-4:1 reads as directional while keeping the way home visible. At 6:1 the tunnel behind went
black, which throws away the route out; at 1.65:1 there is no direction at all.

**Combine terms with `max()`, never a product**, and give each its own reach: beam (long,
directional), proximity (a THIRD of the reach, no direction — this is the "light on the rock
face when you are near it"), wash (longer than the beam, very weak, riding the propagated
spill so it only reaches faces light could have got to). Multiplying two floors lands anything
dim for two reasons on the product, which is black.

**Keep the term-isolation switch in the shader.** A `uniform int debug_term` with one branch
per term costs nothing and I hand-patched the same file twice in one session for want of it.

**Related:** when he restates a system from scratch instead of refining a number, the model is
wrong, not the tuning — that held again here, and the fix was three named terms per surface
rather than any single constant.
