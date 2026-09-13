<#
.SYNOPSIS
  The one phone, claimed before it is used (C:\dev\.phone-lease).

.DESCRIPTION
  There is one Galaxy S26 Ultra and several Claude Code sessions running at once. Two
  sessions installing, filming or reading logcat on it at the same time overwrite each
  other's build and each other's evidence, and the failure looks like a bug in whichever
  game read the log second. So the phone is taken before it is used and given back after.

  Actions:
    claim    -Owner <slug> [-Minutes 20]; takes the phone. Exit 0 when it is yours (a fresh
             claim, your own claim renewed, or a takeover of an expired lease). Exit 75 when
             another game holds it - that is not an error to retry, it is an answer: get on
             with the desk work and record the phone test as owed.
    release  -Owner <slug>; gives it back. Refuses, without failing, if the lease is
             somebody else's.
    status   prints the holder and the expiry, or 'free'.

  The lease file is the fixed path C:\dev\.phone-lease. Fixed and outside every repository
  on purpose: it can never be staged or pushed the way a file inside a repo can, and a
  worktree, a game repo and the main clone all agree on where it is, which a path derived
  from git does not (`git rev-parse --absolute-git-dir` answers differently in each).

  Exit 75 is EX_TEMPFAIL: the request was fine, the resource was busy. `scripts\device.ps1`
  in each game passes it straight through, so a caller can tell "phone busy" from "phone not
  plugged in" (which is a throw) without reading the text.

.EXAMPLE
  scripts\phone.ps1 claim -Owner gravewell
  scripts\phone.ps1 claim -Owner gravewell -Minutes 60   # a live logcat blocks for a while
  scripts\phone.ps1 status
  scripts\phone.ps1 release -Owner gravewell
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory, Position = 0)] [ValidateSet('claim', 'release', 'status')] [string] $Action,
  [string] $Owner = "$env:USERNAME@$env:COMPUTERNAME",
  [int] $Minutes = 20
)
$ErrorActionPreference = 'Stop'

$LeasePath = 'C:\dev\.phone-lease'

# How long a claim is worth when the lease file does not say. Every command renews, so 20
# minutes covers an install, a launch, a 30 s film and a perf run with room to spare, and a
# session killed mid-pass frees the phone inside twenty minutes rather than for the day.
$DefaultMinutes = 20

function Get-Body {
  "owner=$Owner`nacquired=$([datetimeoffset]::UtcNow.ToString('o'))`npid=$PID`nminutes=$Minutes`n"
}

function Write-Body([string] $Text) {
  [System.IO.File]::WriteAllText($LeasePath, $Text, (New-Object System.Text.UTF8Encoding($false)))
}

