# A parse error in a script the harness loads shows up as a HANG, not as an error

**Game:** stillwater  **Date:** 2026-09-11  **Belongs in:** `TESTING.md` beside the harness rules, and `GODOT.md` under headless lifecycle

## What happened

Deleting dead code from `main.gd` left one reference behind (`_box_rows`, in a tap handler I
had forgotten). The smoke suite then **hung**: no failure, no error on stdout, just nothing,
until a 300 s timeout killed it.

Two bisections went past the real cause. I reverted the ray-march I had just written - still
hung. I reverted the early return I had just written - still hung. Only then did I run it with
a short timeout and read the FIRST lines of output instead of grepping for `FAIL`:

```
SCRIPT ERROR: Parse Error: Identifier "_box_rows" not declared in the current scope.
   at: GDScript::reload (res://src/game/main.gd:5566)
ERROR: Failed to load script "res://src/game/main.gd" with error "Parse error".
SCRIPT ERROR: Invalid call. Nonexistent function 'freeze' in base 'Node3D'.
```

The chain is the whole lesson. The scene's script fails to parse, so `main.tscn` instantiates
as a **bare `Node3D`**; the harness calls `freeze()` on it, which does not exist; the error is
non-fatal, so the suite carries on driving a stub that never changes state, and every
`_drive_until` loop runs to its limit. A suite full of "advance until X" loops against an
object that can never reach X is an arbitrarily long run, not a crash.

## The rule

**A hanging suite is a parse error until proven otherwise.** Read the TOP of the log, not the
end and not a grep for `FAIL` - the repo's own `check.ps1` prints "a parse error is at the TOP,
not the end" for exactly this reason and I grepped past it anyway.

**Grepping for `FAIL` hides the class of fault that produces no `FAIL` at all.** When a run
does not finish, the first command should be `head`, not `grep`.

**And a harness should refuse to run against a stub.** One line after instantiating the scene -
assert the node has the method the suite is about to call, and quit non-zero naming the script
- converts a silent multi-minute hang into an instant, accurate failure:

```gdscript
if not main.has_method("freeze"):
    printerr("main.tscn did not load its script - read the parse error above")
    quit(1)
```

Worth adding to the template's `run_smoke.gd`, since every game inherits this shape.

## Replaces or contradicts

Nothing. It extends the existing note that a Godot parse error "hangs" rather than failing
cleanly, by naming the mechanism (the scene loads as its base type and the harness drives a
stub) and by giving the one-line guard that makes it loud.
