<#
.SYNOPSIS
  The standing self-check for the game-dev framework. Asserts the invariants that cannot be
  a unit test inside one game repo, across every repo under C:\dev, and fails loudly.

.DESCRIPTION
  The 2026-09-11 audit named one root cause above all the others: "most rules are written as
  advice about a convention rather than as a test that fails, so a session that has not read
  the line repeats the bug." Six of the eight repeat-offender classes had a correct rule
  written down before the bug happened, and the rule prevented nothing.

  The fix for anything that lives inside a game is a test in godot-template/test/, which a
  scaffolded game inherits. This script is the fix for everything else: the things that are
  true of the studio rather than of one game. Inbox backlog, digest staleness, lesson format,
  broken cross-references, per-repo drift from the template, export guards, version/code,
  the sim wall, git hygiene, web ports. Every one of those was a finding in the audit, and
  every one of them was invisible because nothing looked.

  **A check that inspected nothing FAILS.** The audit's most-repeated fault class is "a check
  that passes because nothing happened" - a blind gate reporting errors 0, a runner reporting
  65 passing for a suite that never ran, an asset scout writing down a miss it read off a 404.
  This script must not join that list, so every glob that comes back empty, every repo list
  that comes back empty and every file that cannot be read is a FAIL with the reason, not a
  quiet PASS. An empty inbox is the one deliberate exception: the directory was found and
  read, and nothing in it is the good answer.

  Exit code 0 when clean or warnings only, 1 on any FAIL, so CI and a SessionStart hook can
  gate on it.

.PARAMETER Fix
  Apply only the changes that are unambiguously safe and reversible, naming each one.
  Today that is exactly one thing: creating a missing build/.gdignore. Editing
  export_presets.cfg, .gitignore, a changelog or any source file is NOT in that set - those
  carry a judgement about which value is right, and a script that guesses at one is how a
  wrong version code gets committed without anyone reading it.

.PARAMETER Quiet
  Print only WARN and FAIL, and skip the deep checks (cross-references, template content
  drift, sim purity, git hygiene), so a SessionStart hook can run it on every session.

.PARAMETER Repo
  Narrow the per-repo checks to one game by directory name. The knowledge-base checks
  always run.

.PARAMETER IncludeSnapshots
  Also check directories that look like snapshots or worktrees (*.pre-fix, *-audit, *.bak,
  *.old). They are skipped by default because a deliberate before-the-fix copy reporting
  its FAILs on every session is how a person learns to stop reading the output. The skipped
  names are always printed.

.EXAMPLE
  powershell -File C:\dev\gamedev-notes\scripts\doctor.ps1
  powershell -File C:\dev\gamedev-notes\scripts\doctor.ps1 -Quiet
  powershell -File C:\dev\gamedev-notes\scripts\doctor.ps1 -Repo stillwater
  powershell -File C:\dev\gamedev-notes\scripts\doctor.ps1 -Fix
#>
[CmdletBinding()]
param(
  [string] $Root = 'C:\dev',
  # The notes repo this script lives in, so the copy in a worktree checks that worktree
  # rather than reporting on a tree nobody is editing.
  #
  # **Resolved in the body, not here.** `$PSScriptRoot` is empty while parameter
  # defaults are being bound under some hosts - launched through `powershell -File`
  # from a non-PowerShell shell it binds to '', and `Split-Path ''` is a terminating
  # error, so the script died on its own param block before running a single check.
  # Every game's gate reported `framework FAIL` and none of them had anything wrong.
  [string] $Notes = '',
  [string] $Template = 'C:\dev\godot-template',
  [string] $Repo,
  [switch] $Fix,
  [switch] $Quiet,
  [switch] $IncludeSnapshots
)

$ErrorActionPreference = 'Stop'

# `$PSScriptRoot` is reliable HERE even when it was empty during parameter binding.
# `$MyInvocation.MyCommand.Path` is the fallback for the hosts where neither is set.
if (-not $Notes) {
  $here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path $MyInvocation.MyCommand.Path -Parent }
  $Notes = Split-Path $here -Parent
}

$Utf8 = New-Object System.Text.UTF8Encoding($false)
$script:Results = New-Object System.Collections.ArrayList
$script:Fixed = New-Object System.Collections.ArrayList
$script:Skipped = New-Object System.Collections.ArrayList

# git writes progress, "Everything up-to-date" and expected failures to stderr, and
# $ErrorActionPreference = 'Stop' turns any of that into a terminating NativeCommandError
# BEFORE the exit-code check below it ever runs. Every native call goes through this, so the
# exit code stays the only thing that decides. (Same helper as scripts\kb.ps1.)
function Native([scriptblock]$Block) {
  $prev = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try { & $Block } finally { $ErrorActionPreference = $prev }
}

function Add-Result([string] $Area, [string] $Name, [string] $Status, [string] $Detail) {
  [void] $script:Results.Add([pscustomobject]@{ Area = $Area; Name = $Name; Status = $Status; Detail = $Detail })
}
function Pass([string] $Area, [string] $Name, [string] $Detail) { Add-Result $Area $Name 'PASS' $Detail }
function Warn([string] $Area, [string] $Name, [string] $Detail) { Add-Result $Area $Name 'WARN' $Detail }
function Fail([string] $Area, [string] $Name, [string] $Detail) { Add-Result $Area $Name 'FAIL' $Detail }

function Read-TextFile([string] $Path) {
  # ReadAllText, never Get-Content: Get-Content splits on line endings and hands back an
  # array, and the repo is LF-only by .gitattributes. Everything here reasons over raw text.
  try { return [System.IO.File]::ReadAllText($Path) } catch { return $null }
}

function Get-TextLines([string] $Path) {
  $t = Read-TextFile $Path
  if ($null -eq $t) { return $null }
  return ($t -split '\r?\n')
}

# A short, readable list for an error line: the first few names and a count of the rest.
function Join-Some([string[]] $Items, [int] $Max = 6) {
  if (-not $Items -or $Items.Count -eq 0) { return '(none)' }
  if ($Items.Count -le $Max) { return ($Items -join ', ') }
  return (($Items[0..($Max - 1)] -join ', ') + ", +$($Items.Count - $Max) more")
}

function Format-Kb([long] $Bytes) {
  if ($Bytes -ge 1048576) { return ('{0:N1} MB' -f ($Bytes / 1MB)) }
  return ('{0:N0} KB' -f ($Bytes / 1KB))
}

# ── Text strippers ────────────────────────────────────────────────────────────
# Both of these exist for one reason: this studio documents a rule by quoting the thing the
# rule forbids. Every sim file carries a header saying "no Node, no Viewport, no input
# event"; coreward's playwright.config.ts explains at length why it is NOT on 4173, 4200 or
# 5173. A matcher that reads raw text fires on the paragraph that exists to prevent the bug
# and on nothing else, which is worse than no matcher at all, because it trains the reader to
# stop looking. Comments and string literals come out first, always.
#
# The alternation order is the whole algorithm: at any position the string forms are tried
# before the comment form, so a '#' inside a string is text, and a quote inside a comment is
# comment. Line numbers are preserved - a multi-line match is replaced by its own newlines -
# so every finding below can name a file and a line.

function Remove-GdCommentsAndStrings([string] $Text) {
  $pattern = '"""[\s\S]*?"""' + "|'''[\s\S]*?'''" + '|"(?:\\.|[^"\\\n])*"' + "|'(?:\\.|[^'\\\n])*'" + '|#[^\n]*'
  $eval = [System.Text.RegularExpressions.MatchEvaluator] {
    param($m)
    $v = $m.Value
    if ($v.StartsWith('#')) { return '' }
    $nl = ([regex]::Matches($v, "`n")).Count
    if ($nl -eq 0) { return ' ' }
    return ("`n" * $nl)
  }
  return [regex]::Replace($Text, $pattern, $eval)
}

function Remove-JsComments([string] $Text) {
  # Strings are KEPT here: a port lives inside one ('http://127.0.0.1:4319'). Only comments go.
  $pattern = '/\*[\s\S]*?\*/' + '|//[^\n]*' + '|"(?:\\.|[^"\\\n])*"' + "|'(?:\\.|[^'\\\n])*'" + '|`(?:\\.|[^`\\])*`'
  $eval = [System.Text.RegularExpressions.MatchEvaluator] {
    param($m)
    $v = $m.Value
    if (-not $v.StartsWith('/')) { return $v }
    $nl = ([regex]::Matches($v, "`n")).Count
    if ($nl -eq 0) { return ' ' }
    return ("`n" * $nl)
  }
  return [regex]::Replace($Text, $pattern, $eval)
}

