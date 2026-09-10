# `get_display_safe_area()` off a phone returns the usable DESKTOP, so applying it displaces every control by a hundred pixels

**Game:** gravewell **Date:** 2026-09-10
**Belongs in:** `GODOT.md` under layout, right beside "the base resolution is a
lie about height", because it is the same bug arriving from the other direction.

## What happened

The HUD root applies the display safe area as its margins, which is correct and
required once `screen/edge_to_edge` is on. The implementation had two faults and
they compounded:

```gdscript
var safe := DisplayServer.get_display_safe_area()
var screen := DisplayServer.screen_get_size()      # the MONITOR
var vp := Vector2(view.get_visible_rect().size)    # 1080 x 2338
var sx := vp.x / float(screen.x)                   # mixing two coordinate spaces
```

**It ran off a phone.** On desktop `get_display_safe_area()` returns the usable
desktop area, the monitor minus the taskbar. That has nothing whatever to do
with the game's window.

**It converted through the SCREEN rather than the WINDOW.** The safe area is in
window pixels and the margins have to be in viewport units, so the ratio wanted
is `viewport / window`. Using the monitor's size makes the answer arbitrary.

Measured with `scripts/rects.gd`, which prints every control's real
`get_global_rect()` from a real window: the d-pad sat at y 1858 when its offsets
said 1962. **104 pixels of displacement, upward.**

## Why it took a filmed run to find

Every check passed. The smoke test asserts the controls are ANCHORED rather than
placed, and they were. A headless run uses a 100x100 viewport where wrong and
right are identical. A screenshot showed the d-pad drawn in a perfectly sensible
place, because the drawing moved with the hit box.

What found it was **filming a replay**: the taps landed in empty space, the run
filmed beautifully for sixty seconds, and the ship never left the surface. That
is exactly the failure the replay README warns about ("the taps miss, the run
films perfectly anyway, and it reads as a broken game rather than a broken
coordinate") arriving from the game's side rather than the replay's.

## The rules

- **Guard the safe area behind `OS.has_feature("mobile")` and make it exactly
  zero everywhere else.** A margin that is right on a phone and wrong on a desk
  is worse than none, because every desk-side tool then measures a layout the
  phone never sees.
- **Convert through `DisplayServer.window_get_size()`, never
  `screen_get_size()`.** One is the thing the safe area is measured in; the other
  is the monitor.
- **Assert it.** The smoke test now checks that off a phone the HUD root's four
  margins are exactly zero. It is a structural assertion, which is the only kind
  a headless run can make about layout, and it is the same shape as the existing
  "the controls are anchored, not placed" test that this bug walked straight past.
- **Keep a `scripts/rects.gd`.** Printing every control's real global rect from a
  real window takes three seconds and is the only way to write replay coordinates
  that are not a guess. It belongs in the template.
