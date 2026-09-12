# PowerShell traps in the scripts

**Game:** all of them - `check.ps1`, `movie.ps1`, `device.ps1`, `doctor.ps1`, `new-game.ps1`
**Status:** every trap here has been paid for and every fix is in the template
**Read when:** a script dies before it runs, a gate prints a verdict with no reason, a log does
not contain what the program printed, an adb flag appears to be ignored, or a check fires on a
repo that cannot fix it.

These are PowerShell faults rather than Godot ones, but the scripts that drive Godot are where
they bite, so the standing rules sit in `GODOT.md` under Toolchain and the mechanism is here. They
share one shape: **PowerShell treats a native command's stderr as an object and binds its own
parameters before the command sees them**, so text you expect to flow through is intercepted and a
script can die before the first line of its body runs.

Two takeaways worth carrying to any script in this studio:

- A script that cannot START says nothing useful about why. Keep `param()` defaults to literals
  and derive anything computed in the body, where a fallback and an error message both exist.
- A gate step that fails must print the reason and not only the verdict, and must never fail for
  a condition the repo being gated cannot fix.

## $ErrorActionPreference, and the Native helper

**`$ErrorActionPreference = 'Stop'` makes a native command's stderr terminate the script
before any `$LASTEXITCODE` check below it runs.** Redirection does not save it - `*>` and
`2>$null` move the text and the ErrorRecord still throws - so every `-AllowFail` flag and
exit-code branch downstream is decoration. `check.ps1` died at step one on an import warning it
was told to forgive; `new-game.ps1` died on a `gh repo view` probe that is *supposed* to fail on
a new game; `movie.ps1` died on Godot's normal shutdown warning **after** writing all 3,840
frames and before tiling one. Wrap every native call whose failure is expected:

```powershell
function Native([scriptblock]$Block) {
  $prev = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try { & $Block } finally { $ErrorActionPreference = $prev }
}
```

**Never compute a parameter default from `$PSScriptRoot`.** Launched through
`powershell -File` from a non-PowerShell shell it binds as an EMPTY string while parameter
defaults are evaluated, so `[string] $Notes = (Split-Path $PSScriptRoot -Parent)` is a
terminating error inside `param()`, before the script's own error handling, logging or usage text
exists. `doctor.ps1` died there and the visible symptom was `framework FAIL exit 1` on every
game with nothing wrong in any of them - the error text only appeared when it was run by hand.
Default to `''` and resolve in the body, where the variable is reliable and
`Split-Path $MyInvocation.MyCommand.Path -Parent` is the fallback. Generally: **a param default
that can throw takes the whole script with it**, so keep defaults to literals and derive in the
body. And a gate step that fails must print the REASON, not only the verdict.

**A cross-cutting check must not fail a gate for a condition the gated repo cannot fix.** Making
every game's commit gate run the knowledge-base checks turned wildform's gate red because a
DIFFERENT game's session had filed three lessons in the wrong header format: nothing about
wildform was wrong and nothing about wildform could fix it. Scope the check to the repo named in
`-Repo`, or report it as a WARN so it is seen without blocking a release that is sound.

**Quote every adb flag beginning with w, v, d or c** (`'-W'`, `'-S'`). PowerShell binds
parameters before handing anything to the native command, and a bare `-W` prefix-matches
`-WarningAction` and `-WarningVariable`, so `device.ps1 launch` raised `AmbiguousParameter`
against itself and had **never once worked**. `ValueFromRemainingArguments` does not protect you:
the binder still tries parameter matching first.

## What `*> $log` actually writes

**But `*> $log` does not write what the program printed.** It sends native stderr through
PowerShell's error channel, so every line arrives as an `ErrorRecord` rendered
`Godot...exe : SCRIPT ERROR: ...` plus a `+ CategoryInfo` block, in UTF-16, and `check.ps1`
counting `'^(SCRIPT )?ERROR'` over it reported **`errors 0` for every Godot error in every step
of every game built from the template**. Unwrap the records and write UTF-8:

```powershell
& $godot @a 2>&1 |
  ForEach-Object { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_.Exception.Message } else { $_ } } |
  Out-File -FilePath $log -Encoding utf8
```

Same family as the `$ErrorActionPreference = 'Stop'` trap: PowerShell treats native stderr as
an object, not text. **A log written by a shell is not the program's output until you have
decoded the bytes and looked at one known-bad line.** `check.ps1`, `movie.ps1` and `device.ps1`
all carry the unwrap.

**Unwrap with `Exception.Message`, not `ToString()`.** An ErrorRecord wrapping an EMPTY stderr
line returns the bare type name, so a `printerr("")` spacing an error block renders as
`System.Management.Automation.RemoteException` and every spacer line in a ship gate's own error
block is replaced by a class name (PowerShell 7.4.6, M; `Exception.Message` gives the empty
string). Map that type name to an empty string as well. The error COUNT is never affected,
because a blank line matches no pattern, which is why this survived the fix it is a family of.

## Never rewrite a source file through Get-Content/Set-Content

PowerShell 5.1 reads a BOM-less file as ANSI and corrupts every non-ASCII byte. Use the Edit/Write
tools, or `[System.IO.File]::ReadAllText/WriteAllText` with `UTF8Encoding($false)`. `stamp.ps1`,
which rewrites `src/build_stamp.gd` on every build, is the one script that has to get this right.
`.gitattributes` is `* text=auto eol=lf`; mixed endings inside a file defeat every exact-match
edit silently.
