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

## A script path containing a space needs `-File`, and the error blames the wrong thing

`powershell C:\dev\Claude outputs\digest-finish.ps1` does not run that script. Without `-File`,
powershell treats its argument as a **command line**, so it splits on the space and tries to run
`C:\dev\Claude`, reporting:

```
C:\dev\Claude : The term 'C:\dev\Claude' is not recognized as the name of a cmdlet, function,
script file, or operable program.
```

The path in that message is a truncation of a path that exists and is spelled correctly, so the
error invites you to go looking for a missing file. Quoting alone does not fix it either, because
`-Command` mode would then evaluate the quoted string as an expression and simply print it. The
form that runs the script is:

```powershell
powershell -File "C:\dev\Claude outputs\digest-finish.ps1" -DryRun
```

Same family as the rest of this file: **PowerShell parses and resolves before your code runs**, so
a correct script can report itself as missing. Any path handed to `powershell`, `Start-Process` or a
scheduled task gets `-File` and quotes if there is any chance of a space in it.

## A wrapper named after the command it wraps calls itself

A script written to check a native call's exit code wrapped `git`:

```powershell
function Git { param([string] $Repo, [string[]] $Arguments) & git -C $Repo @Arguments; return $LASTEXITCODE }
if ((Git $Repo @('add','--','CRAFT.md')) -ne 0) { ... }
```

Two separate faults, neither visible in a parse check, both found only by running it.

**The function shadows the command.** PowerShell resolves names case-insensitively and prefers a
function over an external executable, so `& git` inside `function Git` calls **itself**. Measured
symptoms, in order of discovery: a stream of zeros where one exit code was expected, then a
two-minute hang, then `The script failed due to call depth overflow` once output was captured to a
file rather than read from a terminated pipe. None of the three names the cause.

**The wrapper returned the tool's stdout along with the exit code.** A native command's output
becomes part of the enclosing function's own output, so the caller received an array of git's
lines with the exit code appended - `git status --porcelain` came back an `Object[]` of six
elements, and `-ne 0` against an array is truthy, so a clean call was reported as a failure
(measured against the fixed form, which returns a bare `Int32 0`).

The obvious fix, piping to `Out-Host`, introduces a third fault: `Out-Host` **deadlocks** inside an
`if` condition, which is how every call in the script was written.

**Never name a wrapper after the command it wraps** - `RunGit`, not `Git`. **A wrapper returns the
exit code and nothing else**: capture the output (`$out = & tool args 2>&1`), take
`$code = $LASTEXITCODE` on the very next line before anything else can reset it, print the
captured lines yourself, and return `$code`. Never pipe to `Out-Host` to get text onto the console.
Same family as the rest of this file: PowerShell resolves names and routes streams before your
code runs, so a script that looks correct can never have executed the thing you meant. And a
parse check is not a test - all three broken versions parsed clean; only running the script
against a throwaway git repo found any of this.
