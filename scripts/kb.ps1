<#
.SYNOPSIS
  Safe git operations on the shared knowledge base (C:\dev\gamedev-notes).

.DESCRIPTION
  Several Claude Code sessions write to this repo at once. This script is the only way a
  session should commit here: it pulls with rebase first, stages ONLY the files named, commits
  ONLY the files named, pushes, and retries the push once after a re-pull. It refuses a
  blanket add and it refuses a pattern.

  Actions:
    pull     rebase onto origin and report the head commit
    status   short status and the last five commits
    commit   -Files <paths> -Message <text>; stages, commits and pushes exactly those files.
             A named file that is tracked but no longer on disk is committed as a deletion.
    lease    take the /digest lease, so two digests cannot run over each other. Refuses while
             someone else's lease is less than 30 minutes old, naming the holder and the
             expiry. A lease older than that is stale and is taken over, loudly.
    release  give the lease back

  The lease file is .git/kb-lease inside the repo's git directory. That location is
  deliberate: it can never be tracked, staged or pushed, so the lease needs no .gitignore
  entry and can never ride along in someone else's commit.

.EXAMPLE
  scripts\kb.ps1 pull
  scripts\kb.ps1 commit -Files inbox\2026-09-10-stillwater-scroll-drag.md -Message "Lesson: ScrollContainer needs a hand-translated drag"
  scripts\kb.ps1 commit -Files playtests\stillwater.md -Message "Playtest 2026-09-10"
  scripts\kb.ps1 status
  scripts\kb.ps1 lease -Owner digest
  scripts\kb.ps1 release -Owner digest
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory, Position = 0)] [ValidateSet('pull', 'commit', 'status', 'lease', 'release')] [string] $Action,
  [string[]] $Files,
  [string] $Message,
  [string] $Owner = "$env:USERNAME@$env:COMPUTERNAME",
  [string] $Repo = 'C:\dev\gamedev-notes'
)
$ErrorActionPreference = 'Stop'

# How long a lease is worth. Longer than any digest has taken; short enough that a session
# killed mid-digest does not lock the repo for the rest of the day. 30 was tight for a
# digest of twenty-plus lessons, so it is 45. A stale lease is taken over, never a blocker.
$LeaseMinutes = 45

# git writes progress, "Everything up-to-date" and expected failures to stderr, and
# $ErrorActionPreference = 'Stop' turns any of that into a terminating NativeCommandError
# BEFORE the exit-code check below it ever runs - which made every `throw` in this script
# unreachable. Every native call goes through this, so the exit code stays the only thing
# that decides. (Same helper as scripts\new-game.ps1.)
function Native([scriptblock]$Block) {
  $prev = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try { & $Block } finally { $ErrorActionPreference = $prev }
}

function Get-LeasePath {
  # .git is a directory in the main clone and a FILE in a worktree, so ask git rather than
  # assuming. The answer is always outside the working tree, so it can never be committed.
  $gitDir = Native { git rev-parse --absolute-git-dir }
  if ($LASTEXITCODE -ne 0 -or -not $gitDir) { throw "not a git repository: $Repo" }
  Join-Path ($gitDir -join '').Trim() 'kb-lease'
}

