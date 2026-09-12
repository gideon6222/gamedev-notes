# He reviews by screenshot at every check-in, not only before a ship, and every shot must be at the device aspect

**Game:** stillwater  **Date:** 2026-09-12  **Belongs in:** PLAYER.md / Preferences that carry into every game

## What happened
Across one Stillwater session he said "I can't test currently" three times and then asked for
the working rule directly: "at the end of every session, when you stop and check in, can you
provide me screen shots of how each of the changes look? I cant test right now but I can check
screen shots." He is frequently unable to run a build at the moment the work lands, so the
screenshot is not a ship artefact, it IS the review. The same session proved the aspect half
of it: a screenshot taken in a roughly square desktop window showed the rod in the player's
hands correctly, and a probe at the phone's real 19.5:9 found the reel more than a full
viewport width off the left edge - so the rod bend, the line reddening, the reel animation and
the new haptics had all been signed off on a picture that could not show them. Two of his
complaints in that session ("the pages are in the air on the left", "planks and sticks
sticking up on the right") were both things a device-aspect shot showed immediately.

## The rule
Every check-in carries a picture of every change with a visible result, shot at the device
aspect (`--resolution 460x996` for a 1080x2340 phone). A desktop-window capture is nearly
square and hides anything near an edge, so it cannot be used to sign off placement. If a
change only exists mid-animation, add a screenshot mode that freezes the clock inside it
rather than reporting that it cannot be captured.

## Replaces or contradicts
PLAYER.md, under "He cannot see the thing that matters": "Every state names a visible action, every gauge sits where the thumb is not, and a screenshot of every screen at the phone's aspect is looked at before shipping." - "before shipping" is too late and too narrow. It is at every check-in, and it is how he reviews rather than something done for him.
