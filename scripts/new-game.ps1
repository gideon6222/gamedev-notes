<#
.SYNOPSIS
  Start a new game repo from the template, create the GitHub repo, set secrets, push.

.DESCRIPTION
  Godot:  copies C:\dev\godot-template (without .git, .godot, android, build), renames every
          placeholder to the new game, writes README/CLAUDE/NOTES/PLAN stubs, picks up a plan
          written earlier by /game-plan, resets the changelog, recreates build/.gdignore,
          runs the headless suites so a fresh copy proves its own gate, creates
          gideon6222/<slug> with gh, sets the three signing secrets, pushes, and reports the
          first CI run.
  Web:    copies the most recent web game's TOOLING (default C:\dev\coreward) and then
          deletes that game's src/, e2e/ and test/ and puts setup\web-stub over the hole, so
          the new repo contains a bootable stub and not another game. Gives it fresh ports by
          role, picks up the plan, installs, builds, records its own bundle budget from that
          build, runs the gate, creates the repo, enables GitHub Pages, pushes.

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

# A tool winget installed is invisible to a shell that started before the install, because a
# process reads the user PATH once at startup and a Claude session's shell can be hours older.
# Re-read the user PATH from the registry and prepend anything this process is missing, so gh,
# adb and ffmpeg resolve without anyone reinstalling anything.
$userPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
if ($userPath) {
  $have = $env:PATH -split ';'
  $missing = @($userPath -split ';' | Where-Object { $_ -and $have -notcontains $_ })
  if ($missing.Count) { $env:PATH = ($missing -join ';') + ';' + $env:PATH }
}

# Native commands write progress, warnings and expected failures to stderr, and
# $ErrorActionPreference = 'Stop' turns any of that into a terminating NativeCommandError
# BEFORE the exit-code check below it ever runs. Every native call whose failure is expected
# goes through this, so the exit code stays the only thing that decides.
function Native([scriptblock]$Block) {
  $prev = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try { & $Block } finally { $ErrorActionPreference = $prev }
}

# IDictionary, not Hashtable: the web branch needs the replacements applied in a fixed order,
# and a [hashtable] literal has no order at all.
function Replace-InFile([string] $Path, [System.Collections.IDictionary] $Map) {
  if (-not (Test-Path $Path)) { return }
  $text = [System.IO.File]::ReadAllText($Path)
  $orig = $text
  foreach ($k in @($Map.Keys)) { $text = $text.Replace([string]$k, [string]($Map[$k])) }
  if ($text -ne $orig) { [System.IO.File]::WriteAllText($Path, $text, $Utf8) }
}

function Write-Text([string] $Path, [string] $Content) {
  $dir = Split-Path $Path -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  [System.IO.File]::WriteAllText($Path, ($Content -replace "`r`n", "`n"), $Utf8)
}

# Base64 for a CI secret: pure ASCII, one line, and NO trailing newline. A CR anywhere in the
# value makes `base64 -d` on the runner fail with "invalid input", which reads like a missing
# or corrupt keystore rather than like a line ending.
function Write-B64([string] $BinPath, [string] $OutPath) {
  if (-not (Test-Path $BinPath)) { Fail "no keystore at $BinPath" }
  $bytes = [System.IO.File]::ReadAllBytes($BinPath)
  [System.IO.File]::WriteAllBytes($OutPath, [System.Text.Encoding]::ASCII.GetBytes([Convert]::ToBase64String($bytes)))
}