function Get-LineNumber([string] $Text, [int] $Index) {
  if ($Index -le 0) { return 1 }
  return ([regex]::Matches($Text.Substring(0, $Index), "`n")).Count + 1
}

# ── Small parsers ─────────────────────────────────────────────────────────────

# export_presets.cfg, read as text rather than through ConfigFile. A preset is [preset.N]
# plus its [preset.N.options] section, and version/code lives in the second one while
# exclude_filter lives in the first, so both are grouped under the same index N.
function Get-ExportPresets([string] $Path) {
  $lines = Get-TextLines $Path
  if ($null -eq $lines) { return $null }
  $out = New-Object System.Collections.ArrayList
  $byIndex = @{}
  $cur = $null
  foreach ($l in $lines) {
    $m = [regex]::Match($l, '^\s*\[preset\.(\d+)(\.[A-Za-z_]+)?\]\s*$')
    if ($m.Success) {
      $idx = $m.Groups[1].Value
      if (-not $byIndex.ContainsKey($idx)) {
        $p = [pscustomobject]@{ Index = $idx; Name = $null; ExcludeFilter = $null; VersionCode = $null; VersionName = $null }
        $byIndex[$idx] = $p
        [void] $out.Add($p)
      }
      $cur = $byIndex[$idx]
      continue
    }
    if ($null -eq $cur) { continue }
    $kv = [regex]::Match($l, '^\s*([A-Za-z0-9_/]+)\s*=\s*(.*)$')
    if (-not $kv.Success) { continue }
    $key = $kv.Groups[1].Value
    $val = $kv.Groups[2].Value.Trim()
    if ($val.StartsWith('"') -and $val.EndsWith('"') -and $val.Length -ge 2) { $val = $val.Substring(1, $val.Length - 2) }
    switch ($key) {
      'name'           { if ($null -eq $cur.Name) { $cur.Name = $val } }
      'exclude_filter' { $cur.ExcludeFilter = $val }
      'version/code'   { $cur.VersionCode = $val }
      'version/name'   { $cur.VersionName = $val }
    }
  }
  return $out
}