# CreateNew is the whole arbitration: the filesystem decides, so two claims that land in the
# same millisecond cannot both come back a winner. Test-Path then write would let both pass
# the test before either wrote.
function New-LeaseFile {
  try {
    $fs = [System.IO.File]::Open($LeasePath, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
  } catch [System.IO.IOException] {
    return $false
  }
  try {
    $bytes = (New-Object System.Text.UTF8Encoding($false)).GetBytes((Get-Body))
    $fs.Write($bytes, 0, $bytes.Length)
  } finally { $fs.Dispose() }
  return $true
}

function Read-Lease {
  try { return [System.IO.File]::ReadAllText($LeasePath) } catch { return $null }
}

function Get-Field([string] $Text, [string] $Name) {
  if (-not $Text) { return $null }
  $m = [regex]::Match($Text, "(?m)^$Name=(.+)$")
  if ($m.Success) { return $m.Groups[1].Value.Trim() }
  return $null
}

function Get-Acquired([string] $Text) {
  $raw = Get-Field $Text 'acquired'
  if (-not $raw) { return $null }
  try { return [datetimeoffset]::Parse($raw, [cultureinfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind) } catch { return $null }
}

function Get-Minutes([string] $Text) {
  $raw = Get-Field $Text 'minutes'
  $n = 0
  if ($raw -and [int]::TryParse($raw, [ref] $n) -and $n -gt 0) { return $n }
  return $DefaultMinutes
}

function Show-Lease([string] $Text) {
  if (-not $Text) { return }
  $Text.TrimEnd() -split "`n" | ForEach-Object { Write-Host "    $_" }
}

function Grant([string] $Note) {
  Write-Host "phone claimed by $Owner (pid $PID), good for $Minutes minutes$Note"
  exit 0
}

switch ($Action) {
  'status' {
    $held = Read-Lease
    if (-not $held) { Write-Host 'phone is free'; exit 0 }
    $acquired = Get-Acquired $held
    Show-Lease $held
    if ($null -eq $acquired) {
      Write-Host '    (no readable acquired stamp, so the next claim takes it over)'
    } else {
      $expires = $acquired.AddMinutes((Get-Minutes $held))
      $left = [int]($expires - [datetimeoffset]::UtcNow).TotalMinutes
      if ($expires -gt [datetimeoffset]::UtcNow) {
        Write-Host "    expires $($expires.ToUniversalTime().ToString('o')) (in $left min)"
      } else {
        Write-Host "    expired $($expires.ToUniversalTime().ToString('o')), so the next claim takes it over"
      }
    }
    exit 0
  }
  'claim' {
    if (New-LeaseFile) { Grant '' }
    # The winner of that race holds the file open and unwritten for an instant, so a loser
    # that reads it straight away sees an empty file or a sharing violation. EMPTY IS NOT
    # CORRUPT: read it as corrupt and the loser "takes over" the lease the winner is still
    # writing, and both sessions walk off believing they have the phone. Measured: with two
    # shells started together, that was the outcome of the FIRST round of ten, every time.
    # So wait for the owner line to appear before drawing any conclusion from its absence.
    $held = $null
    for ($i = 0; $i -lt 20; $i++) {
      $held = Read-Lease
      if ($held -and (Get-Field $held 'owner')) { break }
      # The holder may also have released it in the gap; then the phone is simply free.
      if (-not (Test-Path -LiteralPath $LeasePath)) {
        if (New-LeaseFile) { Grant '' }
      }
      Start-Sleep -Milliseconds 50
    }
    $holder = Get-Field $held 'owner'
    $acquired = Get-Acquired $held
    if ($null -eq $acquired) {
      # No readable stamp after all that. The filesystem's own timestamp is the next best
      # thing, and it keeps the two cases apart: a file written seconds ago is a claim in
      # flight, one from this morning is a leftover to take over.
      try { $acquired = [datetimeoffset]([System.IO.File]::GetLastWriteTimeUtc($LeasePath)) } catch { $acquired = $null }
    }
    if ($holder -and $holder -eq $Owner) {
      Write-Body (Get-Body)
      Write-Host "phone still claimed by $Owner (renewed, good for $Minutes more minutes)"
      exit 0
    }
    # One word, first, so a caller that reads the holder out of this line (each game's
    # scripts\device.ps1 does, for the NOTES.md debt line) gets a name and not a sentence.
    $who = if ($holder) { $holder } else { 'unknown (the lease file has no owner line)' }
    if ($null -ne $acquired) {
      $expires = $acquired.AddMinutes((Get-Minutes $held))
      if ($expires -gt [datetimeoffset]::UtcNow) {
        $since = $acquired.ToUniversalTime().ToString('u')
        $until = $expires.ToUniversalTime().ToString('u')
        Write-Host "phone busy: held by $who since $since, expires $until" -ForegroundColor Yellow
        Write-Host "  Do not wait for it. Finish the desk pass, record the phone test as owed, and try again later."
        exit 75
      }
      Write-Host "taking the phone over: the lease held by $who expired $($expires.ToUniversalTime().ToString('u'))" -ForegroundColor Yellow
    } else {
      Write-Host "taking the phone over: no stamp in the lease file and no timestamp on it either" -ForegroundColor Yellow
    }
    Show-Lease $held
    # A takeover is a plain overwrite, not a CreateNew, so two sessions taking over the same
    # expired lease in the same instant would both believe they won. That race is already
    # degenerate (the previous holder is gone and both are entitled to the phone) and the
    # notice above is printed either way, which is what makes it visible.
    Write-Body (Get-Body)
    Grant ''
  }
  'release' {
    $held = Read-Lease
    if (-not $held) { Write-Host 'no phone lease to release'; exit 0 }
    $holder = Get-Field $held 'owner'
    if ($holder -and $holder -ne $Owner) {
      Write-Host "not yours: the phone is held by $holder, not $Owner. Left alone." -ForegroundColor Yellow
      exit 0
    }
    Remove-Item -LiteralPath $LeasePath -Force
    Write-Host "phone released by $Owner"
    exit 0
  }
}
