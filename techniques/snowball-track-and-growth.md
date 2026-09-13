# Snowball: the track boundary, pickup placement, and a wedge that looked like a bug in the bot

**Game:** Snowball · **Status:** shipped, measured with bots · **Read when:** placing pickups or
hazards along a track a ball or vehicle rolls down; a depenetration or push-out correction that
holds an avatar in place for seconds; deciding what the play-space boundary should cost the player.

**Generalisable takeaways**

- **The play-space boundary costs something the player can feel (speed, a rumble), never the
  resource the game is scored on** - an unmeasured boundary can quietly become the real difficulty
  curve.
- **A depenetration must never have a component against the track's direction of travel**, or it
  can wedge an avatar against an edge indefinitely.
- **Sort pickups along the direction of travel for a small avatar, never scatter them on a disc.**

---

## The boundary became the real difficulty curve by accident

Counting contacts per run with the bots, before counting hazard contacts, showed the unplaced
play-space boundary hit 4-10 times a run in Snowball - more often than any placed hazard. Nothing
had been tuned about it; it was simply there, and it was doing more work than the content. **The
play-space boundary costs something the player can feel (speed, a rumble), never the resource the
game is scored on**, and it needs the same contact-counting measurement as any other hazard before
it ships silently as the hardest thing in the level.

## A depenetration with a sideways component can wedge a reader against an edge for minutes

Snowball's avatar has no physics body: overlaps are resolved by hand, pushing it out along the
contact normal. Against a track edge, the contact normal has a component AGAINST the direction of
travel, and pushing along it wedged a reader against a lane edge for over 200 seconds - the bot's
inputs kept changing (it was still trying to advance) while its position did not move, which reads
exactly like a bug in the bot rather than in the correction.

**Resolve overlaps across the track only** - project the correction onto the perpendicular axis and
drop any component along the direction of travel. And **treat a bot that stops advancing while its
inputs keep changing as a wedge, not a bug in the bot**: the bot is telling the truth about what it
is trying to do.

## Pickups sorted along the line beat pickups scattered on a disc

For a ball small next to the field (0.5-1.0 m radius), scattering pickups across a disc gives a
small avatar about one contact per pass across it, because it sweeps a narrow strip. Sorting the
same pickups small-to-large in a LINE along the direction of travel instead gave six to ten
contacts per pass (M) - the difference between a pickup a player can feel accumulating and one that
mostly misses.

**Measure contacts per pass with a bot before placing any growth threshold** - a threshold tuned
against the disc's contact rate is tuned against a number the line never produces.
