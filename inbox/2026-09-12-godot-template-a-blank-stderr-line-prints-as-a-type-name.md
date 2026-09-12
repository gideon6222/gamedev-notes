# A blank stderr line arrives as an ErrorRecord whose ToString() is the bare .NET type name

**Game:** godot-template  **Date:** 2026-09-12  **Belongs in:** GODOT.md / Commands, beside the `*> $log` unwrap rule

## What happened

`check_size.gd`'s new stale-APK refusal uses `printerr("")` to space the paragraphs
of its error block. Run for real for the first time, the log came back as:

```
System.Management.Automation.RemoteException
  THE APK IS OLDER THAN THE CODE. Nothing was measured.
System.Management.Automation.RemoteException
  godot-template.apk        2026-09-08 17:07:41
```

The content lines were right and every spacer line was replaced by the class name.
`check.ps1` already unwraps ErrorRecords with `$_.ToString()`, which is correct for
a line with text in it, but an ErrorRecord wrapping an EMPTY stderr line returns the
type name from `ToString()` rather than an empty string. `$_.Exception.Message` is
the line the program actually wrote, empty string included.

Measured in PowerShell 7.4.6: three stderr lines, the middle one empty, render as
`[  text]`, `[System.Management.Automation.RemoteException]`, `[  next line]` through
`ToString()`, and `[  text]`, `[]`, `[  next line]` through `Exception.Message`.

The error COUNT was never affected, because a blank line matches neither pattern.
This is readability only, but it is the same family as the bug the unwrap was written
for, and it was found the only way it could be: by running the thing and reading the
output rather than reasoning about it.

## The rule

Unwrap an ErrorRecord with `$_.Exception.Message`, not `$_.ToString()`, and map a
result of `System.Management.Automation.RemoteException` to an empty string. Applied
to `check.ps1` and `movie.ps1` in all six repos in one commit.

## Replaces or contradicts

Extends the `*> $log` unwrap rule in `GODOT.md` (Commands): the existing text says to
call `ToString()` on the ErrorRecord. That is right for a line carrying text and wrong
for a blank one. The rule should name `Exception.Message` instead.
