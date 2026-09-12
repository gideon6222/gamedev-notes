<#
.SYNOPSIS
  One-time (and safe to re-run) setup of this PC for the game studio framework.

.DESCRIPTION
  What this script actually does, in order. The last four are the ones README.md does not
  mention and that a reader would otherwise only discover by reading this file:

   1. winget (user scope, no admin) installs, each skipped when already present:
      GitHub.cli, Gyan.FFmpeg, Genymobile.scrcpy, GodotEngine.GodotEngine,
      EclipseAdoptium.Temurin.17.JDK, OpenJS.NodeJS.
   2. SETS THE USER ENVIRONMENT VARIABLE `GODOT` to the Godot console binary it finds.
   3. SETS THE USER ENVIRONMENT VARIABLE `JAVA_HOME` to C:\dev\toolchain\jdk\jdk-17*, if
      that is not already set.
   4. APPENDS TO THE USER `Path`: the Android platform-tools directory (adb) and the JDK's
      bin. Only when something is actually missing, and preserving %VARIABLE% entries.
   5. writes ~/.claude/CLAUDE.md from setup/claude-CLAUDE.md, backing up whatever was there
      whenever the content differs.
   6. merges permissions and the SessionStart hook from setup/settings.merge.json into
      ~/.claude/settings.json, after backing that file up. A malformed settings.json is
      warned about and skipped, never thrown on halfway through the install.
   7. junctions every skills/<name> into ~/.claude/skills/<name> (live: edits here apply
      everywhere), falling back to a copy when a junction is refused. A junction that points
      somewhere else is re-linked; a real directory that is not ours is renamed aside, never
      deleted.
   8. copies agents/*.md into ~/.claude/agents/
   9. creates C:\dev\.env from setup/env.example if missing, and C:\dev\plans
  10. WRITES C:\dev\keys\debug.keystore.base64.txt from C:\dev\toolchain\debug.keystore, which
      is the CI signing secret new-game.ps1 uploads. Treat C:\dev\keys as secret.

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
$stamp = Get-Date -Format yyyyMMdd-HHmmss
function Step($m) { Write-Host "==> $m" -ForegroundColor Cyan }
function Note($m) { Write-Host "    $m" }
function Warn($m) { Write-Host "    $m" -ForegroundColor Yellow }

# Version globs, never a pinned point release. A pinned 'jdk-17.0.20.1+1' or
# 'Godot_v4.7.2-stable' means the day either is upgraded, every script that resolves through
# here stops finding anything and the failure reads as "Godot is not installed".
$GodotGlob = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_*\Godot_v4.*-stable_win64_console.exe"
$JdkParent = 'C:\dev\toolchain\jdk'
$JdkGlob = 'jdk-17*'

function Get-JdkHome {
  if (-not (Test-Path $JdkParent)) { return $null }
  $d = Get-ChildItem $JdkParent -Directory -Filter $JdkGlob -ErrorAction SilentlyContinue |
    Sort-Object Name -Descending | Select-Object -First 1
  if ($d) { return $d.FullName }
  return $null
}

if (-not (Test-Path (Join-Path $Notes 'INDEX.md'))) { throw "gamedev-notes not found at $Notes" }
New-Item -ItemType Directory -Force -Path $claude, (Join-Path $claude 'skills'), (Join-Path $claude 'agents') | Out-Null

# ── 1. tools ────────────────────────────────────────────────────────────────
if (-not $SkipWinget) {
  Step "Installing tools through winget (user scope, no admin)"
  foreach ($id in 'GitHub.cli', 'Gyan.FFmpeg', 'Genymobile.scrcpy', 'GodotEngine.GodotEngine', 'EclipseAdoptium.Temurin.17.JDK', 'OpenJS.NodeJS') {
    $present = switch ($id) {
      'GitHub.cli' { Get-Command gh -ErrorAction SilentlyContinue }
      'Gyan.FFmpeg' { Get-Command ffmpeg -ErrorAction SilentlyContinue }
      'Genymobile.scrcpy' { Get-Command scrcpy -ErrorAction SilentlyContinue }
      # INDEX.md tells every session that Godot, the JDK and node are all present. They were
      # never installed here, so on a genuinely fresh machine that line was false and the
      # first /new-game failed at Get-Godot.
      'GodotEngine.GodotEngine' { @(Get-ChildItem $GodotGlob -ErrorAction SilentlyContinue).Count -gt 0 }
      # The framework's own JDK lives in C:\dev\toolchain\jdk; a java already on PATH counts too.
      'EclipseAdoptium.Temurin.17.JDK' { (Get-JdkHome) -or (Get-Command java -ErrorAction SilentlyContinue) }
      'OpenJS.NodeJS' { Get-Command node -ErrorAction SilentlyContinue }
    }
    if ($present) { Note "$id already present"; continue }
    try {
      winget install --id $id --scope user --accept-package-agreements --accept-source-agreements --silent 2>&1 | Select-Object -Last 1 | ForEach-Object { Note $_ }
    } catch { Warn "winget could not install $id ($($_.Exception.Message)). Install it by hand later." }
  }
  Warn "Open a NEW terminal after this script for the PATH changes to show."
}

# ── 2. environment ──────────────────────────────────────────────────────────
Step "Environment variables"
$godot = Get-ChildItem $GodotGlob -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($godot) {
  [Environment]::SetEnvironmentVariable('GODOT', $godot.FullName, 'User'); $env:GODOT = $godot.FullName
  Note "GODOT = $($godot.FullName)"
} else { Warn "no Godot 4.x console binary under WinGet packages; set GODOT by hand." }

# The user Path is read RAW and written back as REG_EXPAND_SZ, and only when something
# changed. The old code read it through [Environment]::GetEnvironmentVariable, which expands
# %USERPROFILE% and friends, then wrote the expansion back as a plain string - freezing
# every variable entry in the user's Path to today's value, permanently, on every run.
# Get-ItemProperty expands too, so the raw read goes through GetValue with
# DoNotExpandEnvironmentNames. And an empty Path used to hand $null to
# SetEnvironmentVariable, which DELETES the variable.
$envKey = 'HKCU:\Environment'
$rawPath = (Get-Item $envKey).GetValue('Path', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
if ($null -eq $rawPath) { $rawPath = '' }
$pathChanged = $false
$wanted = @('C:\dev\toolchain\android-sdk\platform-tools')
$jdkHome = Get-JdkHome
if ($jdkHome) { $wanted += (Join-Path $jdkHome 'bin') }
foreach ($p in $wanted) {
  if ((Test-Path $p) -and (($rawPath -split ';') -notcontains $p)) {
    $rawPath = if ($rawPath.TrimEnd(';')) { "$($rawPath.TrimEnd(';'));$p" } else { $p }
    $pathChanged = $true
    Note "PATH += $p"
    if (($env:PATH -split ';') -notcontains $p) { $env:PATH = "$env:PATH;$p" }
  }
}
if ($pathChanged) {
  Set-ItemProperty -Path $envKey -Name Path -Value $rawPath -Type ExpandString
  Note "user Path updated (new terminals only)"
} else { Note "user Path already has everything it needs" }

if (-not [Environment]::GetEnvironmentVariable('JAVA_HOME', 'User')) {
  if ($jdkHome) { [Environment]::SetEnvironmentVariable('JAVA_HOME', $jdkHome, 'User'); Note "JAVA_HOME = $jdkHome" }
  else { Warn "no $JdkGlob under $JdkParent; JAVA_HOME not set (the Android export needs it)." }
}

# ── 3. ~/.claude/CLAUDE.md ──────────────────────────────────────────────────
Step "~/.claude/CLAUDE.md"
$src = [System.IO.File]::ReadAllText((Join-Path $Notes 'setup\claude-CLAUDE.md'))
$dst = Join-Path $claude 'CLAUDE.md'
if (Test-Path $dst) {
  $cur = [System.IO.File]::ReadAllText($dst)
  if ($cur -ne $src) {
    # ALWAYS back up when the content differs. The old condition only backed up a file that
    # did not already mention gamedev-notes/INDEX.md - but the installed file does mention
    # it, so from the second run onward the backup was skipped and personal lines added
    # since the first run were overwritten with no copy kept. README.md calls this script
    # "safe to re-run", and for this file it was not.
    $bak = "$dst.bak-$stamp"
    Copy-Item $dst $bak
    Warn "your previous CLAUDE.md is saved as $bak; anything personal in it should be merged by hand"
    [System.IO.File]::WriteAllText($dst, $src, $Utf8); Note "written"
  } else { Note "unchanged" }
} else { [System.IO.File]::WriteAllText($dst, $src, $Utf8); Note "written" }

# ── 4. settings.json merge ──────────────────────────────────────────────────
# The whole block is guarded. It used to throw on a malformed settings.json under
# $ErrorActionPreference = 'Stop', AFTER CLAUDE.md had been rewritten and BEFORE the skills
# and agents were wired: a half install, and no message saying so.
Step "~/.claude/settings.json (permissions and the SessionStart hook)"
$sp = Join-Path $claude 'settings.json'
try {
  $merge = Get-Content (Join-Path $Notes 'setup\settings.merge.json') -Raw | ConvertFrom-Json
  # The hook is a `powershell -File <script>` invocation, so the merge file carries {{NOTES}}
  # and this is where it becomes a real path. Substituted on the parsed object, not on the
  # JSON text, because a Windows path's backslashes are not valid JSON escapes.
  foreach ($entry in @($merge.hooks.SessionStart)) {
    foreach ($h in @($entry.hooks)) { $h.command = $h.command.Replace('{{NOTES}}', $Notes) }
  }
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
  # GAMEDEV_HOOK was the marker while the hook was an inline bash one-liner; session-start.ps1
  # is the marker now. Match both, so an install that ran before this change gets its old
  # entry replaced rather than left behind next to the new one.
  $mine = 'GAMEDEV_HOOK|session-start\.ps1'
  $existing = @($settings.hooks.SessionStart) | Where-Object { ($_ | ConvertTo-Json -Depth 6) -match $mine }
  $settings.hooks.SessionStart = @(@($settings.hooks.SessionStart) | Where-Object { ($_ | ConvertTo-Json -Depth 6) -notmatch $mine }) + $merge.hooks.SessionStart
  if ($existing) { Note "SessionStart hook refreshed" } else { Note "SessionStart hook added" }

  if (Test-Path $sp) { Copy-Item $sp "$sp.bak-$stamp"; Note "previous settings.json saved as $sp.bak-$stamp" }
  [System.IO.File]::WriteAllText($sp, ($settings | ConvertTo-Json -Depth 12), $Utf8)
  Note "written"
} catch {
  Warn "settings.json was NOT changed: $($_.Exception.Message)"
  Warn "Fix or move $sp and re-run this script. Everything below still installed."
}

# ── 5. skills (junctions) ───────────────────────────────────────────────────
# `.gamedev-installed` marks a directory this script created as a copy-fallback, so a re-run
# can refresh it. Anything else at the target is the user's and is renamed aside, never
# deleted: the skill names here (digest, ship, playtest, new-game) are generic enough that a
# user-authored skill of the same name is entirely likely, and Remove-Item -Recurse -Force
# used to destroy it without a word.
Step "Skills -> ~/.claude/skills"
$marker = '.gamedev-installed'
Get-ChildItem (Join-Path $Notes 'skills') -Directory | ForEach-Object {
  $source = $_.FullName
  $name = $_.Name
  $target = Join-Path $claude "skills\$name"
  if (Test-Path $target) {
    $item = Get-Item $target -Force
    if ($item.LinkType -eq 'Junction' -or $item.LinkType -eq 'SymbolicLink') {
      # A link that was never checked is a link that can point at an old layout forever.
      $actual = @($item.Target)[0]
      $same = $false
      if ($actual) {
        $a = (Resolve-Path -LiteralPath $actual -ErrorAction SilentlyContinue)
        $b = (Resolve-Path -LiteralPath $source -ErrorAction SilentlyContinue)
        $same = ($a -and $b -and ($a.Path.TrimEnd('\') -ieq $b.Path.TrimEnd('\')))
      }
      if ($same) { Note "${name}: linked"; return }
      Warn "${name}: link pointed at '$actual', not '$source'; re-linking"
      # Delete the reparse point only. Remove-Item -Recurse on a junction has been known to
      # follow it and delete the target's contents.
      [System.IO.Directory]::Delete($target, $false)
    } elseif (Test-Path (Join-Path $target $marker)) {
      Remove-Item $target -Recurse -Force   # our own copy from a previous run
    } else {
      $aside = "$name.bak-$stamp"
      Rename-Item -LiteralPath $target -NewName $aside
      Warn "${name}: a skill of your own was already installed there; it is saved as skills\$aside and NOT deleted"
    }
  }
  try {
    New-Item -ItemType Junction -Path $target -Target $source | Out-Null
    Note "${name}: junction"
  } catch {
    Copy-Item $source $target -Recurse
    Set-Content -LiteralPath (Join-Path $target $marker) -Value "installed by gamedev-notes/setup/install.ps1" -NoNewline
    Warn "${name}: junction refused, copied instead (re-run install.ps1 after editing the skill)"
  }
}
$old = Join-Path $claude 'skills\phone-game-studio'
if (Test-Path $old) { Rename-Item $old "phone-game-studio.disabled-$stamp"; Warn "the old phone-game-studio skill was renamed aside; game-studio replaces it" }

# ── 6. agents ───────────────────────────────────────────────────────────────
Step "Agents -> ~/.claude/agents"
Get-ChildItem (Join-Path $Notes 'agents') -Filter *.md | ForEach-Object {
  Copy-Item $_.FullName (Join-Path $claude "agents\$($_.Name)") -Force; Note $_.BaseName
}

# ── 6b. the weekly check, on Task Scheduler ─────────────────────────────────
Step "Weekly framework check (Task Scheduler, no Claude)"
try {
  & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Notes 'setup\install-schedule.ps1') 2>&1 | ForEach-Object { Note $_ }
} catch { Warn "could not register the scheduled task: $($_.Exception.Message). Run setup\install-schedule.ps1 by hand." }

# ── 7. .env and plans ───────────────────────────────────────────────────────
Step "C:\dev\.env and C:\dev\plans"
if (-not (Test-Path 'C:\dev\.env')) { Copy-Item (Join-Path $Notes 'setup\env.example') 'C:\dev\.env'; Note "created C:\dev\.env: add the API keys when you have them" } else { Note ".env exists" }
New-Item -ItemType Directory -Force -Path 'C:\dev\plans' | Out-Null
$keysB64 = 'C:\dev\keys\debug.keystore.base64.txt'
if (-not (Test-Path $keysB64) -and (Test-Path 'C:\dev\toolchain\debug.keystore')) {
  New-Item -ItemType Directory -Force -Path 'C:\dev\keys' | Out-Null
  [System.IO.File]::WriteAllText($keysB64, [Convert]::ToBase64String([System.IO.File]::ReadAllBytes('C:\dev\toolchain\debug.keystore')))
  Note "wrote $keysB64 (secret: C:\dev\keys is denied to sessions by settings.merge.json)"
}

# ── 8. status ───────────────────────────────────────────────────────────────
Step "Status"
$gh = Get-Command gh -ErrorAction SilentlyContinue
if ($gh) {
  & gh auth status 2>&1 | Select-Object -First 2 | ForEach-Object { Note $_ }
  if ($LASTEXITCODE -ne 0) { Warn "gh is installed but not signed in. Run:  gh auth login   (GitHub.com, HTTPS, browser)" }
} else { Warn "gh is not on PATH yet. Open a new terminal, then run:  gh auth login" }
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { Warn "node is not on PATH yet (web games need it). Open a new terminal." }
if (-not (Get-Command python -ErrorAction SilentlyContinue) -and -not (Get-Command py -ErrorAction SilentlyContinue)) {
  Warn "python is not on PATH. scripts\assets.py needs it: winget install --id Python.Python.3.12 --scope user"
}
Write-Host ""
Write-Host "Done. Next: open a NEW terminal, run 'gh auth login' once, then start a Claude Code session in any game repo and type /new-game <idea>." -ForegroundColor Green
Write-Host "Check what loaded with /context: INDEX.md should appear under memory files, and the game-studio, new-game, game-plan, game-scaffold, asset-hunt, playtest, ship, record-lesson and digest skills under skills."