Push-Location $Repo
try {
  switch ($Action) {
    'status' {
      Native { git status --short }
      Native { git log --oneline -5 }
    }
    'pull' {
      Native { git pull --rebase --autostash --quiet }
      if ($LASTEXITCODE -ne 0) { throw "pull --rebase failed; resolve in $Repo before continuing" }
      Write-Host "up to date: $(Native { git log --oneline -1 })"
    }
    'lease' {
      $leasePath = Get-LeasePath
      if (Test-Path -LiteralPath $leasePath) {
        $held = Get-Content -LiteralPath $leasePath -Raw
        $m = [regex]::Match($held, '(?m)^acquired=(.+)$')
        $acquired = $null
        if ($m.Success) {
          try { $acquired = [datetimeoffset]::Parse($m.Groups[1].Value.Trim(), [cultureinfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind) } catch { $acquired = $null }
        }
        # An unparseable or timestamp-less lease is treated as stale rather than as
        # permanent: a corrupt file must never be able to lock the repo forever.
        if ($null -ne $acquired) {
          $expires = $acquired.AddMinutes($LeaseMinutes)
          if ($expires -gt [datetimeoffset]::UtcNow) {
            Write-Host "lease is held:" -ForegroundColor Yellow
            $held.TrimEnd() -split "`n" | ForEach-Object { Write-Host "    $_" }
            Write-Host "    expires $($expires.ToUniversalTime().ToString('o')) (in $([int]($expires - [datetimeoffset]::UtcNow).TotalMinutes) min)"
            throw "another session holds the lease; wait for it or run 'kb.ps1 release' there"
          }
          Write-Host "taking over a stale lease (held since $($acquired.ToUniversalTime().ToString('o')), older than $LeaseMinutes min):" -ForegroundColor Yellow
        } else {
          Write-Host "taking over an unreadable lease file:" -ForegroundColor Yellow
        }
        $held.TrimEnd() -split "`n" | ForEach-Object { Write-Host "    $_" }
      }
      $body = "owner=$Owner`nacquired=$([datetimeoffset]::UtcNow.ToString('o'))`npid=$PID`n"
      [System.IO.File]::WriteAllText($leasePath, $body, (New-Object System.Text.UTF8Encoding($false)))
      Write-Host "lease taken by $Owner (pid $PID), good for $LeaseMinutes minutes. Release it with: scripts\kb.ps1 release"
    }
    'release' {
      $leasePath = Get-LeasePath
      if (Test-Path -LiteralPath $leasePath) {
        Remove-Item -LiteralPath $leasePath -Force
        Write-Host "lease released"
      } else {
        Write-Host "no lease to release"
      }
    }
    'commit' {
      # `powershell kb.ps1 commit -Files a,b` binds two files. `powershell -File kb.ps1 ...
      # -Files a,b` binds ONE string with a comma in it, because -File hands arguments over
      # without PowerShell's own parsing. Both spellings are in use, so split here and the
      # difference disappears. No filename in this repo contains a comma.
      # Forward slashes: git on Windows accepts both, git anywhere else accepts one.
      $Files = @($Files | ForEach-Object { $_ -split ',' } | ForEach-Object { ($_.Trim() -replace '\\', '/') } | Where-Object { $_ })
      if (-not $Files -or $Files.Count -eq 0) { throw "commit needs -Files (stage by name; a blanket add here has swept up another session's work before)" }
      if (-not $Message) { throw "commit needs -Message" }
      $removed = @()
      foreach ($f in $Files) {
        if ($f -match '^\s*(-A|--all|-u|\.|\*)\s*$') { throw "refusing blanket add '$f'" }
        # A pattern is a blanket add wearing a narrower name: `inbox/*` passes a literal
        # filter and Test-Path says yes to it, and it stages every unfolded lesson in the
        # directory including the ones another session is still writing.
        if ($f -match '[\*\?\[\]]') { throw "refusing pattern '$f': name each file. A glob here stages whatever else happens to match, including another session's work." }
        # `:(exclude)`, `:!` and `:/` are git pathspec magic, not filenames.
        if ($f.TrimStart() -like ':*') { throw "refusing pathspec magic '$f': name a plain file path." }
        if (-not (Test-Path -LiteralPath $f)) {
          # A file that is not on disk but IS tracked is a deletion (git rm, or a plain
          # delete). `git add -- <path>` stages a removal for a tracked path, so it is
          # named and committed exactly like an edit. Before this branch existed, /digest
          # step 7 (delete the folded inbox files, then commit them by name) could not be
          # run through this script at all.
          # Tracked means in the index (a plain delete) OR in HEAD (after `git rm`, which
          # has already taken it out of the index). Either way `git add -- <path>` stages
          # the removal.
          Native { git ls-files --error-unmatch -- $f 2>$null | Out-Null }
          $inIndex = ($LASTEXITCODE -eq 0)
          Native { git cat-file -e ("HEAD:" + $f.TrimStart('./')) 2>$null }
          $inHead = ($LASTEXITCODE -eq 0)
          if (-not $inIndex -and -not $inHead) { throw "no such file: $f (not on disk and not tracked, so there is nothing to commit)" }
          $removed += $f
          continue
        }
        if (-not (Test-Path -LiteralPath $f -PathType Leaf)) { throw "'$f' is a directory; name the files inside it. A directory stages everything under it, which is the blanket add by another route." }
      }
      Native { git pull --rebase --autostash --quiet }
      if ($LASTEXITCODE -ne 0) { throw "pull --rebase failed before commit" }
      # Deletions are staged with rm --cached, which is a no-op for a path `git rm` already
      # took out of the index; `git add` on such a path errors "did not match any files".
      if ($removed.Count -gt 0) {
        Native { git rm --cached --quiet --ignore-unmatch -- $removed }
        if ($LASTEXITCODE -ne 0) { throw "git rm --cached failed for $($removed -join ', ')" }
      }
      $present = @($Files | Where-Object { $removed -notcontains $_ })
      if ($present.Count -gt 0) {
        Native { git add -- $present }
        if ($LASTEXITCODE -ne 0) { throw "git add failed" }
      }
      # Both the probe and the commit are scoped to $Files. Without the pathspec the probe
      # passes on somebody else's staged change and the commit then carries it.
      Native { git diff --cached --quiet -- $Files }
      if ($LASTEXITCODE -eq 0) {
        Write-Host "nothing to commit for the named files. If you just edited them, look at the log: another session may have committed them already."
        Native { git log --oneline -3 }
        break
      }
      Native { git commit -q -m $Message -m "Co-Authored-By: Claude <noreply@anthropic.com>" -- $Files }
      if ($LASTEXITCODE -ne 0) { throw "git commit failed" }
      Native { git push --quiet 2>&1 | Out-Null }
      if ($LASTEXITCODE -ne 0) {
        Native { git pull --rebase --autostash --quiet }
        if ($LASTEXITCODE -ne 0) { throw "push was rejected and the re-pull failed; resolve in $Repo" }
        Native { git push --quiet }
        if ($LASTEXITCODE -ne 0) { throw "push failed twice; check $Repo" }
      }
      Write-Host "committed and pushed: $(Native { git log --oneline -1 })"
    }
  }
} finally { Pop-Location }
