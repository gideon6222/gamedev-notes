# A deliberately broken path written as an example in a topic file becomes a doctor FAIL, so spell the example so the cross-reference regex cannot read it as a path

**Game:** studio  **Date:** 2026-09-12  **Belongs in:** GODOT.md / Windows paths through the Bash tool

## What happened
The 2026-09-12 digest (commit 901ac41) folded the Windows-path lesson into GODOT.md and, to
show what a swallowed backslash looks like, wrote the mangled result out in full:
``-File 'C:devgamedev-notesscriptsprogress.ps1'``. The doctor's cross-reference check reads
every `.ps1` name in every topic file and asks whether it exists, and it cannot tell an
illustration from a promise, so the next run went from 0 fail to 1 fail with
"'devgamedev-notesscriptsprogress.ps1' does not exist, referenced at GODOT.md:410". The
FAIL is real as far as the check is concerned and it lands on whichever petition runs next,
because the Courier's verdict is the before-and-after delta.

## The rule
When a topic file has to show a broken or mangled path as an example, break the file
extension too (write it as `progress .ps1`, or describe it as "the .ps1 suffix with every
backslash eaten") so the cross-reference check in `scripts\doctor.ps1` cannot read it as a
reference. The same goes for any path that is deliberately wrong: the checker treats every
`name.ps1`, `.py` and `.gd` in prose as a claim that the file exists.

## Replaces or contradicts
GODOT.md:410, which currently reads "(`-File 'C:devgamedev-notesscriptsprogress.ps1'`). If a
backslash path is unavoidable," and needs the example respelled so the extension is not
matched. Nothing else contradicts it.
