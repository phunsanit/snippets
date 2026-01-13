<#
.SYNOPSIS
    Interactive Windows Drivers Restore Utility (USB Ready)
    Author: pitt.plusmagi.com (pitt.plusmagi.com)
#>

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$usbBackupPath = Join-Path -Path $scriptPath -ChildPath "Drivers_Backup"
$cBackupPath = "C:\portables\Drivers_Backup"

Clear-Host
$title = @"
====================================================
      POWERSHELL DRIVERS RESTORE UTILITY
       Author: pitt.plusmagi.com (pitt.plusmagi.com)
====================================================
"@
Write-Host $title -ForegroundColor Cyan

Write-Host "Select Source Path:" -ForegroundColor White
Write-Host "[1] USB Drive  : $usbBackupPath"
Write-Host "[2] System C:  : $cBackupPath"
$choice = Read-Host "`nSelect [1] or [2] (Default is 1)"

$sourcePath = if ($choice -eq "2") { $cBackupPath } else { $usbBackupPath }

if (-not (Test-Path $sourcePath)) { Write-Host "Error: Path not found!" -ForegroundColor Red; pause; exit }

# --- ส่วนเมนู Interactive (เหมือนเดิม) ---
$categories = Get-ChildItem -Path $sourcePath -Directory | Select-Object -ExpandProperty Name
$selection = New-Object System.Collections.Generic.List[bool]
$categories | ForEach-Object { $selection.Add($false) }
$index = 0
$running = $true

while ($running) {
    Clear-Host
    Write-Host $titleText -ForegroundColor Cyan
    Write-Host " Source: $sourcePath" -ForegroundColor Yellow
    Write-Host " [UP/DOWN] Navigate  [ENTER] Toggle  [A] All  [C] Clear  [S] Start  [Q] Quit`n"
    for ($i = 0; $i -lt $categories.Count; $i++) {
        $char = if ($selection[$i]) { "y" } else { " " }
        $prefix = if ($i -eq $index) { " > " } else { "   " }
        if ($i -eq $index) { Write-Host "$prefix[$char] $($categories[$i])" -ForegroundColor Yellow -BackgroundColor DarkCyan }
        else { Write-Host "$prefix[$char] $($categories[$i])" }
    }
    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    switch ($key.VirtualKeyCode) {
        38 { $index = if ($index -gt 0) { $index - 1 } else { $categories.Count - 1 } }
        40 { $index = if ($index -lt $categories.Count - 1) { $index + 1 } else { 0 } }
        13 { $selection[$index] = -not $selection[$index] }
        65 { for($i=0; $i -lt $selection.Count; $i++) { $selection[$i] = $true } }
        67 { for($i=0; $i -lt $selection.Count; $i++) { $selection[$i] = $false } }
        83 { $running = $false }
        81 { exit }
    }
}

$selectedCategories = for ($i = 0; $i -lt $categories.Count; $i++) { if ($selection[$i]) { $categories[$i] } }
foreach ($catName in $selectedCategories) {
    Write-Host "`nInstalling: [$catName]" -ForegroundColor Cyan
    pnputil.exe /add-driver "$(Join-Path $sourcePath $catName)\*.inf" /subdirs /install
}
Write-Host "`nRestore Completed!" -ForegroundColor Green
pause
