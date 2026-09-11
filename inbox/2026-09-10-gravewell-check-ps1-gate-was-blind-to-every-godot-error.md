# `check.ps1` counted zero errors because PowerShell rewrote every one of them

**Cost:** a smoke run that threw inside a check, skipped every assertion after the
throw, and printed `smoke ok ... errors 0`. Two regression tests I had just written and
"verified" were among the skipped ones. Found in Gravewell; the same code is in the
template, so **every game built from it has had a blind gate**.

## The mechanism

```powershell
try { & $godot @a *> $log } finally { ... }
$errs = Select-String -Path $log -Pattern '^(SCRIPT )?ERROR' | Measure-Object | ...
```

`*>` sends a native command's **stderr** through PowerShell's error channel. Each line
comes out as an `ErrorRecord`, which formats as

```
Godot_v4.7.2-stable_win64_console.exe : SCRIPT ERROR: Invalid call. Nonexistent 'int' constructor.
    + CategoryInfo          : NotSpecified: (SCRIPT ERROR: I...:String) [], RemoteException
```

in **UTF-16**. So the `^` anchor can never match: the line starts with the executable's
name. `errs` is structurally always 0 for anything Godot writes to stderr, which is every
`ERROR:`, `SCRIPT ERROR:` and `USER ERROR:` it has.

## The fix

```powershell
& $godot @a 2>&1 |
  ForEach-Object { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_.ToString() } else { $_ } } |
  Out-File -FilePath $log -Encoding utf8
```

`ToString()` gives back the line Godot actually wrote, and `-Encoding utf8` makes the log
greppable by every other tool too. Pattern widened to `'^(SCRIPT |USER )?ERROR'`.

## The lessons under it

1. **A log written by a shell is not the program's output until you prove it is.** Decode
   the bytes and look at one known-bad line before trusting any pattern run over it.
2. **`int(null)` throws in GDScript**, and an unset shader uniform reads back as null. A
   throw inside a check function aborts the rest of that function; the harness keeps going
   and reports "all passing" for the assertions it did reach. Set every uniform a test
   reads explicitly, even when the shader's default is already the right value.
3. **Verify a regression test by reintroducing the bug, and check the assertion COUNT.**
   Mine went from 140 to 142 once the throw was gone: two assertions had never run. The
   count is the tell that "all passing" was hiding something, and it is cheap to read.

**Related:** the `$ErrorActionPreference = 'Stop'` trap in the same function, three scripts
over. Both come from PowerShell treating native stderr as an object rather than as text.