# `Get-Content -Raw | gh secret set` re-encodes through the console encoding and carries any
# line ending with it. cmd's stdin redirect hands gh the file's bytes unchanged.
function Set-SecretFromFile([string] $Name, [string] $Path, [string] $Repo) {
  Native { cmd /c "gh secret set $Name -R $Repo < `"$Path`"" }
  if ($LASTEXITCODE -ne 0) { Fail "gh secret set $Name failed" }
}

function Get-Godot {
  if ($env:GODOT -and (Test-Path $env:GODOT)) { return $env:GODOT }
  # A glob, never a pinned point release: a Godot upgrade used to make this report "Godot is
  # not installed" on a machine where it plainly was.
  $c = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_*\Godot_v4.*-stable_win64_console.exe" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if ($c) { return $c.FullName }
  Fail "Godot console binary not found. Set `$env:GODOT or run setup\install.ps1."
}

# A plan written by /game-plan BEFORE scaffolding lives at C:\dev\plans\<slug>\PLAN.md. This
# used to sit inside the Godot branch, which exits before the web branch starts, so a web game
# scaffolded straight after /game-plan silently got the stub whose text is "No plan was
# written before scaffolding." Both stacks call it now.
function Copy-PrePlan([string] $Into) {
  $planDir = Join-Path $Root "plans\$Slug"
  $prePlan = Join-Path $planDir 'PLAN.md'
  if (Test-Path $prePlan) {
    Write-Step "Taking the plan from $prePlan"
    Copy-Item $prePlan (Join-Path $Into 'PLAN.md') -Force
    $preRef = Join-Path $planDir 'REFERENCE.md'
    if (Test-Path $preRef) { Copy-Item $preRef (Join-Path $Into 'REFERENCE.md') -Force; Write-Host "   and REFERENCE.md" }
  } else {
    Write-Host "   no plan at $prePlan; PLAN.md is the stub. Run /game-plan $Slug next." -ForegroundColor Yellow
  }
}

# Run AFTER the stubs are written, not before. The old check ran before them and so could
# only ever see the template's own names; the {{SLUG}}, {{NAME}}, {{PACKAGE}}, {{DATE}} and
# {{DESCRIPTION}} tokens the stubs introduce were never looked at by anything, and the web
# branch had no check at all.
function Assert-NoPlaceholders([string] $Into, [string[]] $Ext, [string] $Pattern) {
  $leftover = Get-ChildItem $Into -Recurse -File -Force |
    Where-Object { $Ext -contains $_.Extension } |
    Select-String -Pattern $Pattern -List
  if ($leftover) {
    $leftover | ForEach-Object { Write-Host "   leftover: $($_.Path):$($_.LineNumber): $($_.Line.Trim())" }
    Fail "placeholders survived the rename. The new repo would ship another game's name, or a literal {{TOKEN}}."
  }
}

if (Test-Path $Dest) { Fail "$Dest already exists. Pick another slug or remove it." }
if (-not $NoRepo) {
  if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { Fail "gh not found on PATH even after re-reading the user PATH from the registry. Install it with: winget install GitHub.cli" }
  Native { gh auth status 2>&1 | Out-Null }
  if ($LASTEXITCODE -ne 0) { Fail "gh is not signed in. Run: gh auth login" }
}

$today = Get-Date -Format 'yyyy-MM-dd'

# ── Godot ─────────────────────────────────────────────────────────────────────
if ($Stack -eq 'godot') {
  if (-not (Test-Path $Template)) { Fail "Template not found at $Template" }

  Write-Step "Copying template to $Dest"
  robocopy $Template $Dest /E /XD .git .godot android build /XF *.apk *.aab *.idsig /NFL /NDL /NJH /NJS | Out-Null
  if ($LASTEXITCODE -ge 8) { Fail "robocopy failed ($LASTEXITCODE)" }

  # build/ is excluded above because it holds the last export and thousands of
  # filmed frames - but its .gdignore marker is NOT optional, and excluding the
  # directory took it with it. Without the marker Godot imports and then EXPORTS
  # whatever films leave in there: that is the bug that packed 3,720 PNGs into
  # an APK and produced 1.42 GB against a 28 MB budget. Recreate it here, and
  # verify it below, rather than trusting a directory exclusion to have an
  # exception.
  New-Item -ItemType Directory -Force -Path (Join-Path $Dest 'build') | Out-Null
  Set-Content -Path (Join-Path $Dest 'build/.gdignore') -Value '' -NoNewline
  if (-not (Test-Path (Join-Path $Dest 'build/.gdignore'))) {
    Fail "build/.gdignore was not created - films and exports would be packed into the APK"
  }

  Write-Step "Renaming placeholders"
  # Ordered and ORDINAL: longest key first, and case-sensitive key comparison so no entry can
  # be dropped as a duplicate of one that differs only in case. (See the web branch's map.)
  $map = New-Object 'System.Collections.Specialized.OrderedDictionary' ([System.StringComparer]::Ordinal)
  $map['com.gideon.godottemplate'] = $PackageId
  $map['godot-template'] = $Slug
  $map['godottemplate'] = ($Slug -replace '-', '')
  $map['Godot Template'] = $Name
  $textExt = '.gd', '.tscn', '.tres', '.cfg', '.godot', '.md', '.bat', '.ps1', '.yml', '.yaml', '.json', '.txt', '.gdshader', '.import', '.gitattributes', '.gitignore'
  Get-ChildItem $Dest -Recurse -File -Force | Where-Object { $textExt -contains $_.Extension -or $_.Name -in '.gitattributes', '.gitignore' } | ForEach-Object {
    Replace-InFile $_.FullName $map
  }

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
  Copy-PrePlan $Dest
  Write-Text (Join-Path $Dest 'assets\CREDITS.md') "# Credits`n`nEvery asset that was not made here. Appended by scripts/assets.py.`n`n| Date | Source | Asset | Licence | URL |`n|---|---|---|---|---|`n"

  Assert-NoPlaceholders $Dest $textExt 'godot-template|godottemplate|Godot Template|\{\{[A-Z]+\}\}'

  Write-Step "git init"
  Push-Location $Dest
  Native { git init -b main | Out-Null }
  Native { git add -A }   # the ONE place a blanket add is right: a fresh copy with nothing else in it
  # .gitignore ignores build/* and re-includes !build/.gdignore, but the marker is the single
  # file in this repo whose absence costs 1.4 GB, so it is staged explicitly and then verified
  # rather than left to depend on two lines of .gitignore staying in the right order.
  Native { git add -f -- 'build/.gdignore' }
  Native { git commit -q -m "Scaffold $Name from godot-template" -m "Copied from C:\dev\godot-template, renamed to $Slug / $PackageId, changelog reset to 0.1.0.`n`nCo-Authored-By: Claude <noreply@anthropic.com>" }
  if ($LASTEXITCODE -ne 0) { Pop-Location; Fail "the first commit failed" }
  Native { git ls-files --error-unmatch build/.gdignore 2>&1 | Out-Null }
  if ($LASTEXITCODE -ne 0) { Pop-Location; Fail "build/.gdignore is not tracked in the first commit. Every game scaffolded before this check lacked it, and that is how a 1.42 GB APK happens." }

  if (-not $SkipTests) {
    Write-Step "Proving the fresh copy passes its own gate"
    $godot = Get-Godot
    Native { & $godot --headless --path . --import *> build-import.log }
    # The import's exit code used to be discarded: the next line's $LASTEXITCODE check
    # belonged to the test run, so a failed --import went to CI unseen.
    if ($LASTEXITCODE -ne 0) {
      Get-Content build-import.log -ErrorAction SilentlyContinue | Select-Object -First 40
      Remove-Item build-*.log -ErrorAction SilentlyContinue; Pop-Location
      Fail "godot --import failed on the fresh copy. Fix the template before scaffolding from it."
    }
    Native { & $godot --headless --path . --script res://test/run_tests.gd *> build-tests.log }
    if ($LASTEXITCODE -ne 0) {
      Get-Content build-tests.log -ErrorAction SilentlyContinue | Select-Object -First 40
      # These logs are cleaned up on the failure paths too: they used to be left sitting in
      # a repo that the next run would push.
      Remove-Item build-*.log -ErrorAction SilentlyContinue; Pop-Location
      Fail "run_tests.gd failed on the fresh copy. The template drifted; fix it there first."
    }
    Native { & $godot --headless --path . --script res://test/run_smoke.gd *> build-smoke.log }
    if ($LASTEXITCODE -ne 0) {
      Get-Content build-smoke.log -ErrorAction SilentlyContinue | Select-Object -First 40
      Remove-Item build-*.log -ErrorAction SilentlyContinue; Pop-Location
      Fail "run_smoke.gd failed on the fresh copy."
    }
    Remove-Item build-*.log -ErrorAction SilentlyContinue
    Write-Host "   tests and smoke green"
  }

  if (-not $NoRepo) {
    Write-Step "Creating github.com/$Owner/$Slug"
    $vis = if ($Private) { '--private' } else { '--public' }
    Native { gh repo view "$Owner/$Slug" 2>&1 | Out-Null }
    if ($LASTEXITCODE -eq 0) {
      Write-Host "   repo exists, adding remote"
      Native { git remote add origin "https://github.com/$Owner/$Slug.git" }
      Native { git push -u origin main }
      if ($LASTEXITCODE -ne 0) { Pop-Location; Fail "git push failed" }
    } else {
      $desc = if ($Description) { $Description } else { "$Name, a phone game built in Godot" }
      Native { gh repo create "$Owner/$Slug" $vis --source . --remote origin --push --description $desc }
      if ($LASTEXITCODE -ne 0) { Pop-Location; Fail "gh repo create failed" }
    }

    Write-Step "Setting signing secrets"
    # GNU base64 in CI rejects a carriage return, so a base64 file written with CRLF, or piped
    # through PowerShell, produces a secret that decodes to "base64: invalid input" and fails
    # the very first CI run of a new repo. Write pure ASCII with no newline at all, and hand
    # the file to gh through a cmd redirect rather than a PowerShell pipe, which re-encodes.
    $debugB64 = Join-Path $Root 'keys\debug.keystore.base64.txt'
    Write-B64 (Join-Path $Root 'toolchain\debug.keystore') $debugB64
    Set-SecretFromFile 'ANDROID_DEBUG_KEYSTORE_B64' $debugB64 "$Owner/$Slug"
    $uploadB64 = Join-Path $Root 'keys\upload.keystore.base64.txt'
    if (Test-Path $uploadB64) {
      Set-SecretFromFile 'ANDROID_UPLOAD_KEYSTORE_B64' $uploadB64 "$Owner/$Slug"
      $readme = Get-Content (Join-Path $Root 'keys\UPLOAD-KEY-README.txt') -Raw
      $m = [regex]::Match($readme, '(?im)^\s*password\s*[:=]\s*(\S+)')
      # --body, not a pipe: a PowerShell pipe appends a newline, and a trailing newline in a
      # keystore password fails the release signing with an unhelpful message.
      if ($m.Success) { Native { gh secret set ANDROID_UPLOAD_KEYSTORE_PASSWORD -R "$Owner/$Slug" --body $m.Groups[1].Value } }
      else { Write-Host "   could not read the upload password from UPLOAD-KEY-README.txt; set ANDROID_UPLOAD_KEYSTORE_PASSWORD by hand before a v* tag" -ForegroundColor Yellow }
    } else {
      Write-Host "   no upload keystore base64 found; only the debug secret was set" -ForegroundColor Yellow
    }

    Write-Step "First CI run"
    Start-Sleep -Seconds 8
    Native { gh run list -R "$Owner/$Slug" --limit 1 }
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
$WebStub = Join-Path $PSScriptRoot '..\setup\web-stub'
if (-not (Test-Path (Join-Path $WebStub 'src\main.ts'))) { Fail "missing the web stub at $WebStub. Without it this would commit $((Split-Path $WebSource -Leaf))'s entire game as a new one." }

Write-Step "Copying web tooling from $WebSource to $Dest"
# .claude is NOT excluded any more. Excluding it was how launch.json's port survived every
# rescaffold: the port rewrite could not see a file that had not been copied, so every new
# game previewed on the source game's port.
robocopy $WebSource $Dest /E /XD .git node_modules dist test-results playwright-report blob-report /XF *.log /NFL /NDL /NJH /NJS | Out-Null
if ($LASTEXITCODE -ge 8) { Fail "robocopy failed ($LASTEXITCODE)" }

# ── ports ────────────────────────────────────────────────────────────────────
# Three files hold a port and they hold DIFFERENT ports with different jobs. The old code
# read only playwright.config.ts, then rewrote every 4xxx literal in it according to whether
# the ORIGINAL number was odd or even - a rule with no relationship to which port is which,
# which happened to work on one game. Ports are read and written by ROLE, at the one place
# each role lives, and a role that cannot be found is a hard failure rather than a silent
# inheritance of another game's port.
$PwConfig = Join-Path $Dest 'playwright.config.ts'
$LaunchJson = Join-Path $Dest '.claude\launch.json'
$Filmstrip = Join-Path $Dest 'scripts\filmstrip.mjs'

function Get-NamedPort([string] $Path, [string] $Pattern, [string] $Role) {
  if (-not (Test-Path $Path)) { return 0 }
  $m = [regex]::Match([System.IO.File]::ReadAllText($Path), $Pattern)
  if (-not $m.Success) {
    Fail "could not find the $Role port in $Path. Ports are substituted by role at a known occurrence; the source game's layout has changed, so fix the pattern in new-game.ps1 rather than letting the new game inherit another game's port."
  }
  [int]$m.Groups[1].Value
}

$srcTestPort = Get-NamedPort $PwConfig "baseURL:\s*'http://127\.0\.0\.1:(\d{4,5})'" 'test'
$srcPreviewPort = Get-NamedPort $LaunchJson '"name"\s*:\s*"[^"]*-preview"[\s\S]*?"port"\s*:\s*(\d{4,5})' 'preview'
$srcDevPort = Get-NamedPort $LaunchJson '"name"\s*:\s*"[^"]*-dev"[\s\S]*?"port"\s*:\s*(\d{4,5})' 'dev'
$srcFilmPort = Get-NamedPort $Filmstrip 'const PORT\s*=\s*(\d{4,5})' 'film'

# Every port any sibling game already uses, from all three files, not just one of them.
$used = New-Object 'System.Collections.Generic.HashSet[int]'
foreach ($repo in (Get-ChildItem $Root -Directory -ErrorAction SilentlyContinue)) {
  foreach ($rel in 'playwright.config.ts', '.claude\launch.json', 'scripts\filmstrip.mjs') {
    $f = Join-Path $repo.FullName $rel
    if (Test-Path $f) {
      foreach ($m in [regex]::Matches([System.IO.File]::ReadAllText($f), '\b(4\d{3}|5\d{3})\b')) { [void]$used.Add([int]$m.Value) }
    }
  }
}
# A block of four consecutive free ports, so preview/test/film/dev of one game stay together
# and are obvious at a glance in netstat. Never a Vite default (4173, 5173, 4200).
$viteDefaults = @(4173, 4200, 5173)
$block = 4400
while ($true) {
  $cand = @($block, ($block + 1), ($block + 2), ($block + 3))
  if (-not (@($cand | Where-Object { $used.Contains($_) -or $viteDefaults -contains $_ }).Count)) { break }
  $block += 4
  if ($block -gt 4980) { Fail "no free block of four ports between 4400 and 4980; some games are holding more ports than expected." }
}
$previewPort = $block; $testPort = $block + 1; $filmPort = $block + 2; $devPort = $block + 3

Write-Step "Renaming and re-porting"
$srcSlug = Split-Path $WebSource -Leaf
# ToTitleCase on the whole slug turns 'candle-gift' into 'Candle-Gift', which matches nothing
# in a file that spells the game "Candle Gift". Build both spellings, per word.
$srcWords = @($srcSlug -split '-' | ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($_) })
$srcTitle = $srcWords -join ' '
$srcTitleHyphen = $srcWords -join '-'
$srcFlat = $srcSlug -replace '-', ''
$srcTitleFlat = $srcWords -join ''

# Ordered, so the longest spelling is replaced first: replacing 'coreward' before
# 'coreward-deep' would leave a half-renamed string behind. And ORDINAL, which is the part
# that is easy to get wrong - a bare [ordered]@{} compares its keys case-INSENSITIVELY, so
# adding 'Coreward' makes it claim to already contain 'coreward' and the lower-case entry is
# silently dropped. Every lower-case mention of the source game then survives the rename.
$webMap = New-Object 'System.Collections.Specialized.OrderedDictionary' ([System.StringComparer]::Ordinal)
foreach ($pair in @(
    @($srcTitleHyphen, $Name), @($srcTitle, $Name), @($srcTitleFlat, $Name),
    @($srcSlug, $Slug), @($srcFlat, ($Slug -replace '-', ''))
  )) {
  if ($pair[0] -and -not $webMap.Contains($pair[0])) { $webMap[$pair[0]] = $pair[1] }
}
$textExt = '.ts', '.js', '.mjs', '.json', '.html', '.md', '.yml', '.yaml', '.css', '.webmanifest', '.gitattributes', '.gitignore'
# -Force so .claude and the dotfiles are included; .git does not exist yet at this point.
Get-ChildItem $Dest -Recurse -File -Force | Where-Object { $textExt -contains $_.Extension -or $_.Name -in '.gitattributes', '.gitignore' } | ForEach-Object {
  Replace-InFile $_.FullName $webMap
}

# Substitute each role's literal where that role lives. The test port's literal also appears
# in playwright.config.ts's prose ("4319, and NOT 4173 or 4200, on purpose"), and rewriting it
# there is correct - it is this game's port being described. The Vite defaults named in the
# same sentence are different literals and are left alone, which the old blanket 4\d{3} regex
# did not manage.
if ($srcTestPort) { Replace-InFile $PwConfig ([ordered]@{ "$srcTestPort" = "$testPort" }) }
if (Test-Path $LaunchJson) {
  $lj = [ordered]@{}
  if ($srcPreviewPort) { $lj["$srcPreviewPort"] = "$previewPort" }
  if ($srcDevPort -and $srcDevPort -ne $srcPreviewPort) { $lj["$srcDevPort"] = "$devPort" }
  Replace-InFile $LaunchJson $lj
}
if ($srcFilmPort -and (Test-Path $Filmstrip)) {
  $t = [System.IO.File]::ReadAllText($Filmstrip)
  # Targeted, not a whole-file replace: filmstrip.mjs is full of other four-digit numbers.
  $t = [regex]::Replace($t, '(const PORT\s*=\s*)\d{4,5}', "`${1}$filmPort")
  [System.IO.File]::WriteAllText($Filmstrip, $t, $Utf8)
}
Write-Host "   ports: preview $previewPort, tests $testPort, film $filmPort, dev $devPort"

# ── the game itself ──────────────────────────────────────────────────────────
# "keep the tooling, replace src with a stub the smoke test can boot" was a comment above a
# loop that wrote four markdown files and touched no code at all, so every web game was
# committed as "Scaffold <Name> from coreward tooling" containing all of Coreward's gameplay,
# its Playwright suite and its frozen golden baselines. This is that comment, done.
Write-Step "Replacing $srcSlug's game code with the bootable stub"
foreach ($d in 'src', 'e2e', 'test') {
  $p = Join-Path $Dest $d
  if (Test-Path $p) { Remove-Item $p -Recurse -Force }
}
# A budget copied from another game is a guard whose numbers were never measured here. It is
# deleted and re-recorded from this repo's own first build, below.
Remove-Item (Join-Path $Dest 'bundle-budget.json') -Force -ErrorAction SilentlyContinue
robocopy $WebStub $Dest /E /XF README.md /NFL /NDL /NJH /NJS | Out-Null
if ($LASTEXITCODE -ge 8) { Fail "robocopy of the web stub failed ($LASTEXITCODE)" }
foreach ($must in 'src\main.ts', 'src\sim\state.ts', 'src\view\scene.ts', 'index.html', 'e2e\smoke.spec.ts', 'test\state.test.mjs') {
  if (-not (Test-Path (Join-Path $Dest $must))) { Fail "the stub did not land: $must is missing from $Dest" }
}

$stubDesc = if ($Description) { $Description } else { "A phone game. See PLAN.md for what it is." }
$stubMap = [ordered]@{
  '{{DESCRIPTION}}' = $stubDesc
  '{{PREVIEWPORT}}' = "$previewPort"
  '{{TESTPORT}}'    = "$testPort"
  '{{FILMPORT}}'    = "$filmPort"
  '{{NAME}}'        = $Name
  '{{SLUG}}'        = $Slug
  '{{DATE}}'        = $today
}
Replace-InFile (Join-Path $Dest 'index.html') $stubMap
foreach ($d in 'src', 'e2e', 'test') {
  Get-ChildItem (Join-Path $Dest $d) -Recurse -File | ForEach-Object { Replace-InFile $_.FullName $stubMap }
}

Write-Step "Writing README, CLAUDE.md, NOTES.md, PLAN.md"
$stubDir = Join-Path $PSScriptRoot '..\setup\game-stubs'
foreach ($f in 'README.md', 'CLAUDE.md', 'NOTES.md', 'PLAN.md') {
  $src = Join-Path $stubDir "web-$f"
  if (-not (Test-Path $src)) { Fail "missing stub $src" }
  $text = [System.IO.File]::ReadAllText($src)
  $text = $text.Replace('{{SLUG}}', $Slug).Replace('{{NAME}}', $Name).Replace('{{PACKAGE}}', $PackageId).Replace('{{DATE}}', $today).Replace('{{DESCRIPTION}}', $Description).Replace('{{TESTPORT}}', "$testPort").Replace('{{PREVIEWPORT}}', "$previewPort").Replace('{{FILMPORT}}', "$filmPort")
  Write-Text (Join-Path $Dest $f) $text
}
Copy-PrePlan $Dest

Assert-NoPlaceholders $Dest $textExt ([regex]::Escape($srcSlug) + '|' + [regex]::Escape($srcTitle) + '|' + [regex]::Escape($srcTitleHyphen) + '|\{\{[A-Z]+\}\}')

# ── commit, then build, measure and prove ────────────────────────────────────
# The scaffold commit comes BEFORE the build, and that order is load-bearing: vite.config.js
# stamps the build with `git rev-parse --short HEAD`, and a build run in a directory that is
# not yet a repository stamps it "unknown". The smoke test asserts the stamp is real, because
# a stamp nobody can read makes an old build on the phone look current.
Push-Location $Dest
Write-Step "git init"
Native { git init -b main | Out-Null }
Native { git add -A }
Native { git commit -q -m "Scaffold $Name from $srcSlug tooling" -m "Tooling only: $srcSlug's src/, e2e/ and test/ were removed and replaced with setup/web-stub. Ports preview $previewPort, tests $testPort, film $filmPort, dev $devPort.`n`nCo-Authored-By: Claude <noreply@anthropic.com>" }
if ($LASTEXITCODE -ne 0) { Pop-Location; Fail "the first commit failed" }

Write-Step "npm install"
Native { npm install 2>&1 | Select-Object -Last 3 | ForEach-Object { Write-Host "   $_" } }
# An npm install that failed used to go unnoticed until the repo had already been created and
# pushed, at which point the first thing anyone saw was a red CI run.
if ($LASTEXITCODE -ne 0) { Pop-Location; Fail "npm install failed in $Dest. Nothing was pushed; fix it and re-run after deleting $Dest." }

Write-Step "Building and recording this repo's own bundle budget"
Native { npm run build }
if ($LASTEXITCODE -ne 0) { Pop-Location; Fail "npm run build failed on the fresh stub. Fix $WebSource's tooling before scaffolding from it." }
Native { npm run size:update }
if ($LASTEXITCODE -ne 0) { Pop-Location; Fail "npm run size:update failed, so there is no bundle-budget.json. The size guard would then pass by having nothing to check." }
if (-not (Test-Path (Join-Path $Dest 'bundle-budget.json'))) { Pop-Location; Fail "size:update wrote no bundle-budget.json" }

if (-not $SkipTests) {
  Write-Step "Proving the stub passes its own gate"
  Native { npm run typecheck }
  if ($LASTEXITCODE -ne 0) { Pop-Location; Fail "typecheck failed on the fresh stub." }
  Native { npm test }
  if ($LASTEXITCODE -ne 0) { Pop-Location; Fail "the golden tests failed on the fresh stub." }
  Native { npx --yes playwright install chromium }
  if ($LASTEXITCODE -ne 0) {
    Write-Host "   Playwright's browser could not be installed, so the smoke test did NOT run here." -ForegroundColor Yellow
    Write-Host "   It is NOT established that this build boots. CI runs the smoke test on the first push: watch that run." -ForegroundColor Yellow
  } else {
    Native { npm run e2e }
    if ($LASTEXITCODE -ne 0) { Pop-Location; Fail "the smoke test failed on the fresh stub: the scaffolded game does not boot. Nothing was pushed." }
    Write-Host "   typecheck, golden tests and smoke green"
  }
}

# A second commit rather than an amend: the sha the build was stamped with is the first one,
# and amending would orphan it, so the stamp on that build would name a commit that is not in
# the history. The budget is a measurement of that build and says so.
Native { git add -A }
Native { git commit -q -m "Record the bundle budget from the first build" -m "Measured here by npm run size:update, not copied from $srcSlug.`n`nCo-Authored-By: Claude <noreply@anthropic.com>" }
if ($LASTEXITCODE -ne 0) { Pop-Location; Fail "committing bundle-budget.json failed; CI's size guard would have nothing to check." }

if (-not $NoRepo) {
  Write-Step "Creating github.com/$Owner/$Slug and enabling Pages"
  $vis = if ($Private) { '--private' } else { '--public' }
  Native { gh repo create "$Owner/$Slug" $vis --source . --remote origin --push --description "$Name, a phone game on GitHub Pages" }
  if ($LASTEXITCODE -ne 0) { Pop-Location; Fail "gh repo create failed" }
  Native { gh api -X POST "repos/$Owner/$Slug/pages" -f build_type=workflow 2>&1 | Out-Null }
  if ($LASTEXITCODE -ne 0) {
    # Already-enabled Pages answers 409 to POST; PUT is the update path.
    Native { gh api -X PUT "repos/$Owner/$Slug/pages" -f build_type=workflow }
    if ($LASTEXITCODE -ne 0) { Write-Host "   could not enable Pages through the API; turn it on by hand under Settings > Pages (source: GitHub Actions)." -ForegroundColor Yellow }
  }
  Native { gh api "repos/$Owner/$Slug/pages" --jq '.build_type + " " + .html_url' }
  if ($LASTEXITCODE -ne 0) { Write-Host "   Pages is not reporting a URL yet; check Settings > Pages after the first deploy." -ForegroundColor Yellow }
}
Pop-Location
Write-Host ""
Write-Host "Done. $Name is at $Dest" -ForegroundColor Green
Write-Host "src/ is the stub, not a game. Read PLAN.md and replace it; keep the pure/view split, window.__game.advance(dt), and the ids e2e/smoke.spec.ts reads." -ForegroundColor Yellow
if (-not $NoRepo) { Write-Host "Repo: https://github.com/$Owner/$Slug   Live at https://$Owner.github.io/$Slug/ once the first deploy finishes." }
