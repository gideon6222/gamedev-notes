<#
  One command to finish the framework v2 rollout on this PC:
    1. push main in every repo under C:\dev that is ahead of GitHub
    2. run setup\install.ps1 (tools, ~/.claude, skills, agents, .env)
    3. sign in to GitHub CLI (opens the browser once)
    4. print what to do next

  Run from any PowerShell window:
    powershell -ExecutionPolicy Bypass -File C:\dev\gamedev-notes\setup\finish.ps1
#>
$ErrorActionPreference = 'Continue'

# Every git repo under C:\dev, discovered rather than listed. The hardcoded list
# this replaced was written when there were six games and silently skipped
# gravewell and wildform for two days - a list maintained by hand fails in the
# safe-looking direction, which is the same rule the test runners follow.
$root = 'C:\dev'
$repos = Get-ChildItem $root -Directory |
  Where-Object { Test-Path (Join-Path $_.FullName '.git') } |
  Sort-Object Name

Write-Host "==> Pushing main in each repo" -ForegroundColor Cyan
foreach ($d in $repos) {
  $r = $d.Name
  Push-Location $d.FullName
  # FETCH FIRST. `origin/main` is only as current as the last fetch, so counting
  # without one reports "nothing to push" on a repo that is ahead - which is a
  # silent no-op dressed as a clean result.
  git fetch origin main --quiet 2>&1 | Out-Null
  $behind = git rev-list --count main..origin/main 2>$null
  $ahead = git rev-list --count origin/main..main 2>$null
  if (-not $ahead) { Write-Host "    $r : no main, or no origin - skipped" -ForegroundColor Yellow; Pop-Location; continue }
  if ($behind -and [int]$behind -gt 0) {
    Write-Host "    $r : $behind behind origin - pull first, NOT pushed" -ForegroundColor Yellow
  } elseif ([int]$ahead -gt 0) {
    $out = git push origin main 2>&1
    if ($LASTEXITCODE -eq 0) {
      Write-Host "    $r : pushed $ahead commit(s)" -ForegroundColor Green
    } else {
      Write-Host "    $r : PUSH FAILED - $($out | Select-Object -Last 1)" -ForegroundColor Red
    }
  } else { Write-Host "    $r : nothing to push" }
  Pop-Location
}

Write-Host "==> Installing tools and wiring ~/.claude" -ForegroundColor Cyan
& powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'install.ps1')
if ($LASTEXITCODE -ne 0) { Write-Host "    install.ps1 exited $LASTEXITCODE - read its output above before trusting the rest" -ForegroundColor Red }

# gh was just installed in user scope; pick it up without a new terminal.
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'User') + ';' + [Environment]::GetEnvironmentVariable('Path', 'Machine')
$gh = Get-Command gh -ErrorAction SilentlyContinue
if (-not $gh) { $cand = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\GitHub.cli*\gh.exe", "$env:LOCALAPPDATA\Programs\GitHub CLI\gh.exe", "$env:ProgramFiles\GitHub CLI\gh.exe" -ErrorAction SilentlyContinue | Select-Object -First 1; if ($cand) { $gh = $cand.FullName } }
if ($gh) {
  $ghExe = if ($gh -is [string]) { $gh } else { $gh.Source }
  & $ghExe auth status 2>&1 | Out-Null
  if ($LASTEXITCODE -ne 0) {
    Write-Host "==> Signing in to GitHub CLI (a browser page will open; approve it with the one-time code shown here)" -ForegroundColor Cyan
    & $ghExe auth login --hostname github.com --git-protocol https --web
  } else { Write-Host "==> gh is already signed in" -ForegroundColor Cyan }
  & $ghExe auth status
} else {
  Write-Host "gh did not install; run  winget install --id GitHub.cli --scope user  then  gh auth login" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Done. Remaining, when you have them: paste FREESOUND_KEY, ITCH_KEY and POLYPIZZA_KEY into C:\dev\.env" -ForegroundColor Green
Write-Host "Then open Claude Code in any game repo, run /context to confirm INDEX.md and the skills loaded, and try:  /new-game <your idea>"
