# A Windows path with backslashes loses them going through the Bash tool, and the wreck is a real directory with a mangled name

**Game:** coreward  **Date:** 2026-09-12  **Belongs in:** GODOT.md / Windows and the shell (beside the Python heredoc line at GODOT.md:394)

## What happened
Two separate sightings on the same day. A studio sweep found a directory called
`SERSGIDEOAPPDATAocaltemp/` in `C:\dev\coreward`, holding five review PNGs written at
18:29. The name is `C:\Users\gideo\AppData\Local\Temp` after the Bash tool read `\U`, `\A`,
`\L` and `\T` as escape sequences and dropped them, collapsing an absolute path into one
relative directory name, which the tool then created inside the repo. Nothing in
`coreward/scripts/` builds that path, so it came from a typed command line. The same thing
happened in the open a few hours later: `powershell -File C:\dev\gamedev-notes\scripts\progress.ps1`
run through the Bash tool failed with `The argument 'C:devgamedev-notesscriptsprogress.ps1'
to the -File parameter does not exist`, which is the same swallow with a visible error
instead of a silent side effect. That is the difference that matters: when the path is an
argument you get an error, and when the path is an output directory you get 1.4 MB of files
in the wrong place and no complaint from anything.

## The rule
**Write Windows paths with forward slashes whenever they pass through the Bash tool**:
`C:/dev/gamedev-notes/scripts/progress.ps1`. PowerShell, Godot, node, python, adb and ffmpeg
all accept them, so there is no case that needs the backslash form. If a backslash path is
unavoidable, single-quote it and check what arrived before doing anything with it. **Treat a
directory with a run-together capitalised name (`SERSGIDEOAPPDATA...`) as this bug, not as
something a tool meant to make**, and look for the files it swallowed rather than deleting
it blind.

## Replaces or contradicts
`GODOT.md:394` says the narrower half of this already:

> **Never put backslash escapes in a Python heredoc through the Bash tool.** Write the script
> to a file and run it, with an `assert pattern in text` beside every replace.

That stays true and keeps its heredoc advice. It should be widened, because the heredoc is
only the case where the damage is visible: the rule is about any Windows path crossing the
Bash tool, as an argument or as an output directory, and the output-directory case is the
one that fails silently.
