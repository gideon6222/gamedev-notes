<#
.SYNOPSIS
  Safe git operations on the shared knowledge base (C:\dev\gamedev-notes).

.DESCRIPTION
  Several Claude Code sessions write to this repo at once. This script is the only way a
  session should commit here: it pulls with rebase first, stages ONLY the files named, commits,
  pushes, and retries the push once after a re-pull. It refuses a blanket add.

.EXAMPLE
  scripts\kb.ps1 pull
  scripts\kb.ps1 commit -Files inbox\2026-09-10-stillwater-scroll-drag.md -Message "Lesson: ScrollContainer needs a hand-translated drag"
  scripts\kb.ps1 commit -Files playtests\stillwater.md -Message "Playtest 2026-09-10"
  scripts\kb.ps1 status
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory, Position = 0)] [ValidateSet('pull', 'commit', 'status')] [string] $Action,
  [string[]] $Files,
  [string] $Message,
  [string] $Repo = 'C:\dev\gamedev-notes'
)
$ErrorActionPreference = 'Stop'
Push-Location $Repo
try {
  switch ($Action) {
    'status' {
      git status --short
      git log --oneline -5
    }
    'pull' {
      git pull --rebase --autostash --quiet
      if ($LASTEXITCODE -ne 0) { throw "pull --rebase failed; resolve in $Repo before continuing" }
      Write-Host "up to date: $(git log --oneline -1)"
    }
    'commit' {
      if (-not $Files -or $Files.Count -eq 0) { throw "commit needs -Files (stage by name; a blanket add here has swept up another session's work before)" }
      if (-not $Message) { throw "commit needs -Message" }
      foreach ($f in $Files) {
        if ($f -match '^\s*(-A|\.|\*)\s*$') { throw "refusing blanket add '$f'" }
        if (-not (Test-Path $f)) { throw "no such file: $f" }
      }
      git pull --rebase --autostash --quiet
      if ($LASTEXITCODE -ne 0) { throw "pull --rebase failed before commit" }
      git add -- $Files
      git diff --cached --quiet
      if ($LASTEXITCODE -eq 0) {
        Write-Host "nothing to commit for the named files. If you just edited them, look at the log: another session may have committed them already."
        git log --oneline -3
        break
      }
      git commit -q -m $Message -m "Co-Authored-By: Claude <noreply@anthropic.com>"
      git push --quiet 2>&1 | Out-Null
      if ($LASTEXITCODE -ne 0) {
        git pull --rebase --autostash --quiet
        git push --quiet
        if ($LASTEXITCODE -ne 0) { throw "push failed twice; check $Repo" }
      }
      Write-Host "committed and pushed: $(git log --oneline -1)"
    }
  }
} finally { Pop-Location }
