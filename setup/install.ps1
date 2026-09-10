<#
.SYNOPSIS
  One-time (and safe to re-run) setup of this PC for the game studio framework.

  - installs gh, ffmpeg and scrcpy in user scope through winget (no admin)
  - sets the GODOT user environment variable and puts adb and the JDK on the user PATH
  - writes ~/.claude/CLAUDE.md from setup/claude-CLAUDE.md (backing up anything else there)
  - merges permissions and the SessionStart hook from setup/settings.merge.json into
    ~/.claude/settings.json
  - junctions every skills/<name> into ~/.claude/skills/<name> (live: edits here apply
    everywhere), falling back to a copy when a junction is refused
  - copies agents/*.md into ~/.claude/agents/
  - creates C:\dev\.env from setup/env.example if missing, and C:\dev\plans

  Run:  powershell -ExecutionPolicy Bypass -File C:\dev\gamedev-notes\setup\install.ps1
  Then: gh auth login   (once)
#>
[CmdletBinding()]
param(
  [string] $Notes = 'C:\dev\gamedev-notes',
  [switch] $SkipWinget
)
$ErrorActionPreference = 'Stop'
$Utf8 = New-Object System.Text.UTF8Encoding($false)
$claude = Join-Path $env:USERPROFILE '.claude'
function Step($m) { Write-Host "==> $m" -ForegroundColor Cyan }
function Note($m) { Write-Host "    $m" }
function Warn($m) { Write-Host "    $m" -ForegroundColor Yellow }

if (-not (Test-Path (Join-Path $Notes 'INDEX.md'))) { throw "gamedev-notes not found at $Notes" }
New-Item -ItemType Directory -Force -Path $claude, (Join-Path $claude 'skills'), (Join-Path $claude 'agents') | Out-Null

# ── 1. tools ────────────────────────────────────────────────────────────────
if (-not $SkipWinget) {
  Step "Installing tools through winget (user scope, no admin)"
  foreach ($id in 'GitHub.cli', 'Gyan.FFmpeg', 'Genymobile.scrcpy') {
    $present = switch ($id) { 'GitHub.cli' { Get-Command gh -ErrorAction SilentlyContinue } 'Gyan.FFmpeg' { Get-Command ffmpeg -ErrorAction SilentlyContinue } 'Genymobile.scrcpy' { Get-Command scrcpy -ErrorAction SilentlyContinue } }
    if ($present) { Note "$id already present"; continue }
    try {
      winget install --id $id --scope user --accept-package-agreements --accept-source-agreements --silent 2>&1 | Select-Object -Last 1 | ForEach-Object { Note $_ }
    } catch { Warn "winget could not install $id ($($_.Exception.Message)). Install it by hand later." }
  }
  Warn "Open a NEW terminal after this script for the PATH changes to show."
}

# ── 2. environment ──────────────────────────────────────────────────────────
Step "Environment variables"
$godot = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_*\Godot_v4.7.2-stable_win64_console.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($godot) {
  [Environment]::SetEnvironmentVariable('GODOT', $godot.FullName, 'User'); $env:GODOT = $godot.FullName
  Note "GODOT = $($godot.FullName)"
} else { Warn "Godot 4.7.2 console binary not found under WinGet packages; set GODOT by hand." }
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
foreach ($p in 'C:\dev\toolchain\android-sdk\platform-tools', 'C:\dev\toolchain\jdk\jdk-17.0.20.1+1\bin') {
  if ((Test-Path $p) -and ($userPath -split ';' -notcontains $p)) { $userPath = "$userPath;$p"; Note "PATH += $p" }
}
[Environment]::SetEnvironmentVariable('Path', $userPath, 'User')
if (-not [Environment]::GetEnvironmentVariable('JAVA_HOME', 'User') -and (Test-Path 'C:\dev\toolchain\jdk\jdk-17.0.20.1+1')) {
  [Environment]::SetEnvironmentVariable('JAVA_HOME', 'C:\dev\toolchain\jdk\jdk-17.0.20.1+1', 'User'); Note "JAVA_HOME set"
}

# ── 3. ~/.claude/CLAUDE.md ──────────────────────────────────────────────────
Step "~/.claude/CLAUDE.md"
$src = [System.IO.File]::ReadAllText((Join-Path $Notes 'setup\claude-CLAUDE.md'))
$dst = Join-Path $claude 'CLAUDE.md'
if (Test-Path $dst) {
  $cur = [System.IO.File]::ReadAllText($dst)
  if ($cur -ne $src) {
    if ($cur -notmatch 'gamedev-notes/INDEX\.md') {
      $bak = "$dst.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
      Copy-Item $dst $bak; Warn "your previous CLAUDE.md is saved as $bak; anything personal in it should be merged by hand"
    }
    [System.IO.File]::WriteAllText($dst, $src, $Utf8); Note "written"
  } else { Note "unchanged" }
} else { [System.IO.File]::WriteAllText($dst, $src, $Utf8); Note "written" }

# ── 4. settings.json merge ──────────────────────────────────────────────────
Step "~/.claude/settings.json (permissions and the SessionStart hook)"
$merge = Get-Content (Join-Path $Notes 'setup\settings.merge.json') -Raw | ConvertFrom-Json
$sp = Join-Path $claude 'settings.json'
$settings = if (Test-Path $sp) { Get-Content $sp -Raw | ConvertFrom-Json } else { [pscustomobject]@{} }
function Ensure-Prop($obj, $name, $value) { if (-not ($obj.PSObject.Properties.Name -contains $name)) { $obj | Add-Member -NotePropertyName $name -NotePropertyValue $value } }
Ensure-Prop $settings 'permissions' ([pscustomobject]@{})
foreach ($k in 'allow', 'deny', 'additionalDirectories') {
  Ensure-Prop $settings.permissions $k @()
  $have = @($settings.permissions.$k)
  $add = @($merge.permissions.$k) | Where-Object { $have -notcontains $_ }
  $settings.permissions.$k = @($have + $add)
  if ($add.Count) { Note "$k += $($add.Count)" }
}
Ensure-Prop $settings 'hooks' ([pscustomobject]@{})
Ensure-Prop $settings.hooks 'SessionStart' @()
$existing = @($settings.hooks.SessionStart) | Where-Object { ($_ | ConvertTo-Json -Depth 6) -match 'GAMEDEV_HOOK' }
if (-not $existing) { $settings.hooks.SessionStart = @(@($settings.hooks.SessionStart) + $merge.hooks.SessionStart); Note "SessionStart hook added" }
else {
  $settings.hooks.SessionStart = @(@($settings.hooks.SessionStart) | Where-Object { ($_ | ConvertTo-Json -Depth 6) -notmatch 'GAMEDEV_HOOK' }) + $merge.hooks.SessionStart
  Note "SessionStart hook refreshed"
}
[System.IO.File]::WriteAllText($sp, ($settings | ConvertTo-Json -Depth 12), $Utf8)

# ── 5. skills (junctions) ───────────────────────────────────────────────────
Step "Skills -> ~/.claude/skills"
Get-ChildItem (Join-Path $Notes 'skills') -Directory | ForEach-Object {
  $target = Join-Path $claude "skills\$($_.Name)"
  if (Test-Path $target) {
    $item = Get-Item $target -Force
    if ($item.LinkType -eq 'Junction' -or $item.LinkType -eq 'SymbolicLink') { Note "$($_.Name): linked"; return }
    Remove-Item $target -Recurse -Force
  }
  try {
    New-Item -ItemType Junction -Path $target -Target $_.FullName | Out-Null
    Note "$($_.Name): junction"
  } catch {
    Copy-Item $_.FullName $target -Recurse
    Warn "$($_.Name): junction refused, copied instead (re-run install.ps1 after editing the skill)"
  }
}
$old = Join-Path $claude 'skills\phone-game-studio'
if (Test-Path $old) { Rename-Item $old "phone-game-studio.disabled-$(Get-Date -Format yyyyMMdd)"; Warn "the old phone-game-studio skill was renamed aside; game-studio replaces it" }

# ── 6. agents ───────────────────────────────────────────────────────────────
Step "Agents -> ~/.claude/agents"
Get-ChildItem (Join-Path $Notes 'agents') -Filter *.md | ForEach-Object {
  Copy-Item $_.FullName (Join-Path $claude "agents\$($_.Name)") -Force; Note $_.BaseName
}

# ── 7. .env and plans ───────────────────────────────────────────────────────
Step "C:\dev\.env and C:\dev\plans"
if (-not (Test-Path 'C:\dev\.env')) { Copy-Item (Join-Path $Notes 'setup\env.example') 'C:\dev\.env'; Note "created C:\dev\.env: add the API keys when you have them" } else { Note ".env exists" }
New-Item -ItemType Directory -Force -Path 'C:\dev\plans' | Out-Null
$keysB64 = 'C:\dev\keys\debug.keystore.base64.txt'
if (-not (Test-Path $keysB64) -and (Test-Path 'C:\dev\toolchain\debug.keystore')) {
  New-Item -ItemType Directory -Force -Path 'C:\dev\keys' | Out-Null
  [System.IO.File]::WriteAllText($keysB64, [Convert]::ToBase64String([System.IO.File]::ReadAllBytes('C:\dev\toolchain\debug.keystore')))
  Note "wrote $keysB64"
}

# ── 8. status ───────────────────────────────────────────────────────────────
Step "Status"
$gh = Get-Command gh -ErrorAction SilentlyContinue
if ($gh) {
  & gh auth status 2>&1 | Select-Object -First 2 | ForEach-Object { Note $_ }
  if ($LASTEXITCODE -ne 0) { Warn "gh is installed but not signed in. Run:  gh auth login   (GitHub.com, HTTPS, browser)" }
} else { Warn "gh is not on PATH yet. Open a new terminal, then run:  gh auth login" }
Write-Host ""
Write-Host "Done. Next: open a NEW terminal, run 'gh auth login' once, then start a Claude Code session in any game repo and type /new-game <idea>." -ForegroundColor Green
Write-Host "Check what loaded with /context: INDEX.md should appear under memory files, and the game-studio, new-game, game-plan, game-scaffold, asset-hunt, playtest, ship, record-lesson and digest skills under skills."
