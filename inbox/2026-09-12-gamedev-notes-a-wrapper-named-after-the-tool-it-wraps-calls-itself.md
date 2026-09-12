# A PowerShell wrapper named after the tool it wraps calls itself, and a wrapper that leaves the tool's stdout in the pipeline turns every successful call into a failure

**Game:** gamedev-notes (tooling, applies to every `.ps1` in the studio)  **Date:** 2026-09-12
**Belongs in:** GODOT.md / Toolchain, and `techniques/powershell-traps-in-the-scripts.md`

## What happened

A script written to finish a digest wrapped git so each call's exit code could be checked:

```powershell
function Git { param([string] $Repo, [string[]] $Arguments) & git -C $Repo @Arguments; return $LASTEXITCODE }
if ((Git $Repo @('add','--','CRAFT.md')) -ne 0) { ... }
```

Two separate faults, both found by running it rather than by reading it, and neither visible in a
parse check, which passed clean on all three broken versions.

**The function shadows the command.** PowerShell resolves command names case-insensitively and
prefers a function over an external executable, so `& git` inside `function Git` calls **itself**.
Measured symptom, in order of discovery: a stream of zeros where one exit code was expected, then a
two-minute hang, then `The script failed due to call depth overflow` once output was captured to a
file rather than read from a terminated pipe. Nothing in any of those three symptoms names the
cause.

**The wrapper returned the tool's stdout along with the exit code.** A native command's output
becomes part of the enclosing function's output, so the caller received an array of git's own lines
with the exit code appended. `git status --porcelain` returned an `Object[]` of **6 elements**, and
`-ne 0` against an array returns a non-empty array, which is truthy: **a clean git call was
reported as a failure.** Measured against the fixed form, which returns `Int32 0`.

The obvious fix for the second fault, `| Out-Host`, introduced a third: piping to `Out-Host`
**deadlocks** when the call sits inside an `if` condition, which is how every call in the script was
written. Capture to a variable, read `$LASTEXITCODE` into a local immediately, then print the
captured lines.

## The rule

**Never name a wrapper after the command it wraps.** `RunGit`, not `Git`. A function that a native
tool's own name can match will be called instead of the tool, and the failure arrives as a hang or
a depth overflow rather than as anything that names the function.

**A wrapper around a native command returns its exit code and nothing else.** Capture the output
(`$out = & tool args 2>&1`), take `$code = $LASTEXITCODE` on the very next line before anything else
can reset it, print the captured lines yourself, and return `$code`. Do not pipe to `Out-Host` to
get the text onto the console, because that deadlocks inside a condition. Unwrap an ErrorRecord with
`Exception.Message`, never `ToString()`.

**And a parse check is not a test.** All three versions parsed clean. `doctor.ps1`-style static
checks and `Parser::ParseFile` cannot see any of this: the only thing that found it was running the
script against a throwaway git repo and asserting on what it did, including that an untracked
directory and a dirty unrelated file were still untracked and dirty afterwards.

## Replaces or contradicts

Nothing. It extends the PowerShell traps already collected in
`techniques/powershell-traps-in-the-scripts.md`, which covers `$ErrorActionPreference`, parameter
binding and `*> $log`, and says nothing about naming a wrapper or about what a wrapper returns. All
of these are the same family: **PowerShell resolves names and routes streams before your code runs**,
so a script that looks correct can never have executed the thing you meant.