# The .gitignore rules that git actually applies: comments and blank lines are not rules,
# and every repo here explains the build/* trap in a comment that quotes the anti-pattern.
function Get-EffectiveIgnoreLines([string] $Path) {
  $lines = Get-TextLines $Path
  if ($null -eq $lines) { return $null }
  return @($lines | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' -and -not $_.StartsWith('#') })
}

# ══ Knowledge base ════════════════════════════════════════════════════════════

$KB = 'Knowledge base'

function Test-KnowledgeBase {
  if (-not (Test-Path -LiteralPath $Notes)) {
    Fail $KB 'repo' "no knowledge base at $Notes. Fix: pass -Notes <path>, or clone gamedev-notes there."
    return
  }

  $inboxDir = Join-Path $Notes 'inbox'
  if (-not (Test-Path -LiteralPath $inboxDir)) {
    Fail $KB 'inbox' "no inbox/ under $Notes. Fix: this is the write path of the whole base - restore it from git before writing another lesson."
    return
  }
  # README.md is the directory's own note, not a lesson.
  $lessons = @(Get-ChildItem -LiteralPath $inboxDir -Filter '*.md' -File | Where-Object { $_.Name -ne 'README.md' })

  Test-InboxBacklog $lessons
  Test-DigestAge $lessons.Count
  Test-LessonFormat $lessons
  Test-BelongsInTargets $lessons
  Test-TechniquesIndex
  Test-PlaytestsIndex
  Test-TopicFileSize
  if (-not $Quiet) { Test-CrossReferences }
}

# 1. The backlog itself. /digest stopping is the audit's single largest finding: 44 lessons
#    piled up while every topic file stayed frozen at the last digest, and four live
#    contradictions stood in the base at once because of it.
function Test-InboxBacklog([object[]] $Lessons) {
  $n = $Lessons.Count
  if ($n -eq 0) {
    Pass $KB 'inbox backlog' 'inbox is empty; every lesson has been folded in'
    return
  }
  # The date is in the filename by convention (YYYY-MM-DD-<game>-<slug>.md). Fall back to the
  # file's own timestamp rather than skipping the oldest-lesson line, which is the number
  # that says how long a session has been reading stale topic files.
  $oldest = $null
  foreach ($f in $Lessons) {
    $m = [regex]::Match($f.Name, '^(\d{4}-\d{2}-\d{2})-')
    $d = $null
    if ($m.Success) {
      try { $d = [datetime]::ParseExact($m.Groups[1].Value, 'yyyy-MM-dd', [cultureinfo]::InvariantCulture) } catch { $d = $null }
    }
    if ($null -eq $d) { $d = $f.LastWriteTime.Date }
    if ($null -eq $oldest -or $d -lt $oldest) { $oldest = $d }
  }
  $days = [int]([datetime]::Now.Date - $oldest).TotalDays
  $age = "oldest lesson $($oldest.ToString('yyyy-MM-dd')), standing $days day$(if ($days -eq 1) { '' } else { 's' })"
  if ($n -gt 25) {
    Fail $KB 'inbox backlog' "$n lessons waiting ($age). Fix: run /digest now, before any other work in this repo - a lesson nobody folded in is a lesson the other games never got."
  } elseif ($n -gt 10) {
    Warn $KB 'inbox backlog' "$n lessons waiting ($age). Run /digest; the documented threshold is ten."
  } else {
    Pass $KB 'inbox backlog' "$n lesson$(if ($n -eq 1) { '' } else { 's' }) waiting ($age)"
  }
}

# 2. How long since the read path last moved. Cheap on purpose: one git log, one line.
function Test-DigestAge([int] $InboxCount) {
  # stderr is discarded: git prints repository housekeeping warnings there, and one of them
  # landing in the middle of this report reads like a finding.
  $out = Native { git -C $Notes log --grep=Digest -1 --format=%cI 2>$null }
  if ($LASTEXITCODE -ne 0) {
    Fail $KB 'digest age' "git log failed in $Notes. Fix: check that $Notes is a git repository; without it this script cannot tell whether the base is being digested at all."
    return
  }
  $stamp = ($out -join '').Trim()
  if (-not $stamp) {
    Fail $KB 'digest age' "no commit matching 'Digest' in the history of $Notes. Fix: /digest has never run here, or its commit message changed - if the message changed, fix this check in scripts\doctor.ps1 rather than ignoring the line."
    return
  }
  $when = $null
  try { $when = [datetimeoffset]::Parse($stamp, [cultureinfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind) } catch { $when = $null }
  if ($null -eq $when) {
    Fail $KB 'digest age' "could not read the date of the last digest commit ('$stamp'). Fix: scripts\doctor.ps1 expects git's %cI format."
    return
  }
  $days = [math]::Round(([datetimeoffset]::Now - $when).TotalDays, 1)
  $desc = "last /digest $($when.ToLocalTime().ToString('yyyy-MM-dd HH:mm')), $days days ago"
  if ($InboxCount -gt 0 -and $days -gt 3) {
    Warn $KB 'digest age' "$desc, with $InboxCount lesson(s) waiting. Run /digest."
  } else {
    Pass $KB 'digest age' $desc
  }
}

# 3. Lesson format. "Replaces or contradicts" is not decoration: it is the only mechanism in
#    the whole base that catches a lesson contradicting an existing rule, and the audit found
#    it missing from 69% of the inbox while four contradictions stood live in the topic files.
function Test-LessonFormat([object[]] $Lessons) {
  if ($Lessons.Count -eq 0) {
    Pass $KB 'lesson format' 'inbox is empty; nothing to check'
    return
  }
  $noBelongs = @()
  $noReplaces = @()
  $unreadable = @()
  foreach ($f in $Lessons) {
    $t = Read-TextFile $f.FullName
    if ($null -eq $t) { $unreadable += $f.Name; continue }
    if (-not [regex]::IsMatch($t, '(?im)Belongs\s+in\s*:')) { $noBelongs += $f.Name }
    if (-not [regex]::IsMatch($t, '(?im)^\s*#{1,3}\s*Replaces\s+or\s+contradicts\s*$')) { $noReplaces += $f.Name }
  }
  if ($unreadable.Count -gt 0) {
    Fail $KB 'lesson format' "could not read $($unreadable.Count) inbox file(s): $(Join-Some $unreadable). Fix: a lesson this script cannot read is a lesson /digest cannot fold in either."
  }
  if ($noBelongs.Count -eq 0 -and $noReplaces.Count -eq 0) {
    Pass $KB 'lesson format' "$($Lessons.Count) lesson(s), all carrying 'Belongs in:' and '## Replaces or contradicts'"
    return
  }
  $pct = [int](100 * $noReplaces.Count / $Lessons.Count)
  $bits = @()
  if ($noBelongs.Count -gt 0) { $bits += "$($noBelongs.Count) without 'Belongs in:' ($(Join-Some $noBelongs 4))" }
  if ($noReplaces.Count -gt 0) { $bits += "$($noReplaces.Count) of $($Lessons.Count) ($pct%) without '## Replaces or contradicts' ($(Join-Some $noReplaces 4))" }
  $detail = "$($bits -join '; '). Fix: add the fields from the template in skills\record-lesson\SKILL.md. Without 'Replaces or contradicts' a digest folds a correction in BESIDE the rule it corrects and both survive."
  # **A gate must not fail for something the repo being gated cannot fix.**
  #
  # `check.ps1` runs this doctor as the last step of every game's gate, with
  # `-Repo <slug>`. The inbox is shared, so the first time that ran, wildform's
  # gate went red because a CONCURRENT session on a different game had filed
  # three lessons in a different header format. Nothing about wildform was
  # wrong and nothing wildform could do would fix it - and the only ways out of
  # that are to edit another session's work or to stop running the gate.
  #
  # So: still a FAIL for the full framework audit, which is where the knowledge
  # base is somebody's job. A WARN when one repo is being gated, which reports
  # it at every commit without holding a sound release hostage to another
  # game's paperwork.
  if ($Repo) { Warn $KB 'lesson format' $detail } else { Fail $KB 'lesson format' $detail }
}

# 4. Every "Belongs in:" names a file that exists, so a digest is never sent at a target that
#    is not there. The field wraps onto the next line often enough that the next line is read
#    too.
function Test-BelongsInTargets([object[]] $Lessons) {
  if ($Lessons.Count -eq 0) {
    Pass $KB 'lesson targets' 'inbox is empty; nothing to check'
    return
  }
  $withField = 0
  $missing = @()
  foreach ($f in $Lessons) {
    $lines = Get-TextLines $f.FullName
    if ($null -eq $lines) { continue }
    for ($i = 0; $i -lt $lines.Count; $i++) {
      $idx = $lines[$i].IndexOf('Belongs in:')
      if ($idx -lt 0) { continue }
      $seg = $lines[$i].Substring($idx)
      if ($i + 1 -lt $lines.Count -and $lines[$i + 1].Trim() -ne '' -and -not $lines[$i + 1].TrimStart().StartsWith('#')) { $seg += ' ' + $lines[$i + 1] }
      $withField++
      foreach ($m in [regex]::Matches($seg, '[A-Za-z0-9_./-]+\.md')) {
        $target = $m.Value.Trim('`')
        if (-not (Test-Path -LiteralPath (Join-Path $Notes $target))) { $missing += "$($f.Name) -> $target" }
      }
      break
    }
  }
  if ($withField -eq 0) {
    Fail $KB 'lesson targets' "not one of $($Lessons.Count) lesson(s) carries a 'Belongs in:' field, so this check inspected nothing. Fix: see the lesson-format line above."
    return
  }
  if ($missing.Count -gt 0) {
    Fail $KB 'lesson targets' "$($missing.Count) lesson(s) point at a file that does not exist: $(Join-Some $missing 4). Fix: correct the 'Belongs in:' field, or create the target before the digest runs."
    return
  }
  Pass $KB 'lesson targets' "$withField lesson(s) name a target; every target exists"
}

# 6. techniques/README.md indexes every file, and every indexed file exists. Both directions:
#    the last digest added gravewell-tunnel-light-and-beam.md and never wrote its index row,
#    so the write-up existed and nothing pointed at it.
function Test-DirectoryIndex([string] $Dir, [string] $CheckName) {
  $path = Join-Path $Notes $Dir
  $readme = Join-Path $path 'README.md'
  if (-not (Test-Path -LiteralPath $path)) {
    Fail $KB $CheckName "no $Dir/ under $Notes. Fix: restore it from git."
    return
  }
  if (-not (Test-Path -LiteralPath $readme)) {
    Fail $KB $CheckName "no $Dir/README.md. Fix: it is the index; without it nothing points at the files in there."
    return
  }
  $files = @(Get-ChildItem -LiteralPath $path -Filter '*.md' -File | Where-Object { $_.Name -ne 'README.md' } | ForEach-Object { $_.Name })
  if ($files.Count -eq 0) {
    Fail $KB $CheckName "$Dir/ holds no .md files besides README.md, so this check inspected nothing. Fix: if that is right, say so in $Dir/README.md; if it is not, the files moved."
    return
  }
  $text = Read-TextFile $readme
  if ($null -eq $text) {
    Fail $KB $CheckName "could not read $Dir/README.md. Fix: check the file."
    return
  }
  $indexed = @()
  foreach ($m in [regex]::Matches($text, '[A-Za-z0-9_./-]+\.md')) {
    $n = Split-Path $m.Value -Leaf
    if ($n -ne 'README.md' -and $indexed -notcontains $n) { $indexed += $n }
  }
  $notIndexed = @($files | Where-Object { $indexed -notcontains $_ })
  # A name counts as resolved if a file of that name exists anywhere under the
  # notes repo, not only in this directory. An index legitimately names an
  # archived file while pointing at archive/, and flagging that trains the
  # reader to ignore this check - which is how a watchdog stops being read.
  $ghosts = @($indexed | Where-Object {
    $n = $_
    if ($files -contains $n) { return $false }
    if (Test-Path -LiteralPath (Join-Path $Notes $n)) { return $false }
    $hit = @(Get-ChildItem -LiteralPath $Notes -Filter $n -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1)
    return ($hit.Count -eq 0)
  })
  $bits = @()
  if ($notIndexed.Count -gt 0) { $bits += "$($notIndexed.Count) file(s) in $Dir/ with no index row: $(Join-Some $notIndexed)" }
  if ($ghosts.Count -gt 0) { $bits += "$($ghosts.Count) indexed name(s) with no file: $(Join-Some $ghosts)" }
  if ($bits.Count -eq 0) {
    Pass $KB $CheckName "$($files.Count) file(s), all indexed in $Dir/README.md"
    return
  }
  Fail $KB $CheckName "$($bits -join '; '). Fix: edit $Dir/README.md so the index and the directory agree - a write-up nothing points at is a write-up nobody reads."
}

function Test-TechniquesIndex { Test-DirectoryIndex 'techniques' 'techniques index' }

# 8. playtests/README.md lists every file. His words are the evidence base; a game missing
#    from the list is a game whose feedback no session knows to go and read.
function Test-PlaytestsIndex { Test-DirectoryIndex 'playtests' 'playtests index' }

# 7. Topic files stay readable. CLAUDE.md: "Keep every topic file under about 30 KB. When a
#    section grows, condense it or move the detail to techniques/." Over the soft limit is a
#    condense-soon signal; well over it means the file has stopped being read to the end,
#    which is how a rule ends up written down and ignored.
function Test-TopicFileSize {
  $topics = 'INDEX.md', 'PLAYER.md', 'CRAFT.md', 'GODOT.md', 'TESTING.md', 'ASSETS.md', 'POLISH.md', 'PLAY.md', 'WEB.md'
  # The written rule is "under about 30 KB", so the soft limit implements ABOUT:
  # 32 KB. Three topic files sit just under 31 KB after the 2026-09-12 digest and
  # each already delegates its detail to techniques/, which is the behaviour the
  # rule wants. A warning that fires permanently on a file that is fine teaches
  # the reader to skip the output, which is the failure this whole script exists
  # to avoid. 35 KB stays a hard fail: past that the file stops being read.
  $soft = 32KB
  $hard = 35KB
  $missing = @()
  $over = @()
  $way = @()
  foreach ($t in $topics) {
    $p = Join-Path $Notes $t
    if (-not (Test-Path -LiteralPath $p)) { $missing += $t; continue }
    $len = (Get-Item -LiteralPath $p).Length
    if ($len -gt $hard) { $way += "$t $(Format-Kb $len)" }
    elseif ($len -gt $soft) { $over += "$t $(Format-Kb $len)" }
  }
  if ($missing.Count -gt 0) {
    Fail $KB 'topic file size' "missing topic file(s): $(Join-Some $missing). Fix: INDEX.md's file map promises them; restore them or correct the map."
  }
  if ($way.Count -gt 0) {
    Fail $KB 'topic file size' "over the 35 KB hard limit: $(Join-Some $way). Fix: condense in /digest, or move the detail to techniques/ and leave one line behind."
  } elseif ($over.Count -gt 0) {
    Warn $KB 'topic file size' "over the 32 KB soft limit: $(Join-Some $over). Condense at the next digest."
  } elseif ($missing.Count -eq 0) {
    Pass $KB 'topic file size' "all $($topics.Count) topic files within the about-30-KB rule"
  }
}

# 5. Broken cross-references. README.md listing movie.ps1 and device.ps1 under scripts/ was a
#    real instance, and techniques/README.md still cites a PIPELINE.md that has not existed
#    since the split. A reference that does not resolve costs a session the minutes it spends
#    looking for the file, and then costs it the rule the file was going to carry.
#
#    Three rules keep this quiet enough to be worth reading:
#      - a path is resolved relative to the file that names it FIRST, then to the repo root,
#        so techniques/README.md's bare rows resolve inside techniques/;
#      - a bare .ps1/.py/.gd name is resolved against the names that exist anywhere in this
#        repo's scripts/ and setup/ and in any game repo's scripts/, src/ and test/, because
#        GODOT.md talking about check.ps1 or save.gd means the game's copy, not this repo's;
#      - AUDIT*.md is not scanned. It is a narrative ABOUT missing files and quotes every one
#        of them by name.
function Test-CrossReferences {
  $topDirs = 'inbox', 'techniques', 'skills', 'playtests', 'setup', 'agents', 'archive', 'scripts'
  # Names that live in a GAME repo and are never expected here.
  $gameFiles = 'NOTES.md', 'PLAN.md', 'CLAUDE.md', 'PRIVACY.md', 'CREDITS.md', 'REFERENCE.md', 'DESIGN.md', 'SKILL.md', 'README.md', 'CHANGELOG.md', 'listing.md'

  $scan = @()
  $scan += @(Get-ChildItem -LiteralPath $Notes -Filter '*.md' -File | Where-Object { -not $_.Name.StartsWith('AUDIT') })
  $techDir = Join-Path $Notes 'techniques'
  if (Test-Path -LiteralPath $techDir) { $scan += @(Get-ChildItem -LiteralPath $techDir -Filter '*.md' -File) }
  $skillsDir = Join-Path $Notes 'skills'
  if (Test-Path -LiteralPath $skillsDir) {
    $scan += @(Get-ChildItem -LiteralPath $skillsDir -Directory | ForEach-Object {
      $s = Join-Path $_.FullName 'SKILL.md'
      if (Test-Path -LiteralPath $s) { Get-Item -LiteralPath $s }
    })
  }
  if ($scan.Count -eq 0) {
    Fail $KB 'cross references' "found no .md files to scan under $Notes. Fix: this check inspected nothing, which is not the same as finding nothing wrong."
    return
  }

  # The set of script names that exist anywhere a doc could legitimately mean.
  $known = @{}
  foreach ($d in 'scripts', 'setup') {
    $p = Join-Path $Notes $d
    if (Test-Path -LiteralPath $p) { Get-ChildItem -LiteralPath $p -File -Recurse | ForEach-Object { $known[$_.Name] = $true } }
  }
  $nameRoots = @($script:GameRepoPaths)
  if ($nameRoots -notcontains $Template) { $nameRoots += $Template }
  foreach ($r in $nameRoots) {
    foreach ($sub in 'scripts', 'src', 'test') {
      $p = Join-Path $r $sub
      if (Test-Path -LiteralPath $p) {
        Get-ChildItem -LiteralPath $p -File -Recurse | Where-Object { $_.Extension -in @('.ps1', '.py', '.gd') } | ForEach-Object { $known[$_.Name] = $true }
      }
    }
  }

  $rx = [regex] '(?:C:\\dev\\gamedev-notes\\)?((?:[A-Za-z0-9_.-]+[\\/])*[A-Za-z0-9_.-]+\.(?:md|ps1|py|gd|json|cfg|txt|yml))'
  $broken = @{}
  $checked = 0
  foreach ($f in $scan) {
    $lines = Get-TextLines $f.FullName
    if ($null -eq $lines) {
      Fail $KB 'cross references' "could not read $($f.Name). Fix: check the file."
      continue
    }
    $dir = Split-Path $f.FullName -Parent
    for ($i = 0; $i -lt $lines.Count; $i++) {
      foreach ($m in $rx.Matches($lines[$i])) {
        $p = $m.Groups[1].Value.Replace('\', '/')
        if ($p -match '://') { continue }
        $parts = $p.Split('/')
        $ok = $false
        if ($parts.Count -eq 1) {
          $ext = [System.IO.Path]::GetExtension($p)
          if ($ext -eq '.md') {
            if ($gameFiles -contains $p) { continue }
            $ok = (Test-Path -LiteralPath (Join-Path $dir $p)) -or (Test-Path -LiteralPath (Join-Path $Notes $p))
          } elseif ($ext -in @('.ps1', '.py', '.gd')) {
            $ok = $known.ContainsKey($p)
          } else {
            continue
          }
        } else {
          if ($topDirs -notcontains $parts[0]) { continue }
          $ok = (Test-Path -LiteralPath (Join-Path $dir $p)) -or (Test-Path -LiteralPath (Join-Path $Notes $p))
          if (-not $ok -and $parts[0] -eq 'scripts') { $ok = Test-Path -LiteralPath (Join-Path $Template $p) }
        }
        $checked++
        if (-not $ok) {
          $where = "$($f.Name):$($i + 1)"
          if ($broken.ContainsKey($p)) { $broken[$p] += @($where) } else { $broken[$p] = @($where) }
        }
      }
    }
  }
  if ($checked -eq 0) {
    Fail $KB 'cross references' "scanned $($scan.Count) file(s) and found no resolvable reference at all, so this check inspected nothing. Fix: the reference pattern in scripts\doctor.ps1 has stopped matching how the docs are written."
    return
  }
  if ($broken.Count -eq 0) {
    Pass $KB 'cross references' "$checked reference(s) across $($scan.Count) file(s), all resolve"
    return
  }
  foreach ($k in ($broken.Keys | Sort-Object)) {
    Fail $KB 'cross references' "'$k' does not exist, referenced at $(Join-Some $broken[$k] 4). Fix: correct the reference, or create the file it promises."
  }
}

# ══ Game repos ════════════════════════════════════════════════════════════════

# Every directory under $Root holding a project.godot, plus the template itself. Snapshots
# and worktrees (*.pre-fix, *-audit, *.bak, *.old) are skipped unless -IncludeSnapshots, and
# the skip is always printed: a check that quietly narrows its own scope is the failure this
# whole script exists to catch.
function Get-GameRepos {
  if (-not (Test-Path -LiteralPath $Root)) {
    Fail 'Game repos' 'discovery' "no $Root. Fix: pass -Root <path> to the directory the games live in."
    return @()
  }
  $all = @(Get-ChildItem -LiteralPath $Root -Directory | Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'project.godot') })
  if ((Test-Path -LiteralPath (Join-Path $Template 'project.godot')) -and ($all.FullName -notcontains (Get-Item -LiteralPath $Template).FullName)) {
    $all += @(Get-Item -LiteralPath $Template)
  }
  if ($all.Count -eq 0) {
    Fail 'Game repos' 'discovery' "no directory under $Root holds a project.godot, so every per-repo check below would have inspected nothing. Fix: check -Root, or that the games are where INDEX.md says they are."
    return @()
  }
  $keep = @()
  foreach ($d in $all) {
    $isSnapshot = $d.Name -match '(?i)(\.pre-fix|\.bak|\.old|-audit)$'
    if ($isSnapshot -and -not $IncludeSnapshots) { [void] $script:Skipped.Add($d.Name); continue }
    if ($Repo -and $d.Name -ne $Repo) { continue }
    $keep += $d
  }
  if ($Repo -and $keep.Count -eq 0) {
    Fail 'Game repos' 'discovery' "-Repo '$Repo' matched no game under $Root. Fix: use one of: $(Join-Some ($all | ForEach-Object { $_.Name }) 12)."
    return @()
  }
  if ($keep.Count -eq 0) {
    Fail 'Game repos' 'discovery' "every game under $Root was filtered out. Fix: drop -Repo, or pass -IncludeSnapshots."
    return @()
  }
  return $keep
}

# 9. The full stack from the first commit (INDEX.md rule 3). PLAN.md is not required of the
#    template, which is the one directory here that is not a game.
function Test-RequiredFiles([string] $Area, [string] $Path, [bool] $IsTemplate) {
  $required = 'CLAUDE.md', 'NOTES.md', 'PLAN.md', 'README.md', 'PRIVACY.md', 'export_presets.cfg', 'size-budget.json'
  $missing = @()
  foreach ($f in $required) {
    if ($IsTemplate -and $f -eq 'PLAN.md') { continue }
    if (-not (Test-Path -LiteralPath (Join-Path $Path $f))) { $missing += $f }
  }
  if ($missing.Count -eq 0) {
    Pass $Area 'required files' 'all present'
    return
  }
  Fail $Area 'required files' "missing $(Join-Some $missing). Fix: INDEX.md rule 3 - there are no one-off games. Copy each from godot-template (PLAN.md from setup\game-stubs\godot-PLAN.md) and fill it in."
}

# 10. The two guards against the 1.42 GB APK. exclude_filter keeps films and exports out of
#     the pack; build/.gdignore keeps Godot from importing them in the first place. Losing
#     either one has happened; losing both is how 3,720 PNGs shipped against a 28 MB budget.
function Test-ExportGuards([string] $Area, [string] $Path, [object[]] $Presets) {
  if ($null -eq $Presets -or $Presets.Count -eq 0) {
    Fail $Area 'export guards' "export_presets.cfg has no [preset.N] section, so nothing was inspected. Fix: restore it from godot-template - a repo with no preset cannot export at all."
  } else {
    $bad = @()
    foreach ($p in $Presets) {
      $label = if ($p.Name) { "preset.$($p.Index) '$($p.Name)'" } else { "preset.$($p.Index)" }
      if ($null -eq $p.ExcludeFilter) { $bad += "$label has no exclude_filter line" }
      elseif ($p.ExcludeFilter.Trim() -eq '') { $bad += "$label exclude_filter is empty" }
    }
    if ($bad.Count -eq 0) {
      Pass $Area 'export guards' "exclude_filter set in all $($Presets.Count) preset(s)"
    } else {
      Fail $Area 'export guards' "$(Join-Some $bad). Fix: set exclude_filter=`"build/*, *.log, *.apk, *.aab, *.idsig`" in EVERY preset, as godot-template does. Empty here is the 1.42 GB APK."
    }
  }

  $gd = Join-Path $Path 'build\.gdignore'
  if (Test-Path -LiteralPath $gd) {
    Pass $Area 'build/.gdignore' 'present'
    return
  }
  if ($Fix) {
    try {
      $buildDir = Join-Path $Path 'build'
      if (-not (Test-Path -LiteralPath $buildDir)) { [void] (New-Item -ItemType Directory -Path $buildDir -Force) }
      [System.IO.File]::WriteAllText($gd, '', $Utf8)
      [void] $script:Fixed.Add("created $gd")
      Pass $Area 'build/.gdignore' 'was missing; created it (-Fix)'
      return
    } catch {
      Fail $Area 'build/.gdignore' "missing, and creating it failed: $($_.Exception.Message). Fix: create an empty file at $gd."
      return
    }
  }
  Fail $Area 'build/.gdignore' "missing. Without it Godot imports and then EXPORTS whatever films leave in build\. Fix: create an empty file at $gd (or re-run with -Fix), and stage it with: git add -f build/.gdignore"
}

# 11. The .gitignore form that actually works. `build/` stops git descending into the
#     directory at all, so a later `!build/.gdignore` can never fire, and the `!build/` that
#     gets added to rescue it re-includes every output file instead. Comments are stripped
#     first: every repo here explains the trap in a comment that quotes both broken forms.
function Test-GitignoreForm([string] $Area, [string] $Path) {
  $gi = Join-Path $Path '.gitignore'
  $lines = Get-EffectiveIgnoreLines $gi
  if ($null -eq $lines) {
    Fail $Area '.gitignore' "no .gitignore. Fix: copy godot-template\.gitignore - without it the first blanket add stages the whole build directory."
    return
  }
  if ($lines.Count -eq 0) {
    Fail $Area '.gitignore' ".gitignore holds no rules, only comments or blanks, so nothing was inspected. Fix: copy godot-template\.gitignore."
    return
  }
  $anti = @($lines | Where-Object { $_ -in @('build/', 'build', '!build/', '!build') })
  $hasStar = $lines -contains 'build/*'
  $hasMarker = $lines -contains '!build/.gdignore'
  $bits = @()
  if ($anti.Count -gt 0) { $bits += "carries the anti-pattern line(s) $(($anti | ForEach-Object { "'$_'" }) -join ', ')" }
  if (-not $hasStar) { $bits += "has no 'build/*' rule" }
  if (-not $hasMarker) { $bits += "has no '!build/.gdignore' exception" }
  if ($bits.Count -eq 0) {
    Pass $Area '.gitignore' "build/* plus !build/.gdignore, the form that works"
    return
  }
  Fail $Area '.gitignore' "$(Join-Some $bits). Fix: use exactly 'build/*' then '!build/.gdignore', and delete any bare 'build/' or '!build/' - the bare pair silently re-includes every output file."
}

# 12. The version is one fact. version/code must match across presets and equal the number of
#     entries in the changelog, because that is the only number in the repo that counts
#     releases. Four of five repos sat at 1 while their names climbed past 0.13.0, and Play
#     rejects every upload after the first when it does.
function Test-VersionCode([string] $Area, [string] $Path, [object[]] $Presets) {
  if ($null -eq $Presets -or $Presets.Count -eq 0) {
    Fail $Area 'version/code' "no preset to read version/code from, so nothing was inspected. Fix: see the export guards line."
    return
  }
  $codes = @($Presets | ForEach-Object { $_.VersionCode })
  $absent = @($Presets | Where-Object { $null -eq $_.VersionCode } | ForEach-Object { "preset.$($_.Index)" })
  if ($absent.Count -gt 0) {
    Fail $Area 'version/code' "no version/code in $(Join-Some $absent). Fix: add it to every preset; a Play upload needs a code higher than the last every time."
    return
  }
  $distinct = @($codes | Sort-Object -Unique)
  if ($distinct.Count -ne 1) {
    Fail $Area 'version/code' "presets disagree: $(($Presets | ForEach-Object { "preset.$($_.Index)=$($_.VersionCode)" }) -join ', '). Fix: make every preset carry the same version/code - the AAB preset is the one nobody looks at until the store rejects it."
    return
  }
  $code = $distinct[0]
  $cl = Join-Path $Path 'src\changelog.gd'
  $text = Read-TextFile $cl
  if ($null -eq $text) {
    Fail $Area 'version/code' "version/code=$code, but there is no src\changelog.gd to check it against, so the check inspected nothing. Fix: every game keeps a changelog from the first commit (INDEX.md rule 3)."
    return
  }
  $releases = ([regex]::Matches($text, '(?m)^\s*"version"\s*:')).Count
  if ($releases -eq 0) {
    Fail $Area 'version/code' "src\changelog.gd has no RELEASES entries, so version/code=$code could not be checked. Fix: the changelog's shape changed - update this check in scripts\doctor.ps1 or restore the file's format."
    return
  }
  if ([int]$code -ne $releases) {
    Fail $Area 'version/code' "version/code=$code but the changelog lists $releases release(s). Fix: set version/code=$releases in every preset and bump it by one on every ship (skills\ship\SKILL.md step 2)."
    return
  }
  $names = @($Presets | ForEach-Object { $_.VersionName } | Sort-Object -Unique)
  if ($names.Count -ne 1) {
    Warn $Area 'version/code' "version/code=$code matches $releases release(s), but version/name differs between presets: $($names -join ', ')."
    return
  }
  Pass $Area 'version/code' "$code in every preset, matching $releases changelog release(s) (version/name $($names[0]))"
}

# 13/14. Drift from the template, by name and by content.
#
#   By name (FAIL): the template ships nine scripts and a game is expected to have all of
#   them. This is the single check that would have caught stillwater running a blind check.ps1
#   for three days - not because the file was wrong, but because a game can be missing
#   device.ps1 entirely and nothing anywhere says so.
#
#   By content (WARN): for the scripts a repo DOES share with the template, flag the ones
#   whose text differs, so a fix made in the template and never forward-ported is visible.
#   Advisory on purpose - check_size.gd carries the game's own budget and export_release.bat
#   its own package id, so a diff here is normal and only the reader can tell which kind it
#   is. Whitespace is ignored. .uid files are Godot's per-file import ids and never match.
function Get-TemplateScripts {
  $dir = Join-Path $Template 'scripts'
  if (-not (Test-Path -LiteralPath $dir)) { return $null }
  $files = @(Get-ChildItem -LiteralPath $dir -File | Where-Object { $_.Extension -ne '.uid' })
  if ($files.Count -eq 0) { return @() }
  return $files
}

function Normalize-Text([string] $Text) {
  # Whitespace-insensitive compare: line endings, indentation and trailing space all collapse.
  $t = $Text -replace '\r\n', "`n"
  $t = $t -replace '[ \t]+', ' '
  $t = ($t -split '\n' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }) -join "`n"
  return $t
}

function Test-TemplateScriptSet([string] $Area, [string] $Path, [object[]] $TemplateScripts, [bool] $IsTemplate) {
  if ($IsTemplate) {
    Pass $Area 'template scripts' "this is the template: $($TemplateScripts.Count) script(s) are the reference set"
    return
  }
  $missing = @()
  $shared = @()
  $altGate = $false
  foreach ($t in $TemplateScripts) {
    $mine = Join-Path $Path ('scripts\' + $t.Name)
    if (Test-Path -LiteralPath $mine) { $shared += @{ Name = $t.Name; Mine = $mine; Theirs = $t.FullName } }
    elseif ($t.Name -eq 'check.ps1' -and (Test-Path -LiteralPath (Join-Path $Path 'scripts\check.sh'))) {
      # A bash gate is still a gate. What matters is that the repo HAS one.
      $altGate = $true
    }
    else { $missing += $t.Name }
  }
  if ($missing.Count -gt 0) {
    Fail $Area 'template scripts' "$($shared.Count)/$($TemplateScripts.Count) present; missing $(Join-Some $missing). Fix: copy each from $Template\scripts and adapt it. A game with no check.ps1 has no gate, and a game with no device.ps1 cannot be playtested on the phone at all."
  } elseif ($altGate) {
    Pass $Area 'template scripts' "all $($TemplateScripts.Count) accounted for; this repo gates through scripts\check.sh instead of check.ps1"
  } else {
    Pass $Area 'template scripts' "all $($TemplateScripts.Count) template scripts present"
  }

  if ($Quiet) { return }
  if ($shared.Count -eq 0) {
    Fail $Area 'template drift' 'no script is shared with the template, so no content could be compared. Fix: see the template scripts line above.'
    return
  }
  $differ = @()
  foreach ($s in $shared) {
    $a = Read-TextFile $s.Theirs
    $b = Read-TextFile $s.Mine
    if ($null -eq $a -or $null -eq $b) { $differ += "$($s.Name) (unreadable)"; continue }
    if ((Normalize-Text $a) -cne (Normalize-Text $b)) { $differ += $s.Name }
  }
  if ($differ.Count -eq 0) {
    Pass $Area 'template drift' "$($shared.Count) shared script(s), all identical to the template"
    return
  }
  Warn $Area 'template drift' "differs from $Template\scripts: $(Join-Some $differ 9). Read each: a game may legitimately diverge, but a template fix that was never forward-ported looks exactly the same from here."
}

# 15. The test set the template now guarantees. run_tests.gd must discover suites by globbing
#     the directory, because any list of things to run maintained by hand fails silently in
#     the safe-looking direction - a sibling game added nine suites, did not add them to the
#     array, and the runner reported "65 passing" for a suite that had never run. The three
#     named suites are the gates for the three rules that were written down and still shipped
#     broken: the version (version/code included), the sim wall, and handedness.
function Test-TestSet([string] $Area, [string] $Path) {
  $testDir = Join-Path $Path 'test'
  if (-not (Test-Path -LiteralPath $testDir)) {
    Fail $Area 'test set' "no test\ directory. Fix: INDEX.md rule 3 - golden and smoke suites from the first commit. Copy test\ from $Template."
    return
  }
  $runner = Join-Path $testDir 'run_tests.gd'
  $text = Read-TextFile $runner
  if ($null -eq $text) {
    Fail $Area 'test set' "no test\run_tests.gd. Fix: copy it from $Template\test - without a runner the suites in this repo are never executed."
  } else {
    # The hand-written array is counted in the RAW text on purpose: each entry is a string
    # literal (load("res://test/test_sim.gd")) and stripping strings would erase the very
    # thing being counted. The glob markers are code, so they are read from the stripped text
    # where a comment quoting the old form cannot be mistaken for the old form.
    $clean = Remove-GdCommentsAndStrings $text
    $hand = ([regex]::Matches($text, 'load\("res://test/test_')).Count
    $globbed = [regex]::IsMatch($clean, 'DirAccess\.open') -and [regex]::IsMatch($clean, 'get_files\s*\(')
    if ($globbed -and $hand -eq 0) {
      Pass $Area 'test discovery' 'run_tests.gd globs res://test'
    } elseif ($hand -gt 0) {
      Fail $Area 'test discovery' "run_tests.gd names $hand suite(s) in a hand-written array. Fix: replace it with the glob runner in $Template\test\run_tests.gd, which also fails on an empty glob. A hand-maintained list silently stops running the suites nobody added to it."
    } else {
      Fail $Area 'test discovery' "run_tests.gd neither globs res://test nor names suites, so this check could not tell how suites are found. Fix: read the file; if the discovery changed shape, update this check in scripts\doctor.ps1."
    }
  }
  # test_version.gd and test_sim_boundary.gd are game-independent: they parse
  # export_presets.cfg and scan src/sim, so the template's copies drop straight
  # in and a repo without one is simply ungated. test_controls.gd cannot be
  # copied - it drives THIS game's input handler - so its absence is a WARN
  # with the reason, not a FAIL. Controls have shipped inverted in five games
  # and in the template itself, so the warning is not decoration.
  # Detect each gate by what it asserts, not by the filename it lives in:
  # stillwater keeps its version assertions inside test_assets.gd, and a check
  # that demanded the filename would report a gap that is not there.
  $want = 'test_version.gd', 'test_sim_boundary.gd'
  $probe = @{ 'test_version.gd' = 'version/code'; 'test_sim_boundary.gd' = 'src/sim' }
  $suiteText = ''
  foreach ($sf in @(Get-ChildItem -LiteralPath $testDir -Filter 'test_*.gd' -File -ErrorAction SilentlyContinue)) {
    $st = Read-TextFile $sf.FullName
    if ($null -ne $st) { $suiteText += "`n" + $st }
  }
  $missing = @($want | Where-Object {
    if (Test-Path -LiteralPath (Join-Path $testDir $_)) { return $false }
    $needle = $probe[$_]
    return -not ($suiteText -match [regex]::Escape($needle))
  })
  $notes = @()
  $tv = Join-Path $testDir 'test_version.gd'
  if (Test-Path -LiteralPath $tv) {
    $tvText = Read-TextFile $tv
    if ($null -ne $tvText -and -not [regex]::IsMatch($tvText, 'version/code')) {
      $notes += 'test_version.gd never mentions version/code'
    }
  }
  # Detect the controls gate by what it DOES, not by its filename: wildform's
  # lives in run_smoke.gd and is a real gate. What makes it a gate is driving a
  # real InputEventScreenDrag or InputEventScreenTouch through the game's own
  # handler - a policy that calls steer_to() is not a test of the control, which
  # is the sentence this studio has now paid for six times.
  $hasControls = $false
  foreach ($tf in @(Get-ChildItem -LiteralPath $testDir -Filter '*.gd' -File -ErrorAction SilentlyContinue)) {
    $tt = Read-TextFile $tf.FullName
    if ($null -ne $tt -and $tt -match 'InputEventScreen(Drag|Touch)') { $hasControls = $true; break }
  }
  if ($missing.Count -eq 0 -and $notes.Count -eq 0) {
    Pass $Area 'test set' 'test_version.gd and test_sim_boundary.gd present'
  } else {
    $bits = @()
    if ($missing.Count -gt 0) { $bits += "missing $(Join-Some $missing)" }
    $bits += $notes
    Fail $Area 'test set' "$($bits -join '; '). Fix: copy them from $Template\test - both are game-independent. They gate the version code and the sim wall, two rules this studio wrote down and shipped broken anyway."
  }
  if (-not $hasControls) {
    Warn $Area 'controls gate' "no test/test_controls.gd. It cannot be copied - it has to drive THIS game's input handler - so write it from $Template\test\test_controls.gd: a real InputEventScreenDrag through the real handler, asserting where the avatar lands ON SCREEN. Controls have shipped inverted in five games and in the template itself, every time with the rule already written down."
  }
}

# 16. The sim wall, as a text scan, across every repo. INDEX.md rule 2 is the invariant that
#     makes the golden test, the headless harness and any rewrite possible. godot-template's
#     test_sim_boundary.gd is the real gate and runs inside the repo that has it; this is the
#     sweep for the repos that do not have it yet.
#
#     Comments and string literals are stripped first. This is not a nicety: every sim file in
#     this studio carries a header that names the forbidden things in order to forbid them,
#     and a naive grep reports thirty of those headers and zero bugs.
function Test-SimPurity([string] $Area, [string] $Path) {
  $simDir = Join-Path $Path 'src\sim'
  if (-not (Test-Path -LiteralPath $simDir)) {
    Fail $Area 'sim wall' "no src\sim\ directory. Fix: INDEX.md rule 2 - a pure simulation core with no renderer in it. Without one there is no golden test and no headless harness."
    return
  }
  $files = @(Get-ChildItem -LiteralPath $simDir -Filter '*.gd' -File -Recurse)
  if ($files.Count -eq 0) {
    Fail $Area 'sim wall' "src\sim\ holds no .gd files, so this check inspected nothing. Fix: either the simulation moved, or this repo has no sim core - both need looking at."
    return
  }
  $banned = @(
    @{ Name = 'extends Node';       Pattern = '(?m)^\s*extends\s+Node\w*\s*$' },
    @{ Name = 'Node3D';             Pattern = '\bNode3D\b' },
    @{ Name = 'Viewport';           Pattern = '\b\w*Viewport\w*\b' },
    @{ Name = 'InputEvent';         Pattern = '\bInputEvent\w*' },
    @{ Name = 'get_tree(';          Pattern = '\bget_tree\s*\(' },
    @{ Name = 'get_node(';          Pattern = '\bget_node\s*\(' },
    @{ Name = '_process(';          Pattern = '\b_process\s*\(' },
    @{ Name = '_physics_process(';  Pattern = '\b_physics_process\s*\(' },
    @{ Name = 'await';              Pattern = '\bawait\s' },
    @{ Name = 'randf(';             Pattern = '\brandf(_range)?\s*\(' },
    @{ Name = 'randi(';             Pattern = '\brandi(_range)?\s*\(' },
    @{ Name = 'Input.';             Pattern = '\bInput\.' }
  )
  $hits = @()
  foreach ($f in $files) {
    $raw = Read-TextFile $f.FullName
    if ($null -eq $raw) { $hits += "$($f.Name) (unreadable)"; continue }
    $clean = Remove-GdCommentsAndStrings $raw
    foreach ($b in $banned) {
      foreach ($m in [regex]::Matches($clean, $b.Pattern)) {
        $line = Get-LineNumber $clean $m.Index
        $hits += "src\sim\$($f.Name):$line $($b.Name)"
      }
    }
  }
  if ($hits.Count -eq 0) {
    Pass $Area 'sim wall' "$($files.Count) sim file(s), no engine reference (comments and strings stripped)"
    return
  }
  Fail $Area 'sim wall' "$($hits.Count) engine reference(s) inside src\sim: $(Join-Some $hits 6). Fix: move the offending call into src\game\ and pass the result in. INDEX.md rule 2; seeded randomness goes through SimRng or SimUtil.hash2."
}

# 17. Git hygiene. Cheap calls only: status, one rev-list against the LAST KNOWN remote, and
#     count-objects. Nothing here fetches, so "ahead" means ahead of the last fetch - which is
#     the same caveat that makes setup\finish.ps1 report nothing to push on a repo that is
#     behind. Pack size is here because gravewell carries 1.72 GB of dead objects from one
#     `git add -A`, and every clone and every CI checkout pulls all of it.
function Test-GitHygiene([string] $Area, [string] $Path) {
  if (-not (Test-Path -LiteralPath (Join-Path $Path '.git'))) {
    Fail $Area 'git' "not a git repository. Fix: INDEX.md rule 3 - git and a GitHub repo from the first commit."
    return
  }
  $status = Native { git -C $Path status --porcelain 2>$null }
  if ($LASTEXITCODE -ne 0) {
    Fail $Area 'git' "git status failed here. Fix: open $Path and find out why before trusting anything else in this report."
    return
  }
  $dirty = @(@($status) | Where-Object { $_ -and $_.Trim() -ne '' })
  $ahead = $null
  $revs = Native { git -C $Path rev-list --count "@{u}..HEAD" 2>$null }
  $revText = ($revs -join '').Trim()
  if ($LASTEXITCODE -eq 0 -and $revText -match '^\d+$') { $ahead = [int]$revText }

  $bits = @()
  if ($dirty.Count -gt 0) {
    $untracked = @($dirty | Where-Object { $_.StartsWith('??') }).Count
    $bits += "$($dirty.Count) uncommitted change(s) ($untracked untracked)"
  }
  if ($null -eq $ahead) { $bits += 'no upstream branch set' }
  elseif ($ahead -gt 0) { $bits += "$ahead commit(s) not pushed (as of the last fetch)" }

  if ($bits.Count -gt 0) {
    Warn $Area 'git' "$($bits -join '; '). CI has never seen any of it. Commit and push, or say in NOTES.md why not."
  } else {
    Pass $Area 'git' 'clean and pushed'
  }

  $counts = Native { git -C $Path count-objects -v 2>$null }
  if ($LASTEXITCODE -ne 0) {
    Fail $Area 'git size' "git count-objects failed. Fix: check $Path\.git."
    return
  }
  $kib = 0
  foreach ($l in @($counts)) {
    $m = [regex]::Match([string]$l, '^(size|size-pack):\s*(\d+)')
    if ($m.Success) { $kib += [long]$m.Groups[2].Value }
  }
  $bytes = $kib * 1024
  if ($bytes -gt 200MB) {
    Warn $Area 'git size' "$(Format-Kb $bytes) of objects in .git. Every clone and every CI checkout pulls all of it. Fix: find what is in the pack (git count-objects -vH, git rev-list --objects --all), then rewrite the history or start a fresh repo."
  } else {
    Pass $Area 'git size' "$(Format-Kb $bytes) of objects in .git"
  }
}

# ══ Web repos ═════════════════════════════════════════════════════════════════

# 18. A web game has a gate and a port of its own.
#
#     The gate: `npm run check` is the web equivalent of scripts\check.ps1, and a web session
#     that cannot find one has no gate at all - skills\game-studio\SKILL.md used to send a web
#     session to a check.ps1 that coreward does not have.
#
#     The ports: three files carry one, and the scaffold used to rewrite exactly one of them,
#     so a new game filmed on the old game's port and Playwright happily reused a dev server
#     serving a different repo's app. Comments are stripped before the numbers are read,
#     because coreward's playwright.config.ts explains at length why it is NOT on 4173, 4200
#     or 5173, and those are the numbers a naive scan finds.
$WEBPORTFILES = 'playwright.config.ts', '.claude\launch.json', 'scripts\filmstrip.mjs'
$VITEDEFAULTS = 5173, 4173, 4200, 3000

function Get-PortsFromFile([string] $Path) {
  $t = Read-TextFile $Path
  if ($null -eq $t) { return $null }
  $clean = Remove-JsComments $t
  $found = @()
  foreach ($rx in '(?i)port\W{0,20}?(\d{4,5})\b', '(?i)(?:localhost|127\.0\.0\.1|\[::1\])\s*:\s*(\d{4,5})\b') {
    foreach ($m in [regex]::Matches($clean, $rx)) {
      $n = [int]$m.Groups[1].Value
      if ($n -ge 1024 -and $n -le 65535 -and $found -notcontains $n) { $found += $n }
    }
  }
  return ,@($found | Sort-Object)
}

function Test-WebRepos {
  $area = 'Web repos'
  if (-not (Test-Path -LiteralPath $Root)) { return }
  $webs = @(Get-ChildItem -LiteralPath $Root -Directory | Where-Object {
    (Test-Path -LiteralPath (Join-Path $_.FullName 'package.json')) -and (Test-Path -LiteralPath (Join-Path $_.FullName 'vite.config.js'))
  })
  if (-not $IncludeSnapshots) { $webs = @($webs | Where-Object { $_.Name -notmatch '(?i)(\.pre-fix|\.bak|\.old|-audit)$' }) }
  if ($Repo) { $webs = @($webs | Where-Object { $_.Name -eq $Repo }) }
  if ($webs.Count -eq 0) {
    if ($Repo) { return }
    Fail $area 'discovery' "no directory under $Root has both a package.json and a vite.config.js, so every web check below inspected nothing. Fix: if there really is no web game, delete this check; if there is, the detection in scripts\doctor.ps1 is looking for the wrong pair of files."
    return
  }

  $portOwners = @{}
  foreach ($w in $webs) {
    $name = $w.Name
    $pkgPath = Join-Path $w.FullName 'package.json'
    $pkgText = Read-TextFile $pkgPath
    if ($null -eq $pkgText) {
      Fail $area "$name / gate" "could not read package.json. Fix: check the file."
    } else {
      $hasCheck = $false
      try {
        $pkg = $pkgText | ConvertFrom-Json
        if ($pkg.scripts) { $hasCheck = @($pkg.scripts.PSObject.Properties.Name) -contains 'check' }
      } catch {
        Fail $area "$name / gate" "package.json is not valid JSON: $($_.Exception.Message). Fix: repair it; npm cannot read it either."
      }
      if ($hasCheck) {
        Pass $area "$name / gate" "npm run check is defined"
      } else {
        Fail $area "$name / gate" "no 'check' script in package.json. Fix: add one that runs the whole gate (typecheck, unit, e2e, size) - it is the web equivalent of scripts\check.ps1, and without it a web session has no gate to be green."
      }
    }

    foreach ($rel in $WEBPORTFILES) {
      $p = Join-Path $w.FullName $rel
      if (-not (Test-Path -LiteralPath $p)) {
        Fail $area "$name / ports" "no $rel, so its port could not be checked. Fix: copy it from the web source repo; a missing one is a port nobody rewrote at scaffold time."
        continue
      }
      $ports = Get-PortsFromFile $p
      if ($null -eq $ports -or $ports.Count -eq 0) {
        Fail $area "$name / ports" "$rel names no port at all, so nothing was inspected. Fix: read the file - either it stopped configuring a port, or the pattern in scripts\doctor.ps1 no longer matches how it does."
        continue
      }
      foreach ($n in $ports) {
        $key = [string]$n
        if (-not $portOwners.ContainsKey($key)) { $portOwners[$key] = @() }
        $portOwners[$key] += "$name/$rel"
      }
    }
  }

  $collisions = @()
  $defaults = @()
  foreach ($k in ($portOwners.Keys | Sort-Object)) {
    $owners = @($portOwners[$k])
    $repos = @($owners | ForEach-Object { $_.Split('/')[0] } | Sort-Object -Unique)
    if ($repos.Count -gt 1) { $collisions += "$k used by $($repos -join ' and ') ($(Join-Some $owners 4))" }
    if ($VITEDEFAULTS -contains [int]$k) { $defaults += "$k ($(Join-Some $owners 3))" }
  }
  if ($collisions.Count -gt 0) {
    Fail $area 'port collisions' "$(Join-Some $collisions 4). Fix: give each game its own port in all three files. Two repos on one port means Playwright reuses a dev server that is serving the other game, and the failure it reports is about the test, not the port."
  } elseif ($portOwners.Count -eq 0) {
    Fail $area 'port collisions' 'no port was read from any web repo, so the collision check inspected nothing. Fix: see the per-file lines above.'
  } else {
    Pass $area 'port collisions' "$($portOwners.Count) distinct port(s) across $($webs.Count) web repo(s), none shared"
  }
  if ($defaults.Count -gt 0) {
    Warn $area 'default ports' "on a Vite/preview default: $(Join-Some $defaults 4). A second web game scaffolded tomorrow takes the same one. Move it to a per-game number."
  }
}

# ══ Driver and report ═════════════════════════════════════════════════════════

function Test-GameRepo([object] $Dir, [object[]] $TemplateScripts) {
  $path = $Dir.FullName
  # -Template may point at a worktree (godot-template-audit) while the live
  # godot-template is also enumerated. Both are the template for these checks.
  $isTemplate = ($Dir.Name -eq (Split-Path $Template -Leaf)) -or ($Dir.Name -like 'godot-template*')
  $area = "Game: $($Dir.Name)"
  $presetPath = Join-Path $path 'export_presets.cfg'
  $presets = $null
  if (Test-Path -LiteralPath $presetPath) {
    $presets = Get-ExportPresets $presetPath
  } else {
    Fail $area 'export_presets.cfg' "not found. Fix: copy it from $Template and set the package id and version - a repo without one cannot produce an APK at all."
  }
  Test-RequiredFiles $area $path $isTemplate
  Test-ExportGuards  $area $path $presets
  Test-GitignoreForm $area $path
  Test-VersionCode   $area $path $presets
  if ($null -ne $TemplateScripts) { Test-TemplateScriptSet $area $path $TemplateScripts $isTemplate }
  Test-TestSet       $area $path
  if (-not $Quiet) {
    Test-SimPurity   $area $path
    Test-GitHygiene  $area $path
  }
}

function Write-Report {
  $lastArea = $null
  foreach ($r in $script:Results) {
    if ($Quiet -and $r.Status -eq 'PASS') { continue }
    if ($r.Area -ne $lastArea) {
      Write-Host ''
      Write-Host "== $($r.Area) ==" -ForegroundColor Cyan
      $lastArea = $r.Area
    }
    $colour = switch ($r.Status) { 'PASS' { 'Green' } 'WARN' { 'Yellow' } default { 'Red' } }
    Write-Host ("  {0,-4}  {1,-20} {2}" -f $r.Status, $r.Name, $r.Detail) -ForegroundColor $colour
  }

  $pass = @($script:Results | Where-Object { $_.Status -eq 'PASS' }).Count
  $warn = @($script:Results | Where-Object { $_.Status -eq 'WARN' }).Count
  $fail = @($script:Results | Where-Object { $_.Status -eq 'FAIL' }).Count

  Write-Host ''
  Write-Host '== Summary ==' -ForegroundColor Cyan
  Write-Host ("  {0} pass, {1} warn, {2} fail" -f $pass, $warn, $fail) -ForegroundColor $(if ($fail) { 'Red' } elseif ($warn) { 'Yellow' } else { 'Green' })
  if ($script:Skipped.Count -gt 0) {
    Write-Host "  skipped as snapshots or worktrees: $(Join-Some ($script:Skipped.ToArray()) 8) (-IncludeSnapshots to check them)"
  }
  if ($Quiet) {
    Write-Host '  -Quiet: cross-references, template content drift, sim purity and git hygiene were not run. Run without -Quiet before shipping.'
  }
  if ($script:Fixed.Count -gt 0) {
    Write-Host '  fixed:' -ForegroundColor Green
    foreach ($f in $script:Fixed) { Write-Host "    $f" -ForegroundColor Green }
  }
  if ($fail -gt 0) {
    Write-Host '  Every FAIL line above ends with the fix. Do them, then run this again.' -ForegroundColor Red
  } elseif ($warn -gt 0) {
    Write-Host '  Nothing is broken. The WARN lines are the ones that become FAILs if left.' -ForegroundColor Yellow
  } else {
    Write-Host '  The framework holds.' -ForegroundColor Green
  }
  return $fail
}

# ── Run ───────────────────────────────────────────────────────────────────────

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Host 'git is not on PATH, so the digest-age and git-hygiene checks cannot run.' -ForegroundColor Red
  Write-Host 'Fix: install git, or start a new shell - a session older than the install does not see the user PATH.' -ForegroundColor Red
  exit 1
}
if (-not $Quiet) {
  Write-Host "doctor: $Notes, games under $Root, template $Template" -ForegroundColor DarkGray
}

$repos = @(Get-GameRepos)
# The cross-reference check resolves bare script names against the game repos, so the list
# has to exist before the knowledge-base checks run.
$script:GameRepoPaths = @($repos | ForEach-Object { $_.FullName })

Test-KnowledgeBase

$templateScripts = Get-TemplateScripts
if ($null -eq $templateScripts) {
  Fail 'Game repos' 'template' "no $Template\scripts directory, so no repo could be compared against the template. Fix: pass -Template <path>, or restore the template - every drift check below depends on it."
  $templateScripts = $null
} elseif ($templateScripts.Count -eq 0) {
  Fail 'Game repos' 'template' "$Template\scripts is empty, so the drift checks would have compared each repo against nothing and passed. Fix: restore the template's scripts."
  $templateScripts = $null
}

foreach ($d in $repos) { Test-GameRepo $d $templateScripts }

Test-WebRepos

$failures = Write-Report
if ($failures -gt 0) { exit 1 }
exit 0
