<#
.SYNOPSIS
  The routine framework check. Runs doctor.ps1 in full, writes a dated report, and keeps a
  one-line verdict where every session sees it. Costs no Claude tokens: it is plain
  PowerShell on a Windows scheduled task (setup\install-schedule.ps1 registers it).

.DESCRIPTION
  Steps, in order:
    1. Clear stale git locks. A zero-byte .git\index.lock older than ten minutes in any repo
       under C:\dev is a crashed or foreign git process, not a live one, and it blocks every
       git write with "another git process seems to be running". Cowork's Linux sandbox
       leaves these behind whenever it runs git against the mounted folder and cannot
       delete them itself.
    2. Run scripts\doctor.ps1 with no -Quiet and no -Repo, so every check runs.
    3. Write reports\doctor-<date>.txt (the full output) and reports\LATEST.txt (the summary
       line, then every WARN and FAIL line). reports\ is gitignored: it is this machine's
       state, and committing it would put every session in conflict over it.
    4. Keep the eight newest dated reports and delete the rest.

  A FAIL does not page anyone. The next Claude Code session prints the LATEST verdict in
  its SessionStart output, and /framework-check reads reports\LATEST.txt before running the
  doctor again. Escalation to Claude is deliberate and manual: "run /framework-check".

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File C:\dev\gamedev-notes\scripts\weekly-check.ps1
#>
[CmdletBinding()]
param(
  [string] $Root = 'C:\dev',
  [int] $Keep = 8
)
$ErrorActionPreference = 'Continue'
$notes = Split-Path $PSScriptRoot -Parent
if (-not $notes) { $notes = Split-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) -Parent }
$reports = Join-Path $notes 'reports'
New-Item -ItemType Directory -Force -Path $reports | Out-Null
$stamp = Get-Date -Format 'yyyy-MM-dd-HHmm'
$full = Join-Path $reports "doctor-$stamp.txt"
$latest = Join-Path $reports 'LATEST.txt'

# 1. stale locks
$cleared = @()
Get-ChildItem -LiteralPath $Root -Directory -ErrorAction SilentlyContinue | ForEach-Object {
  $lock = Join-Path $_.FullName '.git\index.lock'
  if (Test-Path -LiteralPath $lock) {
    $i = Get-Item -LiteralPath $lock
    if ($i.Length -eq 0 -and $i.LastWriteTime -lt (Get-Date).AddMinutes(-10)) {
      try { Remove-Item -LiteralPath $lock -Force; $cleared += $_.Name } catch { }
    }
  }
}

# 2. the doctor. Write-Host lands on the information stream; *> catches every stream.
$doctor = Join-Path $notes 'scripts\doctor.ps1'
$out = & powershell -NoProfile -ExecutionPolicy Bypass -File $doctor -Root $Root -Notes $notes *>&1 | ForEach-Object { "$_" }
$code = $LASTEXITCODE

# 3. reports
$header = @(
  "gamedev-notes weekly check  $(Get-Date -Format 'yyyy-MM-dd HH:mm')  exit $code"
  "$(if ($cleared.Count -gt 0) { "cleared stale index.lock in: $($cleared -join ', ')" } else { 'no stale git locks' })"
  ''
)
($header + $out) | Set-Content -LiteralPath $full -Encoding UTF8
$summary = @($out | Where-Object { $_ -match '^\s+\d+ pass, \d+ warn, \d+ fail' }) | Select-Object -Last 1
if (-not $summary) { $summary = "  doctor produced no summary line (exit $code); read $full" }
# WARN and FAIL lines, each under the `== Area ==` heading it appeared under, so the
# verdict says which repo without opening the full report.
$flagged = @()
$area = $null; $areaShown = $false
foreach ($line in $out) {
  if ($line -match '^== (.+) ==$') { $area = $line; $areaShown = $false; continue }
  if ($line -match '^\s+(WARN|FAIL)\s') {
    if ($area -and -not $areaShown) { $flagged += $area; $areaShown = $true }
    $flagged += $line
  }
}
$verdict = @(
  "checked $(Get-Date -Format 'yyyy-MM-dd HH:mm')  $($summary.Trim())"
  "full report: $full"
)
if ($cleared.Count -gt 0) { $verdict += "cleared stale index.lock in: $($cleared -join ', ')" }
if ($flagged.Count -gt 0) { $verdict += ''; $verdict += $flagged }
$verdict | Set-Content -LiteralPath $latest -Encoding UTF8

# 4. prune
Get-ChildItem -LiteralPath $reports -Filter 'doctor-*.txt' | Sort-Object Name -Descending | Select-Object -Skip $Keep | Remove-Item -Force -ErrorAction SilentlyContinue

# One line for the dashboard's robots log.
try { Add-Content -LiteralPath (Join-Path $reports 'robots.log') -Value ("{0}|doctor|{1}|weekly check: {2}" -f [datetimeoffset]::Now.ToString('o'), $(if ($code -eq 0) { 'ok' } else { 'fail' }), $summary.Trim()) -Encoding UTF8 } catch { }

Write-Host ($verdict -join "`n")
exit $code
