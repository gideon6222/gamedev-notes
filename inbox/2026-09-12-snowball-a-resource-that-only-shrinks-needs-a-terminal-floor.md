# Any run resource that a hazard can only shrink gets a named floor at which the run ENDS, in the same commit as the hazard; and a "wild thumb" is a policy the bot set does not contain, so the first phone session is the test for it.

**Game:** snowball  **Date:** 2026-09-12  **Belongs in:** CRAFT.md / The loop and stakes

## What happened
Snowball's ball sheds 12% of its radius on every shove and there was no floor. Six scripted policies over six seeds never found it, because no bot swipes at random; the first thirty seconds on the phone with a thumb swiping wildly did: the ball went from 1.0 m to 0.3 m across (screenshot `build/phone/20260912-185454.png`), at which point it was invisible at the camera's minimum distance, everything on the mountain was a wall to it, nothing could grow it, and the run sat there with no end and no way out but the pause menu. A multiplicative loss with no floor converges on a state the design never named. Fixed: shoved under `R_MIN` (0.35 m radius, seven-tenths of the starting size) the ball breaks up and the run ends like a shatter, with a test whose fixture keeps a shove-class thing four metres ahead ON THE BALL'S LINE - a fixed ladder of rocks was missed after the first shove kicked the heading and the ball rolled on and regrew, so the first version of the test passed for the wrong reason.

## The rule
Any run resource that a hazard can only shrink gets a named floor at which the run ENDS, in the same commit as the hazard. A "wild thumb" is a policy the bot set does not contain, so the first phone session is the test for it. Ask of every multiplicative loss: what state does it converge to, and is that state one the game can leave? Measured: 12% shed with no floor reached 0.15 m radius inside thirty seconds of swiping; zero of thirty-six bot runs had ever gone under 0.4 m.

## Replaces or contradicts
Never let a hazard take the run: bound the worst case and test it.
