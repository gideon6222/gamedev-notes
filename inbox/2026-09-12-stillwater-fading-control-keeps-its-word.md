# A fading control keeps its last word

**Game:** stillwater  **Date:** 2026-09-12  **Belongs in:** CRAFT.md / UI / controls

## What happened
Stillwater cross-fades the Cast button into a reel slide when a fish is hooked, and back when it is landed. Both controls computed their caption from the sim state every frame. The filmed run (1/30 s tiles) showed that for six frames after the strike the ghost of the outgoing button and the incoming slide BOTH said "Reel", and at the landing a second faint "Cast" hung under the button as the slide faded out. No screenshot caught it because a screenshot shows one settled state; only the frame-by-frame film did.

## The rule
In a cross-fade between two controls that stand in for each other, the control that is leaving keeps the word it left with. Write each control's caption only while it is the live control (one writer per word), and store the outgoing control's caption instead of recomputing it. Assert it in the smoke suite by stepping the fade exactly one frame after the state change and checking the two captions differ (stillwater test/run_smoke.gd, _check_the_slide_is_the_reel). Verified by reintroducing the bug: 2 failures.

## Replaces or contradicts
The action button's caption is derived by the function that performs the action - and so is its whole identity. One button that becomes Cast over water and Select over the boat, grey when nothing is under the crosshair, beats two buttons for one verb.
