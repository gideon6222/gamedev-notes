# `-AllowFail` in `check.ps1` cannot fire, because `$ErrorActionPreference='Stop'` kills the script on a native command's stderr before the exit-code check is ever reached

**Game:** stillwater  **Date:** 2026-09-09  **Belongs in:** TESTING.md / the local gate (and the same fix is owed to `C:\dev\godot-template\scripts\check.ps1`, which is where this came from)

## What happened

`scripts/check.ps1` printed one line and stopped:

```
Godot_v4.7.2-stable_win64_console.exe : ERROR: Can't open file from path 'res://build/movie/first-cast/frame.wav'.
```

No `import ok`, no `tests`, no `all green`, and no non-zero summary either. The import
step is declared `-AllowFail` precisely so an import warning cannot block the gate, so the
gate should have carried on. It did not, and the reason is not Godot.

`check.ps1` sets `$ErrorActionPreference = 'Stop'` at the top and runs every step as
`& $godot @a *> $log`. Under PowerShell 5.1 a native command's stderr becomes an
ErrorRecord, and with the preference set to `Stop` that ErrorRecord is *terminating* — it
throws out of the function before `$LASTEXITCODE`, before the `Select-String '^ERROR'`
count, and before the `$AllowFail` test that was written to forgive exactly this. The
redirection does not save it: `*>` sends the text to the log and the ErrorRecord still
terminates. Measured directly, both halves of it:

```powershell
$ErrorActionPreference='Stop';     & cmd /c 'echo boom 1>&2' *> out.txt; Write-Host 'REACHED-AFTER'   # never prints
$ErrorActionPreference='Continue'; & cmd /c 'echo boom 1>&2' *> out.txt; Write-Host 'REACHED-AFTER'   # prints
```

So `-AllowFail` had never been exercised. It looked correct for as long as Godot happened
to write nothing to stderr, which was until `/playtest desk` filmed a run: the movie writer
leaves its output *inside the project* at `build/movie/<scenario>/`, 380-odd PNGs plus a
2.8 MB `frame.wav`, and `--import` walks `build/` like any other folder. The PNGs reimport
(slowly). The wav does not open, Godot writes one line to stderr, and the whole gate dies at
step one. What that looks like from the outside is "the check suite is broken", when the
tests are fine — run direct, 97 tests / 10810 assertions and smoke's 327 all pass.

Two separate faults, and the second is the one that costs a session: the film output should
not be somewhere `--import` scans, and a `-AllowFail` that cannot fail is not a safety net.

## The rule

In any `.ps1` that shells out and then inspects `$LASTEXITCODE`, either drop
`$ErrorActionPreference = 'Stop'` around the call or wrap the call in
`$ErrorActionPreference='Continue'` for its duration — otherwise one stderr line from the
child terminates the script before your own check runs, and every `-AllowFail`,
`-ErrorAction SilentlyContinue` and exit-code branch downstream is decoration. Verify such a
branch the way any other untested construct is verified: make the child write to stderr on
purpose and confirm the script continues. And keep generated run output (film frames,
recordings) out of any directory Godot imports — `build/` is inside the project, so
`--import` reimports every frame and chokes on the movie writer's `frame.wav`.

## Replaces or contradicts

Nothing yet in TESTING.md. It is standing rule 11 ("a construct that cannot fail is
untested, not safe") applied to the gate itself, which is the one script nobody thinks to
test.
