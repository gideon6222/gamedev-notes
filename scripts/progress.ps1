# Prints where a game's PLAN.md stands: milestones done, and which phases still have work.
# Used by a build session at a stopping point and by /ship, so Gideon can judge pace without
# opening PLAN.md or the dashboard. Reads checkboxes only - it changes nothing and spends no
# tokens (ADMIN.md "What runs when").
param(
  [string]$Plan = '.\PLAN.md',
  [string]$Phase = ''
)

function Read-TextFile([string] $Path) {
  # ReadAllText, never Get-Content: Get-Content splits on line endings and hands back an
  # array, and this repo's games are LF-only by .gitattributes.
  try { return [System.IO.File]::ReadAllText($Path) } catch { return $null }
}

function Clip([string] $Text, [int] $Max) {
  if ($Text.Length -gt $Max) { return $Text.Substring(0, $Max) }
  return $Text
}

$fullPlan = [System.IO.Path]::GetFullPath($Plan)

if (-not (Test-Path -LiteralPath $fullPlan)) {
  Write-Host "PLAN.md not found at $fullPlan; the doctor's required-files line covers this"
  exit 2
}

$text = Read-TextFile $fullPlan
$lines = @($text -split '\r?\n')

# Same regex as scripts\doctor.ps1 Test-PlanOutline (the "16. The plan is an outline" check),
# and it must stay identical - a change to one is a change to both (ADMIN.md).
$milestoneRegex = '^\s*[-*]\s+\[[ xX]\]\s+\S'
$milestoneCapture = '^\s*[-*]\s+\[([ xX])\]\s+(.*)$'
$headingRegex = '^#{2,4}\s+(.*)$'

$phases = New-Object System.Collections.Generic.List[object]
$phaseIndex = @{}
$currentTitle = ''

foreach ($line in $lines) {
  if ($line -match $headingRegex) {
    $currentTitle = $Matches[1].TrimEnd()
    continue
  }
  if ($line -notmatch $milestoneRegex) { continue }
  $ticked = $false
  $title = ''
  if ($line -match $milestoneCapture) {
    $checkChar = $Matches[1]
    $title = $Matches[2].Trim()
    $ticked = ($checkChar -eq 'x' -or $checkChar -eq 'X')
  }
  # Headings with no boxes under them never reach here, so they never enter $phaseIndex -
  # that is what "ignored" means, with no separate skip logic needed.
  if (-not $phaseIndex.ContainsKey($currentTitle)) {
    $obj = [pscustomobject]@{ Title = $currentTitle; Done = 0; Total = 0; FirstUnticked = $null }
    $phaseIndex[$currentTitle] = $obj
    $phases.Add($obj)
  }
  $p = $phaseIndex[$currentTitle]
  $p.Total++
  if ($ticked) {
    $p.Done++
  } elseif ($null -eq $p.FirstUnticked) {
    $p.FirstUnticked = $title
  }
}

$totalMilestones = 0
$doneMilestones = 0
foreach ($p in $phases) { $totalMilestones += $p.Total; $doneMilestones += $p.Done }

if ($totalMilestones -eq 0) {
  Write-Host "PLAN.md has no '- [ ]' milestone lines, so progress cannot be measured; see doctor 'plan outline'"
  exit 3
}

$remaining = $totalMilestones - $doneMilestones
$pct = [math]::Round(($doneMilestones / $totalMilestones) * 100)
$repoName = Split-Path (Split-Path $fullPlan -Parent) -Leaf

$incomplete = @($phases | Where-Object { $_.Total -gt $_.Done })
$active = @()
$rest = $incomplete
if ($Phase -ne '') {
  $active = @($incomplete | Where-Object { $_.Title.IndexOf($Phase, [System.StringComparison]::OrdinalIgnoreCase) -ge 0 })
  $rest = @($incomplete | Where-Object { $_.Title.IndexOf($Phase, [System.StringComparison]::OrdinalIgnoreCase) -lt 0 })
}
$ordered = @($active + $rest)

$out = New-Object System.Collections.Generic.List[string]
$out.Add("PLAN ${repoName}: $doneMilestones of $totalMilestones milestones done ($pct%), $remaining left across $($incomplete.Count) phases")

$shown = $ordered
$more = 0
if ($ordered.Count -gt 6) {
  $shown = $ordered[0..5]
  $more = $ordered.Count - 6
}

foreach ($p in $shown) {
  $marker = ''
  if ($active -contains $p) { $marker = ' <- active' }
  $line = "  $(Clip $p.Title 40)  $($p.Done)/$($p.Total)  next: $(Clip $p.FirstUnticked 60)$marker"
  $out.Add($line)
}
if ($more -gt 0) {
  $out.Add("  ... and $more more phases")
}

$finishedPhases = @($phases | Where-Object { $_.Done -eq $_.Total }).Count
$out.Add("  Finished: $finishedPhases of $($phases.Count) phases")

$out | Select-Object -First 10 | ForEach-Object { Write-Host $_ }
exit 0
