<#
  SessionStart hook for the game studio framework. Installed into ~/.claude/settings.json by
  setup\install.ps1, which rewrites {{NOTES}} in setup\settings.merge.json to this repo's path.

  It lives in a file, and is invoked as `powershell -File <path>`, on purpose. The hook used
  to be a POSIX one-liner using /c/dev/... Git-Bash paths carried by a "shell": "bash" key
  that is not part of Claude Code's hook schema (type, command, timeout). Whether that
  command ran at all depended on which shell Claude Code happened to hand it to. A -File
  invocation has no shell metacharacters in it, so cmd.exe, PowerShell and bash all parse it
  the same way, and powershell.exe is on PATH under all three on Windows.

  Prints three things, and the first of them is the one that used to lie: a failed pull now
  says so instead of being followed by an unconditional "up to date".
#>
$ErrorActionPreference = 'Continue'
$notes = Split-Path $PSScriptRoot -Parent
if (-not (Test-Path (Join-Path $notes '.git'))) { exit 0 }

git -C $notes pull --ff-only --quiet 2>$null
if ($LASTEXITCODE -eq 0) {
  $head = (git -C $notes log -1 --format='%h %s' 2>$null | Out-String).Trim()
  if ($head.Length -gt 70) { $head = $head.Substring(0, 70) }
  Write-Output "gamedev-notes: up to date ($head)"
} else {
  Write-Output "gamedev-notes: pull FAILED (offline, diverged, or a rebase is in progress). This repo is NOT current; run scripts\kb.ps1 pull before you commit."
}

$inbox = Join-Path $notes 'inbox'
$count = @(Get-ChildItem $inbox -Filter *.md -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne 'README.md' }).Count
Write-Output "gamedev-notes: $count lesson(s) waiting in inbox"
if ($count -gt 10) { Write-Output "More than ten lessons are waiting: run /digest before starting a new game." }
exit 0
