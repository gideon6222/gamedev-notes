# `movie.ps1` in the template still dies on Godot's own exit warning, and the first filmed run of any game is where you find out

**Game:** candle-gift  **Date:** 2026-09-10
**Belongs in:** `TESTING.md` / filming a run, and as a fix owed to `C:\dev\godot-template`.

## What happened

The 2026-09-10 digest folded in two lessons about `$ErrorActionPreference = 'Stop'` turning a
native command's stderr into a terminating error before any exit-code check runs. Both named
`check.ps1` and `new-game.ps1`, and both noted the fix was "still owed to `movie.ps1` and
`device.ps1`".

Within the hour, bringing filming into Candle Gift for the first time, `movie.ps1` died on
exactly that:

```
Godot_v4.7.2-stable_win64_console.exe : WARNING: 4 ObjectDB instances were leaked at exit
At C:\dev\candle-gift\scripts\movie.ps1:72 char:3
+   & $godot @gargs *> "$out\godot.log"
+ FullyQualifiedErrorId : NativeCommandError
```

**480 frames were already on disk.** The film had worked. What failed was the script's
handling of a routine Godot exit warning, and what it printed was a `NativeCommandError` at
the Godot call - which reads as "filming is broken", not as "the wrapper mishandled a
warning". The next line down would have read `$LASTEXITCODE` and been perfectly happy.

Godot writes several things to stderr on a normal exit: leaked ObjectDB instances, "resources
still in use at exit". So this is not an edge case for `movie.ps1`, it is **every run**. The
tool could never have completed once on this machine.

## The rule

**When a digest records that a fix is owed to other scripts, the fix is not done.** The two
folded lessons both ended with "the same fix is still owed to `movie.ps1` and `device.ps1`",
and the owed half is the half that then cost the next session time. Either apply it across
the family in the same commit, or the note is a bug report filed against yourself.

**A wrapper around a tool must not treat the tool's own chatter as failure.** `movie.ps1`
already had a correct exit-code check and a correct "did any frames get written" check; the
preference threw before either. Every native call in a `.ps1` that branches on
`$LASTEXITCODE` runs through:

```powershell
function Native([scriptblock] $Block) {
  $prev = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try { & $Block } finally { $ErrorActionPreference = $prev }
}
```

**And the first time a tool is used in a repo is a test of the tool, not of the repo.** This
was Candle Gift's first filmed run in five rounds of work. Nothing was wrong with the game.

## Still owed

`C:\dev\godot-template\scripts\movie.ps1` and `device.ps1` carry the same fault, so every
game scaffolded from the template inherits a film tool that cannot finish. Deliberately not
edited from this session, because several sessions run against that repo at once - but it is
a one-function change and somebody should make it.

## Also observed, unresolved

Candle Gift prints `2 resources still in use at exit` and `4 ObjectDB instances were leaked
at exit` intermittently - on some `check.sh` runs and on every filmed run. It is a shutdown
warning rather than a runtime fault and the suites are green, so it is recorded rather than
chased. Worth knowing it is there before someone reads it as evidence of something else.
