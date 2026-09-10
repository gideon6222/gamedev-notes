<#
.SYNOPSIS
  Start a new game repo from the template, create the GitHub repo, set secrets, push.

.DESCRIPTION
  Godot:  copies C:\dev\godot-template (without .git, .godot, android, build), renames every
          placeholder to the new game, writes README/CLAUDE/NOTES/PLAN stubs, resets the
          changelog, runs the headless suites so a fresh copy proves its own gate, creates
          gideon6222/<slug> with gh, sets the three signing secrets, pushes, and reports the
          first CI run.
  Web:    copies the most recent web game's tooling (default C:\dev\coreward) without its
          game code, gives it fresh ports, creates the repo, enables GitHub Pages through the
          API, pushes.

  Idempotent where it can be: an existing C:\dev\<slug> is refused, an existing remote repo
  is reused, secrets are overwritten.

.EXAMPLE
  scripts\new-game.ps1 -Slug tide-runner -Name "Tide Runner" -Description "Surf a rising tide..."
  scripts\new-game.ps1 -Slug link-game -Name "Link Game" -Stack web
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)] [ValidatePattern('^[a-z][a-z0-9-]{1,40}$')] [string] $Slug,
  [Parameter(Mandatory)] [string] $Name,
  [string] $Description = "",
  [ValidateSet('godot', 'web')] [string] $Stack = 'godot',
  [string] $Owner = 'gideon6222',
  [string] $Root = 'C:\dev',
  [string] $Template = 'C:\dev\godot-template',
  [string] $WebSource = 'C:\dev\coreward',
  [switch] $Private,
  [switch] $NoRepo,      # scaffold locally only
  [switch] $SkipTests    # do not run the headless suites before pushing
)

$ErrorActionPreference = 'Stop'
$Dest = Join-Path $Root $Slug
$PackageId = 'com.gideon.' + ($Slug -replace '-', '')
$Utf8 = New-Object System.Text.UTF8Encoding($false)

function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Fail($msg) { Write-Host "!! $msg" -ForegroundColor Red; exit 1 }

function Replace-InFile([string] $Path, [hashtable] $Map) {
  $text = [System.IO.File]::ReadAllText($Path)
  $orig = $text
  foreach ($k in $Map.Keys) { $text = $text.Replace($k, $Map[$k]) }
  if ($text -ne $orig) { [System.IO.File]::WriteAllText($Path, $text, $Utf8) }
}

function Write-Text([string] $Path, [string] $Content) {
  $dir = Split-Path $Path -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
  [System.IO.File]::WriteAllText($Path, ($Content -replace "`r`n", "`n"), $Utf8)
}

function Get-Godot {
  if ($env:GODOT -and (Test-Path $env:GODOT)) { return $env:GODOT }
  $c = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_*\Godot_v4.7.2-stable_win64_console.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($c) { return $c.FullName }
  Fail "Godot console binary not found. Set `$env:GODOT or run setup\install.ps1."
}

if (Test-Path $Dest) { Fail "$Dest already exists. Pick another slug or remove it." }
if (-not $NoRepo) {
  if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { Fail "gh is not installed. Run setup\install.ps1, then gh auth login." }
  gh auth status 2>$null | Out-Null
  if ($LASTEXITCODE -ne 0) { Fail "gh is not signed in. Run: gh auth login" }
}

$today = Get-Date -Format 'yyyy-MM-dd'

