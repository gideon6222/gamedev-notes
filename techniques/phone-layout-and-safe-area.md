# Laying out a HUD on a real phone: the safe area, and why headless cannot see a layout bug

**Game:** Gravewell and Wildform (both shipped the bug), template fix in `godot-template` · **Status:** the arithmetic is a pure static function with a test; both instances fixed · **Read when:** placing anything in a `CanvasLayer`; turning `screen/edge_to_edge` on; a control reported as "about half an inch too high"; writing a test that is meant to protect a layout

Two games shipped a broken HUD past a full green suite, and in both cases the reason is the same:
a phone layout has exactly one input that headless cannot produce, and every test was reading the
value rather than the arithmetic that consumes it. The numbers below are the two instances, and
they fail in opposite directions, which is what makes the clamp non-negotiable.

**Generalisable takeaways**

- **`get_display_safe_area()` off a phone returns the usable DESKTOP.** It has nothing to do with
  the game's window and it is not zero, so the unguarded call is wrong everywhere but the target.
- **Clamp the rect to the window before subtracting**, so every inset is non-negative by
  construction whatever the platform hands back.
- **Put the arithmetic in a pure static function and assert THAT, fed the awkward inputs.** The
  model is the only place the bad input can be produced on demand.

---

## The safe area is the one input headless cannot produce

Apply `DisplayServer.get_display_safe_area()` as margins on `_ready` and on `size_changed`. It is
required once `screen/edge_to_edge` is on, and it is where both bugs live.

- **Guard it behind `OS.has_feature("mobile")` and make it exactly zero everywhere else.**
- **Clamp the rect to the window before subtracting**: `clampi(safe.position.x, 0, window.x)`, the
  same for `safe.end.x`, so a bad rect can only ever produce a zero inset.
- **Convert through `DisplayServer.window_get_size()`, never `screen_get_size()`.** The safe area
  arrives in window pixels and the margins are viewport units.
- **Treat a degenerate rect as "no inset", never as "inset everything".**

The two instances, which fail in opposite directions:

| game | what the platform returned | what it did |
|---|---|---|
| Gravewell | a desktop's usable rect | d-pad displaced **104 px upward** (M) |
| Wildform | `Rect2i(0, 0, 1920, 1080)` against a **460x996** window | `window.x - safe.end.x` = **-1460** (M) |

Wildform's is the instructive one. The inset became an **outset**, so the branch pips that the
whole evolution mechanic is steered by were pushed off the viewport - while the top-left-anchored
HUD, which subtracts nothing, survived and looked completely fine in the screenshot. Half a layout
being right is what made it survive review.

## Why every test passed

**No headless test can catch a layout bug by reading live values**, and asserting the property
rather than the position is necessary and **not** sufficient.

Headless runs at the base size, where wrong and right are identical, and it reports a safe area of
**zeros**. Wildform's smoke test asserted exactly the right property - `main._ui.offset_right <= 0.0`
- and it was true on every single run for the entire time the window was broken, because every
offset was `0.0`. That is `INDEX.md` rule 11 in its purest form: an assertion that has only ever
seen one value is the definition of a vacuous guard.

**Put the arithmetic in a pure static function and assert that**, fed the inputs that actually
occur:

1. a desktop's oversized rect (Wildform's `1920x1080` against a `460x996` window),
2. a phone's real cutout-and-gesture-bar rect,
3. an empty or degenerate one.

Guard the arithmetic, not the reading. The model is the only place the bad input can be produced
on demand, and it needs no window, no frame and no GPU.

What actually found the Gravewell instance was a **filmed replay whose taps landed in empty
space** - a drawn control moves with its own hit box, so the picture and the input agreed with
each other and disagreed with the player. Screenshots still go through `--resolution 460x996`,
which is necessary and also not sufficient: the Wildform screenshot looked right.
