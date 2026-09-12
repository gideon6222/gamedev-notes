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

# STALE GIT LOCKS, cleared before anything tries to write.
#
# A zero-byte .git\index.lock older than ten minutes is not a running git process. It is
# what a killed session leaves, and what Cowork's Linux sandbox leaves every time it runs
# git against the mounted folder (it cannot delete the lock it made). Either way it blocks
# every git write in that repo with "another git process seems to be running", which reads
# like a concurrency bug and is not one. Ten minutes is far longer than any real git
# operation here holds the index.
$root = Split-Path $notes -Parent
$cleared = @()
Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue | ForEach-Object {
  $lock = Join-Path $_.FullName '.git\index.lock'
  if (Test-Path -LiteralPath $lock) {
    $i = Get-Item -LiteralPath $lock
    if ($i.Length -eq 0 -and $i.LastWriteTime -lt (Get-Date).AddMinutes(-10)) {
      try { Remove-Item -LiteralPath $lock -Force; $cleared += $_.Name } catch { }
    }
  }
}
if ($cleared.Count -gt 0) { Write-Output "gamedev-notes: cleared stale .git\index.lock in $($cleared -join ', ') (zero bytes, over ten minutes old)" }

git -C $notes pull --ff-only --quiet 2>$null
if ($LASTEXITCODE -eq 0) {
  $head = (git -C $notes log -1 --format='%h %s' 2>$null | Out-String).Trim()
  if ($head.Length -gt 70) { $head = $head.Substring(0, 70) }
  Write-Output "gamedev-notes: up to date ($head)"
} else {
  Write-Output "gamedev-notes: pull FAILED (offline, diverged, or a rebase is in progress). This repo is NOT current; run scripts\kb.ps1 pull before you commit."
}

# THE LESSON TITLES, not just the count.
#
# inbox/README.md says plainly that nothing in there is read by a build session:
# a lesson is invisible to every other chat until /digest folds it in. That is
# how the backlog came to hold eight groups of duplicates - two sessions each
# learning the same thing days apart, neither able to see the other's note.
#
# A count cannot fix that. A title can: "the safe area is not in window
# coordinates" is enough for a session hitting the same wall to go and read the
# file. So print the titles, newest first, capped so the block stays small.
$inbox = Join-Path $notes 'inbox'
$lessons = @(Get-ChildItem $inbox -Filter *.md -File -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -ne 'README.md' } | Sort-Object Name -Descending)
$count = $lessons.Count
Write-Output "gamedev-notes: $count lesson(s) waiting in inbox, not yet folded into the topic files"
if ($count -gt 0) {
  Write-Output "  Other sessions learned these. If one touches what you are about to do, read it before you start:"
  $show = [Math]::Min($count, 8)
  foreach ($f in $lessons[0..($show - 1)]) {
    # The title is the first `# ` heading, which record-lesson makes the rule itself.
    $title = (Select-String -Path $f.FullName -Pattern '^#\s+(.+)$' -List).Matches.Groups[1].Value
    if (-not $title) { $title = $f.BaseName }
    if ($title.Length -gt 92) { $title = $title.Substring(0, 92) + '...' }
    Write-Output "    $($f.Name.Substring(0, [Math]::Min(10, $f.Name.Length)))  $title"
  }
  if ($count -gt $show) { Write-Output "    ... and $($count - $show) more in inbox\" }
}
if ($count -gt 10) { Write-Output "More than ten lessons are waiting: run /digest before starting a new game." }

# THE LAST ROUTINE CHECK. scripts\weekly-check.ps1 runs on a Windows scheduled task and
# leaves its verdict in reports\LATEST.txt. One line here is how a FAIL reaches a session
# without anyone re-running the doctor.
$latest = Join-Path $notes 'reports\LATEST.txt'
if (Test-Path -LiteralPath $latest) {
  $first = (Get-Content -LiteralPath $latest -TotalCount 1 | Out-String).Trim()
  $age = [int]((Get-Date) - (Get-Item -LiteralPath $latest).LastWriteTime).TotalDays
  Write-Output "gamedev-notes: weekly check: $first"
  if ($first -match ' [1-9]\d* fail') { Write-Output "  The last routine check had FAILs. Read reports\LATEST.txt; run /framework-check if you are the session that should act on them." }
  if ($age -gt 9) { Write-Output "  That report is $age days old. The scheduled task may not be running: setup\install-schedule.ps1 re-registers it." }
} else {
  Write-Output "gamedev-notes: no routine check has run yet. Register it once: powershell -ExecutionPolicy Bypass -File $notes\setup\install-schedule.ps1 -RunNow"
}
exit 0