# ── Godot ─────────────────────────────────────────────────────────────────────
if ($Stack -eq 'godot') {
  if (-not (Test-Path $Template)) { Fail "Template not found at $Template" }

  Write-Step "Copying template to $Dest"
  robocopy $Template $Dest /E /XD .git .godot android build /XF *.apk *.aab *.idsig /NFL /NDL /NJH /NJS | Out-Null
  if ($LASTEXITCODE -ge 8) { Fail "robocopy failed ($LASTEXITCODE)" }

  Write-Step "Renaming placeholders"
  $map = @{
    'godot-template'          = $Slug
    'com.gideon.godottemplate' = $PackageId
    'godottemplate'           = ($Slug -replace '-', '')
    'Godot Template'          = $Name
  }
  $textExt = '.gd', '.tscn', '.tres', '.cfg', '.godot', '.md', '.bat', '.ps1', '.yml', '.yaml', '.json', '.txt', '.gdshader', '.import', '.gitattributes', '.gitignore'
  Get-ChildItem $Dest -Recurse -File | Where-Object { $textExt -contains $_.Extension -or $_.Name -in '.gitattributes', '.gitignore' } | ForEach-Object {
    Replace-InFile $_.FullName $map
  }
  $leftover = Get-ChildItem $Dest -Recurse -File | Where-Object { $textExt -contains $_.Extension } | Select-String -Pattern 'godot-template|godottemplate|Godot Template' -List
  if ($leftover) { $leftover | ForEach-Object { Write-Host "   leftover: $($_.Path)" }; Fail "placeholders survived the rename" }

  if ($Description) {
    Replace-InFile (Join-Path $Dest 'project.godot') @{ 'config/description="Proving stack for phone games built with Godot: headless tests, a whole-run golden, a size guard, CI, and an APK that installs."' = "config/description=`"$($Description -replace '"', '')`"" }
  }

  Write-Step "Resetting the changelog to 0.1.0"
  $changelog = @"
class_name Changelog
extends RefCounted

## What changed, in the player's terms. Newest first, one line each, describe
## what the player can now do or see. The build stamp says whether an update
## landed; this says what it was.

const VERSION := "0.1.0"

const RELEASES := [
	{
		"version": "0.1.0",
		"date": "$today",
		"title": "First playable",
		"notes": [
			"The first build of $Name.",
		],
	},
]
"@
  Write-Text (Join-Path $Dest 'src\changelog.gd') $changelog

  Write-Step "Writing README, CLAUDE.md, NOTES.md, PLAN.md"
  $stubDir = Join-Path $PSScriptRoot '..\setup\game-stubs'
  foreach ($f in 'README.md', 'CLAUDE.md', 'NOTES.md', 'PLAN.md') {
    $src = Join-Path $stubDir "godot-$f"
    if (-not (Test-Path $src)) { Fail "missing stub $src" }
    $text = [System.IO.File]::ReadAllText($src)
    $text = $text.Replace('{{SLUG}}', $Slug).Replace('{{NAME}}', $Name).Replace('{{PACKAGE}}', $PackageId).Replace('{{DATE}}', $today).Replace('{{DESCRIPTION}}', $Description)
    $target = Join-Path $Dest $f
    if ($f -eq 'PLAN.md' -and (Test-Path $target)) { continue }
    Write-Text $target $text
  }
  # A plan written by /game-plan before scaffolding lives at C:\dev\plans\<slug>\PLAN.md.
  $prePlan = Join-Path $Root "plans\$Slug\PLAN.md"
  if (Test-Path $prePlan) {
    Write-Step "Taking the plan from $prePlan"
    Copy-Item $prePlan (Join-Path $Dest 'PLAN.md') -Force
    $preRef = Join-Path $Root "plans\$Slug\REFERENCE.md"
    if (Test-Path $preRef) { Copy-Item $preRef (Join-Path $Dest 'REFERENCE.md') -Force }
  }
  Write-Text (Join-Path $Dest 'assets\CREDITS.md') "# Credits`n`nEvery asset that was not made here. Appended by scripts/assets.py.`n`n| Date | Source | Asset | Licence | URL |`n|---|---|---|---|---|`n"

  Write-Step "git init"
  Push-Location $Dest
  git init -b main | Out-Null
  git add -A   # the ONE place a blanket add is right: a fresh copy with nothing else in it
  git commit -q -m "Scaffold $Name from godot-template" -m "Copied from C:\dev\godot-template, renamed to $Slug / $PackageId, changelog reset to 0.1.0.`n`nCo-Authored-By: Claude <noreply@anthropic.com>"

  if (-not $SkipTests) {
    Write-Step "Proving the fresh copy passes its own gate"
    $godot = Get-Godot
    & $godot --headless --path . --import *> build-import.log
    & $godot --headless --path . --script res://test/run_tests.gd *> build-tests.log
    if ($LASTEXITCODE -ne 0) { Get-Content build-tests.log | Select-Object -First 40; Pop-Location; Fail "run_tests.gd failed on the fresh copy. The template drifted; fix it there first." }
    & $godot --headless --path . --script res://test/run_smoke.gd *> build-smoke.log
    if ($LASTEXITCODE -ne 0) { Get-Content build-smoke.log | Select-Object -First 40; Pop-Location; Fail "run_smoke.gd failed on the fresh copy." }
    Remove-Item build-*.log -ErrorAction SilentlyContinue
    Write-Host "   tests and smoke green"
  }

  if (-not $NoRepo) {
    Write-Step "Creating github.com/$Owner/$Slug"
    $vis = if ($Private) { '--private' } else { '--public' }
    gh repo view "$Owner/$Slug" 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
      Write-Host "   repo exists, adding remote"
      git remote add origin "https://github.com/$Owner/$Slug.git"
      git push -u origin main
    } else {
      $desc = if ($Description) { $Description } else { "$Name, a phone game built in Godot" }
      gh repo create "$Owner/$Slug" $vis --source . --remote origin --push --description $desc
      if ($LASTEXITCODE -ne 0) { Pop-Location; Fail "gh repo create failed" }
    }

    Write-Step "Setting signing secrets"
    $debugB64 = Join-Path $Root 'keys\debug.keystore.base64.txt'
    if (-not (Test-Path $debugB64)) {
      $bytes = [System.IO.File]::ReadAllBytes((Join-Path $Root 'toolchain\debug.keystore'))
      [System.IO.File]::WriteAllText($debugB64, [Convert]::ToBase64String($bytes))
    }
    Get-Content $debugB64 -Raw | gh secret set ANDROID_DEBUG_KEYSTORE_B64 -R "$Owner/$Slug"
    $uploadB64 = Join-Path $Root 'keys\upload.keystore.base64.txt'
    if (Test-Path $uploadB64) {
      Get-Content $uploadB64 -Raw | gh secret set ANDROID_UPLOAD_KEYSTORE_B64 -R "$Owner/$Slug"
      $readme = Get-Content (Join-Path $Root 'keys\UPLOAD-KEY-README.txt') -Raw
      $m = [regex]::Match($readme, '(?im)^\s*password\s*[:=]\s*(\S+)')
      if ($m.Success) { $m.Groups[1].Value | gh secret set ANDROID_UPLOAD_KEYSTORE_PASSWORD -R "$Owner/$Slug" }
      else { Write-Host "   could not read the upload password from UPLOAD-KEY-README.txt; set ANDROID_UPLOAD_KEYSTORE_PASSWORD by hand before a v* tag" -ForegroundColor Yellow }
    } else {
      Write-Host "   no upload keystore base64 found; only the debug secret was set" -ForegroundColor Yellow
    }

    Write-Step "First CI run"
    Start-Sleep -Seconds 8
    gh run list -R "$Owner/$Slug" --limit 1
    Write-Host "   watch it with: gh run watch -R $Owner/$Slug"
  }
  Pop-Location

  Write-Host ""
  Write-Host "Done. $Name is at $Dest" -ForegroundColor Green
  if (-not $NoRepo) { Write-Host "Repo: https://github.com/$Owner/$Slug   Releases will carry the APK." }
  exit 0
}

# ── Web ───────────────────────────────────────────────────────────────────────
if (-not (Test-Path $WebSource)) { Fail "Web source game not found at $WebSource" }

Write-Step "Copying web tooling from $WebSource to $Dest"
robocopy $WebSource $Dest /E /XD .git node_modules dist test-results .claude /XF *.log /NFL /NDL /NJH /NJS | Out-Null
if ($LASTEXITCODE -ge 8) { Fail "robocopy failed ($LASTEXITCODE)" }

# Fresh ports: never a Vite default, never one another game uses.
$used = Get-ChildItem $Root -Directory | ForEach-Object {
  $pc = Join-Path $_.FullName 'playwright.config.ts'
  if (Test-Path $pc) { [regex]::Matches((Get-Content $pc -Raw), '\b4[0-9]{3}\b') | ForEach-Object { [int]$_.Value } }
} | Sort-Object -Unique
$testPort = 4400; while ($used -contains $testPort -or $used -contains ($testPort - 1)) { $testPort += 2 }
$prevPort = $testPort - 1

Write-Step "Renaming and re-porting"
$srcSlug = Split-Path $WebSource -Leaf
$textExt = '.ts', '.js', '.mjs', '.json', '.html', '.md', '.yml', '.yaml', '.css', '.webmanifest', '.gitattributes'
Get-ChildItem $Dest -Recurse -File | Where-Object { $textExt -contains $_.Extension } | ForEach-Object {
  Replace-InFile $_.FullName @{ $srcSlug = $Slug; ((Get-Culture).TextInfo.ToTitleCase($srcSlug)) = $Name }
}
$pc = Join-Path $Dest 'playwright.config.ts'
if (Test-Path $pc) {
  $t = [System.IO.File]::ReadAllText($pc)
  $t = [regex]::Replace($t, '\b4[0-9]{3}\b', { param($m) if ([int]$m.Value % 2 -eq 1) { "$testPort" } else { "$prevPort" } })
  [System.IO.File]::WriteAllText($pc, $t, $Utf8)
}
# The game itself starts empty: keep the tooling, replace src with a stub the smoke test can boot.
$stubDir = Join-Path $PSScriptRoot '..\setup\game-stubs'
foreach ($f in 'README.md', 'CLAUDE.md', 'NOTES.md', 'PLAN.md') {
  $src = Join-Path $stubDir "web-$f"
  if (Test-Path $src) {
    $text = [System.IO.File]::ReadAllText($src).Replace('{{SLUG}}', $Slug).Replace('{{NAME}}', $Name).Replace('{{DATE}}', $today).Replace('{{DESCRIPTION}}', $Description).Replace('{{TESTPORT}}', "$testPort").Replace('{{PREVIEWPORT}}', "$prevPort")
    Write-Text (Join-Path $Dest $f) $text
  }
}
Write-Host "   ports: tests $testPort, preview $prevPort. The game code under src/ is the source game's; replace it per PLAN.md before the first push of gameplay." -ForegroundColor Yellow

Push-Location $Dest
git init -b main | Out-Null
git add -A
git commit -q -m "Scaffold $Name from $srcSlug tooling" -m "Co-Authored-By: Claude <noreply@anthropic.com>"
npm install 2>&1 | Select-Object -Last 2

if (-not $NoRepo) {
  Write-Step "Creating github.com/$Owner/$Slug and enabling Pages"
  $vis = if ($Private) { '--private' } else { '--public' }
  gh repo create "$Owner/$Slug" $vis --source . --remote origin --push --description "$Name, a phone game on GitHub Pages"
  if ($LASTEXITCODE -ne 0) { Pop-Location; Fail "gh repo create failed" }
  gh api -X POST "repos/$Owner/$Slug/pages" -f build_type=workflow 2>$null
  if ($LASTEXITCODE -ne 0) { gh api -X PUT "repos/$Owner/$Slug/pages" -f build_type=workflow }
  gh api "repos/$Owner/$Slug/pages" --jq '.build_type + " " + .html_url'
}
Pop-Location
Write-Host "Done. $Name is at $Dest" -ForegroundColor Green
