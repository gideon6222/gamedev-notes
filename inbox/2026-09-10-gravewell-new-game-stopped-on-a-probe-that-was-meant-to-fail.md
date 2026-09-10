# `new-game.ps1` died creating the repo, because the probe that asks "does this repo exist yet" is *supposed* to fail

**Game:** gravewell (scaffolding it)  **Date:** 2026-09-10
**Belongs in:** `TESTING.md` beside the `check.ps1` `-AllowFail` lesson, which is the same bug
in a different script, and `GODOT.md` under the toolchain, for the PATH half.

## What happened, twice, in one command

**First failure.** `new-game.ps1` refused to start: "gh is not installed. Run
setup\install.ps1, then gh auth login." `gh` was installed, version 2.100.0, signed in as
gideon6222, and its directory was in the **user** PATH in the registry. What it was not in was
the environment of the shell doing the asking, because winget writes the user PATH and a
process only reads that once, at startup. A Claude session's shell can be hours older than the
install. This is already recorded for `ffmpeg` and `movie.ps1`; it is the same fault in a
second script, and the error message again sent the reader off to reinstall something that was
already there.

**Second failure**, after resolving `gh` by hand. The script got all the way through the copy,
the rename, the changelog, the stubs, the first commit and a green tests-and-smoke run, then
died here:

```
gh : GraphQL: Could not resolve to a Repository with the name 'gideon6222/gravewell'.
At new-game.ps1:166 char:5
+     gh repo view "$Owner/$Slug" 2>$null | Out-Null
```

That line is a **probe**. It asks whether the remote already exists so the script can either
add a remote or create the repo, and on a genuinely new game it is *meant* to fail. The next
line reads `$LASTEXITCODE` and branches on it correctly. The exit-code check was never
reached, because `$ErrorActionPreference = 'Stop'` at the top of the file turns a native
command's stderr into a terminating `NativeCommandError` first. `2>$null` does not help: the
redirection happens after PowerShell has already decided to throw.

So the script could create a repo that already existed and could not create one that did not.

## The rule

**Under `$ErrorActionPreference = 'Stop'`, a native command's stderr terminates the script
before any exit-code check below it runs.** Every native call whose failure is expected, or
which merely chats to stderr, has to be run with the preference relaxed. A redirection is not
enough and neither is `-AllowFail` as a parameter, which is how `check.ps1` failed the same
way.

The fix in both scripts is one helper, and it is worth copying rather than reinventing:

```powershell
function Native([scriptblock]$Block) {
  $prev = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try { & $Block } finally { $ErrorActionPreference = $prev }
}
```

Then `Native { gh repo view "$Owner/$Slug" 2>&1 | Out-Null }` and the `$LASTEXITCODE` check
below it is reached and means what it says.

**And a script that shells out should re-read the user PATH before believing `Get-Command`:**

```powershell
$userPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
if ($userPath) {
  $have = $env:PATH -split ';'
  $missing = @($userPath -split ';' | Where-Object { $_ -and $have -notcontains $_ })
  if ($missing.Count) { $env:PATH = ($missing -join ';') + ';' + $env:PATH }
}
```

Six lines at the top of the file and it fixes `gh`, `adb` and `ffmpeg` at once for every
long-running session, instead of one tool at a time at the call site.

## What was done

Both fixes are in `scripts/new-game.ps1` now, and the script was proved by deleting the
half-scaffolded copy and running it again from clean: repo created, secrets set, pushed, first
CI run reported. **The same two fixes are still owed to `C:\dev\godot-template\scripts\check.ps1`**
and to `movie.ps1` and `device.ps1`, which shell out to Godot, ffmpeg and adb respectively and
carry the same two faults.

## The part worth more than the fix

Both failures were **silent about the real cause and loud about a wrong one**. "gh is not
installed" is false and sends you to an installer. A GraphQL "could not resolve" error looks
like a permissions or a network problem, and is in fact the script working correctly one line
too early. `TESTING.md` already says a construct that cannot fail is untested rather than safe.
This is the mirror of it: **a branch whose condition can only be reached by a failure needs the
failure path exercised once, or it is untested in exactly the case it exists for.** Nobody had
ever scaffolded a game whose repo did not already exist while this preference was set.
