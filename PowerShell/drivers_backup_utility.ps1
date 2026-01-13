<#
.SYNOPSIS
    Smart Windows Drivers Backup Utility (USB Ready)
    Author: pitt.plusmagi.com pitt.plusmagi.com
#>

# 1. Check for Administrator Rights
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 2. Detect Script Location (USB Path)
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$usbBackupPath = Join-Path -Path $scriptPath -ChildPath "Drivers_Backup"
$cBackupPath = "C:\portables\Drivers_Backup"

Clear-Host
$title = @"
====================================================
       POWERSHELL DRIVERS BACKUP UTILITY
       Author: pitt.plusmagi.com (pitt.plusmagi.com)
====================================================
"@
Write-Host $title -ForegroundColor Cyan

# 3. Choose Destination
Write-Host "Select Destination Path:" -ForegroundColor White
Write-Host "[1] USB Drive  : $usbBackupPath"
Write-Host "[2] System C:  : $cBackupPath"
$choice = Read-Host "`nSelect [1] or [2] (Default is 1)"

$targetPath = if ($choice -eq "2") { $cBackupPath } else { $usbBackupPath }

# 4. Initialize Note File
if (-not (Test-Path $targetPath)) { New-Item -ItemType Directory -Path $targetPath -Force | Out-Null }
$timestamp = Get-Date -Format "yyyy-MM-ddTHHmm"
$noteFile = Join-Path -Path $targetPath -ChildPath "note_$($timestamp).txt"
"Driver Backup Log - $(Get-Date)`r`nAuthor: pitt.plusmagi.com (pitt.plusmagi.com)`r`n" + ("="*60) | Out-File $noteFile -Encoding UTF8

# 5. Backup Process
Write-Host "`nTarget: $targetPath" -ForegroundColor Yellow
$allDrivers = Get-WindowsDriver -Online | Where-Object { $_.Inbox -eq $false }

foreach ($d in $allDrivers) {
    $categoryPath = Join-Path -Path $targetPath -ChildPath $d.ClassName
    $infFolder = Split-Path (Split-Path $d.OriginalFileName -Parent) -Leaf
    $specificBackupPath = Join-Path -Path $categoryPath -ChildPath $infFolder

    if (Test-Path $specificBackupPath) {
        Write-Host "Skipping: [$($d.ClassName)] $($d.Driver) (Already exists)" -ForegroundColor Gray
    } else {
        Write-Host "Backing up: [$($d.ClassName)] $($d.Driver) ..." -ForegroundColor Green
        if (-not (Test-Path $specificBackupPath)) { New-Item -ItemType Directory -Path $specificBackupPath -Force | Out-Null }
        pnputil.exe /export-driver $($d.Driver) "$specificBackupPath" | Out-Null
    }

    $details = "`r`nDriver: $($d.Driver)`r`nClassName: $($d.ClassName)`r`nVersion: $($d.Version)`r`nPath: $specificBackupPath`r`n" + ("-"*46)
    $details | Out-File $noteFile -Append -Encoding UTF8
}

Write-Host "`nBackup Completed!" -ForegroundColor Cyan
explorer.exe $targetPath
Pause
