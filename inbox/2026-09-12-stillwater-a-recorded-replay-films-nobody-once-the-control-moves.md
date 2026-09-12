# A recorded replay films nobody once the control moves

**Game:** stillwater  **Date:** 2026-09-12  **Belongs in:** techniques/filming-a-run.md / Scenarios

## What happened
To review a change to the cast animation (F5, B8) the session filmed `test/replays/first-cast.json` - the replay CLAUDE.md names as the scripted first cast - and tiled the 36 frames around where the cast should be. The rod never moved and the caption read "Cast" in every tile. The replay had been recorded on 2026-09-09 when touching the water loaded the rod; since then casting moved to the Cast button ("touching the water never casts", a deliberate change with its own smoke assertion), so the replay's touches at (540, 1150) land on the water and do nothing. Nothing reported it: the film ran to the end, the sheet was produced, and it looked like a calm boat. It was only noticed because the reviewer was looking for a specific motion in specific frames. The same session's policy film (`-UserArgs policy=angler`, which asks the game's bot where to press each frame and pushes real touches) cast correctly through the button, because a policy adapts and a recording cannot. The fix was to re-record the replay FROM the bot - `-UserArgs policy=angler,record=test/replays/first-cast.json` writes the bot's real touches out as an ordinary replay file - so the scenario file is generated from the current layout rather than typed against an old one.

## The rule
A recorded replay goes stale the moment a control moves and then films a game nobody is playing without a word of complaint, so generate scenario replays from the policy bot (`policy=<name>,record=<file>`) rather than by hand, and treat a filmed run whose sim state never left IDLE as a failed film, not a calm one.

## Replaces or contradicts
stillwater adds `first-cast` and `logbook`,
