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
$repos = 'gamedev-notes', 'godot-template', 'coreward', 'stillwater', 'wrecking-crew', 'candle-gift'

Write-Host "==> Pushing main in each repo" -ForegroundColor Cyan
foreach ($r in $repos) {
  $p = "C:\dev\$r"
  if (-not (Test-Path "$p\.git")) { continue }
  Push-Location $p
  $ahead = git rev-list --count origin/main..main 2>$null
  if ($ahead -and [int]$ahead -gt 0) {
    git push origin main 2>&1 | Select-Object -Last 1 | ForEach-Object { Write-Host "    $r : $_" }
  } else { Write-Host "    $r : nothing to push" }
  Pop-Location
}

Write-Host "==> Installing tools and wiring ~/.claude" -ForegroundColor Cyan
& powershell -ExecutionPolicy Bypass -File C:\dev\gamedev-notes\setup\install.ps1

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
