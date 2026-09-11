# A directory exclusion takes its exceptions with it, in robocopy and in .gitignore both

**Game:** wildform  **Date:** 2026-09-11  **Belongs in:** `GODOT.md` under export,
and `TESTING.md` beside the scaffold checks.

## What happened

Two separate tools, the same shape of bug, found within ten minutes of each other in a
freshly scaffolded game.

**1. `new-game.ps1` never copied `build/.gdignore`.** The template has the marker, and
its comment explains exactly why it matters: without it Godot imports and then EXPORTS
whatever films leave in `build/`, which is how an APK once came out at **1.42 GB against
a 28 MB budget** with 3,720 PNG frames inside it. The copy line is

```powershell
robocopy $Template $Dest /E /XD .git .godot android build ...
```

`/XD build` excludes the directory, and the one file inside it that is not build output
went with it. **No game ever scaffolded from this template has had the marker**, and
nothing would have noticed until the first filmed run was followed by an export.

**2. The template's own `.gitignore` un-ignored the whole directory.**

```gitignore
build/
!build/.gdignore
!build/
```

A bare `build/` followed by `!build/` does not "ignore the contents except one file"; it
un-ignores the DIRECTORY, and git then happily tracks everything in it. Three check logs
went into a commit before anyone looked.

## The rule

**When you exclude a directory, list what inside it was load-bearing.** A directory
exclusion is not a statement about build output, it is a statement about a path, and any
exception living under that path disappears silently.

- In `.gitignore`, ignore the CONTENTS and re-include the file: `build/*` then
  `!build/.gdignore`. `dir/` + `!dir/` is not that and never was.
- In a copy step, recreate the exception explicitly after the copy and **assert it
  exists**, rather than trusting an exclusion to have carved one out.

Both fixes are one line each and both are now in `new-game.ps1` and the template.

## The general shape, which is the part worth keeping

Both faults are invisible at the moment they are made and only surface much later, in a
different tool, as a number nobody connects back: an oversized APK, or a diff full of
logs. **A guard that lives inside the thing being excluded is not a guard.** Recreate it
outside, and fail loudly when it is absent - `new-game.ps1` now refuses to scaffold a game
whose `build/.gdignore` is missing, which turns a 1.42 GB surprise into a one-line stop.

## Replaces or contradicts

Nothing. Extends the existing `GODOT.md` note that "anything a tool writes INTO the project
directory is a candidate for the package, and `.gdignore` is the load-bearing half of that
pair, not `exclude_filter`" - by recording that the marker was never actually arriving in
any scaffolded game, so that note has been true and unenforced this whole time.
