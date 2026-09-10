# The shell hid the game from every screenshot script written before it

**Game:** Gravewell. **Cost:** one screenshot filed as evidence about tunnel lighting that
was a photograph of the title screen.

The harness seam is `freeze()` then `advance()`. Once a title screen exists, `_tick` returns
immediately while the shell is not playing, on purpose: the title is a screen in FRONT of the
game and the game is not running behind it. So every shot script written before that
milestone still ran, still printed "wrote shot.png at t=26.0s", still exited 0, and captured
the menu. Nothing failed.

**The rule:** the milestone that puts a screen in front of the game updates every harness
entry point in the same commit. Grep for the seam (`freeze()`, `advance()`) and fix all of
them, then delete the by-hand `_shell._new.pressed.emit()` copies that the newest scripts had
started growing.

**The shape:** `main.start_run()` calling `shell.begin_new()`, where `begin_new()` is the
method the NEW GAME button also calls. When the only way in lives inside a button's lambda,
the only way for a test to get in is to reach into a private, so half the scripts do and half
forget.

**Related:** the smoke suite was fine throughout — it crosses the title through the button on
purpose. A suite that skips the title is a suite where the title is the one uncovered path,
and here it was the shot scripts, not the suite, that had the hole.
