<#
  One-time apply for the 2026-09-12 management changes. Safe to re-run: every step checks
  whether its work is done. Run from any directory:

    powershell -ExecutionPolicy Bypass -File C:\dev\gamedev-notes\setup\apply-2026-09-12.ps1

  What it does, in order:
    1. clears any stale zero-byte .git\index.lock under C:\dev
    2. commits the framework changes in gamedev-notes by name, through kb.ps1, and pushes
    3. commits scripts\DIVERGENCE.md in each game repo and the template, and pushes
    4. runs setup\install.ps1 (agents to ~/.claude, hook refresh, registers the weekly task)
    5. runs scripts\weekly-check.ps1 once so reports\LATEST.txt exists
  Delete this file after it has run once; it is a handover, not a tool.
#>
$ErrorActionPreference = 'Continue'
$notes = 'C:\dev\gamedev-notes'
$kb = Join-Path $notes 'scripts\kb.ps1'
function Step($m) { Write-Host "==> $m" -ForegroundColor Cyan }

Step "stale git locks"
Get-ChildItem C:\dev -Directory | ForEach-Object {
  $l = Join-Path $_.FullName '.git\index.lock'
  if ((Test-Path $l) -and (Get-Item $l).Length -eq 0) { Remove-Item $l -Force; Write-Host "    cleared $l" }
}

Step "gamedev-notes: commit and push the framework changes"
$files = @(
  '.gitignore','ADMIN.md','MODELS.md','CLAUDE.md','INDEX.md','README.md',
  'agents\doctor-runner.md','agents\lesson-filer.md',
  'inbox\2026-09-12-gamedev-notes-the-digest-cannot-finish-its-own-step-seven.md',
  'scripts\doctor.ps1','scripts\kb.ps1','scripts\weekly-check.ps1',
  'setup\install.ps1','setup\install-schedule.ps1','setup\session-start.ps1','setup\apply-2026-09-12.ps1',
  'skills\digest\SKILL.md','skills\framework-check\SKILL.md','skills\game-studio\SKILL.md','skills\studio-admin\SKILL.md'
)
& powershell -NoProfile -ExecutionPolicy Bypass -File $kb commit -Files ($files -join ',') -Message "Admin: zero-token weekly check, stale-lock self-heal, kb.ps1 deletions, haiku agents, studio-admin skill, softer doctor" 2>&1 | ForEach-Object { "    $_" }

Step "game repos: scripts\DIVERGENCE.md"
foreach ($g in 'candle-gift','stillwater','wrecking-crew','gravewell','wildform','godot-template') {
  $r = "C:\dev\$g"
  if (-not (Test-Path "$r\scripts\DIVERGENCE.md")) { Write-Host "    ${g}: no DIVERGENCE.md, skipped"; continue }
  $st = (git -C $r status --porcelain -- scripts/DIVERGENCE.md 2>$null | Out-String).Trim()
  if (-not $st) { Write-Host "    ${g}: already committed"; continue }
  git -C $r add -- scripts/DIVERGENCE.md
  git -C $r commit -q -m "List the template scripts this game deliberately diverges from (doctor drift check reads it)" -m "Co-Authored-By: Claude <noreply@anthropic.com>" -- scripts/DIVERGENCE.md
  git -C $r push -q 2>&1 | Out-Null
  Write-Host "    ${g}: committed and pushed ($(git -C $r log --oneline -1))"
}

Step "install.ps1 (agents, hook, weekly task)"
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $notes 'setup\install.ps1') 2>&1 | ForEach-Object { "    $_" }

Step "first weekly check, now"
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $notes 'scripts\weekly-check.ps1') 2>&1 | ForEach-Object { "    $_" }

Write-Host ""
Write-Host "Done. Open a new Claude Code session in any game repo: the startup lines should show the weekly verdict. /agents should list doctor-runner and lesson-filer as haiku." -ForegroundColor Green
