# A touch control's per-frame sync must send to the simulation only while the thumb is on it, and once as it lifts

**Game:** stillwater  **Date:** 2026-09-12  **Belongs in:** GODOT.md / input / controls and CRAFT.md / intro carrying the control's words

## What happened

Stillwater's new reel slide (a vertical touch slider that sets `Sim.set_reel(r)` in [-1, 1]) had a per-frame `_sync_slide(dt)` that computed the thumb's value and called `sim.set_reel(want)` every frame during a fight, with `want` = 0 whenever no thumb was on the slide. That overwrote every OTHER driver of the sim sixty times a second: the scripted policies in `Main.play()`, the smoke harness's direct `sim.set_reel(1.0)`, and the filmed bot's policy seam before its thumb had landed. The smoke suite reported "two minutes of correct play landed nothing - the loop is broken somewhere in the scene" and eleven more failures downstream of that, plus the first-morning intro stalling at the reel beat. Nothing was wrong with the model or the bots; the picture was shouting zero over them. The fix: the control speaks only while a thumb is on it, and once with zero on the frame it lifts (a `_slide_spoke` flag), so anything driving the sim directly is left alone. The same session also found the intro copy still said "tap to reel it in. stop tapping when it runs" three fights after tapping was removed - a control's wording lives in the intro as well as on the button, and both have to move.

## The rule

A touch control's per-frame sync must send to the simulation only while the thumb is on it, and once as it lifts - a sync that sends its resting value every frame silently overrides the bots, the harness and the filmed policy seam. When a control's verb changes, grep the intro and the hints for the old verb.

## Replaces or contradicts

nothing
