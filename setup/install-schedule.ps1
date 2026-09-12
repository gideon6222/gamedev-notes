<#
.SYNOPSIS
  Register (or remove) the Windows scheduled task that runs scripts\weekly-check.ps1.
  Zero Claude tokens: it is PowerShell on Task Scheduler. Sundays at 18:00 local by default,
  and it also runs if the PC was off at that time, as soon as it is next awake.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File C:\dev\gamedev-notes\setup\install-schedule.ps1
  powershell -ExecutionPolicy Bypass -File C:\dev\gamedev-notes\setup\install-schedule.ps1 -Day Sunday -At 18:00
  powershell -ExecutionPolicy Bypass -File C:\dev\gamedev-notes\setup\install-schedule.ps1 -Remove
  powershell -ExecutionPolicy Bypass -File C:\dev\gamedev-notes\setup\install-schedule.ps1 -RunNow
#>
[CmdletBinding()]
param(
  [string] $TaskName = 'gamedev-notes weekly check',
  [ValidateSet('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday')] [string] $Day = 'Sunday',
  [string] $At = '18:00',
  [switch] $Remove,
  [switch] $RunNow
)
$ErrorActionPreference = 'Stop'
$notes = Split-Path $PSScriptRoot -Parent
if (-not $notes) { $notes = Split-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) -Parent }
$script = Join-Path $notes 'scripts\weekly-check.ps1'

if ($Remove) {
  if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    Write-Host "removed scheduled task '$TaskName'"
  } else { Write-Host "no scheduled task named '$TaskName'" }
  exit 0
}
if (-not (Test-Path -LiteralPath $script)) { throw "not found: $script" }

$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$script`""
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $Day -At $At
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 20) -MultipleInstances IgnoreNew
Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Description "Runs C:\dev\gamedev-notes\scripts\doctor.ps1 and writes reports\LATEST.txt. No Claude involved." -Force | Out-Null
$t = Get-ScheduledTask -TaskName $TaskName
Write-Host "registered '$TaskName': every $Day at $At, runs $script"
Write-Host "next run: $((Get-ScheduledTaskInfo -TaskName $TaskName).NextRunTime)"
if ($RunNow) {
  Start-ScheduledTask -TaskName $TaskName
  Write-Host "started it now; reports\LATEST.txt will appear in under a minute"
}
