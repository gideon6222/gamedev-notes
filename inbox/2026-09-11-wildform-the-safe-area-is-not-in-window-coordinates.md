# `get_display_safe_area()` is not in window coordinates, and headless hides it

**Game:** wildform  **Date:** 2026-09-11  **Belongs in:** `GODOT.md` under layout, beside
the "base resolution is a lie about height" section.

## What happened

POLISH asks that nothing sit under the camera cutout or the gesture bar. The obvious
implementation insets the UI root by the difference between the window and the safe area:

```gdscript
var window := DisplayServer.window_get_size()
var safe := DisplayServer.get_display_safe_area()
_ui.offset_right = -float(window.x - safe.end.x) * sx
```

On the desk, `get_display_safe_area()` returned **the whole screen** - `Rect2i(0, 0, 1920,
1080)` - while the window was 460x996. So `window.x - safe.end.x` is `460 - 1920 = -1460`,
the offset came out POSITIVE, and the inset became an **outset**: the UI root was pushed off
the side of its own viewport.

The symptom was that the branch pips - the readout the whole evolution mechanic is steered
by - were simply absent from a screenshot. Everything else still drew, because the HUD label
and the type ring are anchored top-left and survived being pushed right.

## And the test passed the entire time

The smoke test asserted exactly the right property:

```gdscript
_t.ok(main._ui.offset_right <= 0.0, "the UI root is pushed off the right of the screen")
```

**A headless run reports a safe area of zeros**, so every offset was 0.0 and the assertion
was true on every run while the real window was broken. This is the same class as the
headless-layout warning already in `GODOT.md` - the wrong layout and the right one are
identical at the size the tests run - but it is worse here, because there WAS an assertion
and it was watching a value that could only ever be convenient.

## The rule

**Clamp the safe area to the window before subtracting.** Then every inset is non-negative by
construction, whatever the platform hands back:

```gdscript
var left := clampi(safe.position.x, 0, window.x)
var right := clampi(safe.end.x, 0, window.x)
```

Treat a degenerate rect (zero width or height) as "no inset", never as "inset everything".

**And make the arithmetic a pure static function so it can be given the awkward inputs.** The
test that catches this cannot run against the real display - it has to call the function with
a desktop's oversized rect, a phone's cutout-and-gesture-bar rect, and an empty one. That is
"test the placement with the model" applied to a platform query: the model is the only place
the bad input can be produced on demand.

## The general shape, which is the part worth keeping

A platform query that returns something sensible on the machine you are testing on, and
something else on the machine you are shipping to, cannot be guarded by an assertion on its
result. **Guard the arithmetic, not the reading.** And when an assertion has only ever seen
one value, that is not evidence it works - it is the definition of a vacuous guard.

## Replaces or contradicts

Extends `GODOT.md`'s layout section. The existing note says no headless test can catch a
layout bug and to assert the PROPERTY instead. True, and insufficient: the property has to be
asserted about a pure function fed real-world inputs, because asserting it about live values
in a headless run is asserting it about zeros.
