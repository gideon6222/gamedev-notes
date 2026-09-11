# A loop of `tween_property` is sequential, so duplicating a material multiplied a 0.56 s transform into a 9 s whiteout

**Game:** wildform  **Date:** 2026-09-11  **Belongs in:** `GODOT.md` under Tween and lifecycle
traps, and `TESTING.md` under what a headless harness cannot see.

## What happened

The evolution transform dissolved the creature out, swapped the mesh, and dissolved it back in,
written as:

```gdscript
var tw := create_tween()
for mat in _form_mats:
    tw.tween_property(mat, "shader_parameter/dissolve", 1.05, 0.22)
tw.tween_callback(func(): ... ; _flash.modulate.a = FLASH_PEAK)
for mat in _form_mats:
    tw.tween_property(mat, "shader_parameter/dissolve", -0.05, 0.34)
tw.parallel().tween_property(_flash, "modulate:a", 0.0, FLASH_FADE)
```

Correct when `_form_mats` held one shared material. A later change gave every creature its own
material duplicate, and `_form_mats` became sixteen. **Tweeners added to a plain `Tween` run one
after another**, so the transform went from 0.56 s to 16 × 0.22 + 16 × 0.34 = **8.96 seconds**,
with the white flash held at peak for 5.08 s of it because the fade was parallel to the *last*
tweener.

Measured off a filmed run: three whiteouts of 5.08 s each in a 75 second run. **A fifth of the
game was a white rectangle**, and the player had already reported the game as *"difficult to
understand what is going on"*.

Nothing about the diff that caused it looked like a timing change. The constants stayed 0.22 and
0.34 throughout.

## Two rules

1. **Never put `tween_property` inside a loop over a collection whose size can grow.** Tween one
   value and fan it out to the collection in whatever function already writes that collection
   per frame. Then the duration is a property of the animation instead of a property of how much
   content the game happens to have.
2. **Assert the animation's MEASURED length, not its constants.** `Tween.custom_step(delta)`
   drives a tween with no running SceneTree and returns false when it finishes, so counting the
   steps is a headless measurement of exactly the quantity that was wrong:

   ```gdscript
   var tw: Tween = main._play_transform(...)
   var seconds := 0.0
   while tw.custom_step(1.0 / 60.0) and seconds < 30.0:
       seconds += 1.0 / 60.0
   assert(seconds < 1.0)
   ```

   Reported 8.97 on the bug and 0.56 after the fix. Have the function return its tween so this
   is possible at all.

## The bigger finding: `is_inside_tree()` is false for everything a SceneTree harness builds

```gdscript
func _initialize() -> void:
    var m = scene.instantiate()
    root.add_child(m)
    print(m.is_inside_tree())   # false, one line after the add
```

The root window has not entered the tree yet during `_initialize()`, and it is the tree entering
that sets the flag. `get_parent()` already returns `root`, so the node looks attached by every
other test.

The consequence is not a curiosity. This studio's Godot notes tell you to guard anything that
needs the tree with `is_inside_tree()` - which is right - and **every one of those guards is a
silent no-op for the entire smoke suite.** Any code path behind one has never been exercised by
any test, however green the suite is. That is exactly how a nine second transform shipped.

**So a smoke harness needs two stages**: the checks that must work outside the tree in
`_initialize()`, and the checks that need a live tree in `_process()` on frame one. Without the
second stage, the suite is silently not testing the half of the game that is guarded.

The obvious version of the test - advance the game for a second and assert the flash is down -
**passes on the bug**, twice over: nothing in a headless harness ticks a Tween, so the flash is
never raised either. A test that passes for two independent wrong reasons is the worst kind.

## Replaces or contradicts

Nothing contradicted. It sharpens the existing `GODOT.md` note that `get_tree()`,
`get_viewport()`, `look_at` and `unproject_position` fail outside the tree: the missing half is
that the standard guard against that is itself untested, and the fix is a second harness stage
rather than another guard.
