# `$PSScriptRoot` is empty while parameter defaults are being bound, and a `Split-Path` on it kills the script before it runs

**Game:** wildform  **Date:** 2026-09-12  **Belongs in:** `GODOT.md` under the toolchain and
scripts section (it is a PowerShell trap, not a Godot one, but that is where the scripts live).

## What happened

`scripts\doctor.ps1` took the notes repo as a parameter with a computed default:

```powershell
param(
  [string] $Notes = (Split-Path $PSScriptRoot -Parent),
  ...
)
```

Launched through `powershell -NoProfile -File ...` from a non-PowerShell shell, `$PSScriptRoot`
binds as an **empty string** while the parameter defaults are evaluated. `Split-Path ''` is a
terminating error, `$ErrorActionPreference = 'Stop'` is set at the top, and the script died on
its own `param()` block before running a single check.

The symptom was not a PowerShell error anyone read. `check.ps1` had just been changed to run
the doctor as the last step of every gate, so the visible result was **`framework FAIL exit 1`
on every game**, with nothing wrong in any of them. The error text only appeared when the
script was run by hand.

`$PSScriptRoot` is populated normally once the body starts. It is only the parameter-binding
phase that is unreliable, and only under some hosts - which is why this works when you test it
from a PowerShell prompt and fails from the gate.

## The rule

**Never compute a parameter default from `$PSScriptRoot`.** Default it to `''` and resolve it
in the body, where the variable is reliable and a fallback is available:

```powershell
param([string] $Notes = '')
...
if (-not $Notes) {
  $here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path $MyInvocation.MyCommand.Path -Parent }
  $Notes = Split-Path $here -Parent
}
```

More generally: **a param default that can throw takes the whole script with it**, before any
of its own error handling, logging or usage text exists. Keep defaults to literals and move
anything derived into the body.

## And a second one, about where a check is allowed to fail

The same change made every game's commit gate depend on the shared knowledge base being tidy.
It fired immediately: wildform's gate went red because a **different game's** session had filed
three inbox lessons in a different header format. Nothing about wildform was wrong and nothing
about wildform could fix it.

A cross-cutting check is worth running from a gate. **It should not fail that gate for a
condition the repo being gated cannot fix.** Either scope it to the repo named in `-Repo`, or
report it as a WARN so it is seen without blocking a release that is otherwise sound.

## Replaces or contradicts

Nothing. It extends the existing rule that a script which cannot do its job should be fixed
rather than worked around - the addition is that a script which cannot START says nothing
useful about why, so a gate step that fails must print the reason and not just the verdict.
