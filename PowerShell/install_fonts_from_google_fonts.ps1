<#
.SYNOPSIS
    Download and Install Google Fonts
    - Auto-elevates to Administrator
    - Options: Cache to USB, Fixed Path, or No Cache (Temp & Delete)
    Author: pitt phunsanit (pitt.plusmagi.com)
#>

# --- 0. ADMIN CHECK ---
# Check for Administrator privileges. If not, restart the script as Administrator.
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# --- 1. SETUP PATHS & MENU ---
# Detect Script Location (Equivalent to USB Path or current file location)
$scriptPath = $PSScriptRoot
if (-not $scriptPath) { $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition }

$usbFontsPath = Join-Path -Path $scriptPath -ChildPath "Fonts"
$cFontsPath = "C:\portables\Fonts"

Clear-Host
$title = @"
====================================================
       GOOGLE FONTS INSTALLER UTILITY
       Author: pitt phunsanit (pitt.plusmagi.com)
====================================================
"@
Write-Host $title -ForegroundColor Cyan

# Menu Selection
Write-Host "Select Download/Cache Destination:" -ForegroundColor White
Write-Host "[1] Current Location : $usbFontsPath" -ForegroundColor Yellow
Write-Host "[2] System C:        : $cFontsPath" -ForegroundColor Gray
Write-Host "[3] No Cache         : (Temp & Delete)" -ForegroundColor Magenta
$choice = Read-Host "`nSelect [1], [2] or [3] (Default is 1)"

# Initialize Cleanup Flag
$shouldCleanup = $false

# Set Cache Directory based on choice
if ($choice -eq "2") {
    $cacheDir = $cFontsPath
}
elseif ($choice -eq "3") {
    # Create a random temp folder
    $cacheDir = Join-Path $env:TEMP "GoogleFontsInstaller_$(Get-Random)"
    $shouldCleanup = $true
}
else {
    $cacheDir = $usbFontsPath
}

# --- 2. CONFIGURATION ---
# List of desired fonts
$fontList = @(
    "Bai+Jamjuree",
    "Chakra+Petch",
    "Charm",
    "Charmonman",
    "Fah+Kwang",
    "K2D",
    "Kodchasan",
    "KoHo",
    "Krub",
    "Maitree",
    "Mali",
    "Niramit",
    "Sarabun",
    "Srisakdi",
    "Taviraj",
    "Thasadith"
)

# --- 3. START PROCESS ---

# Check and create Cache folder if it doesn't exist
if (-not (Test-Path $cacheDir)) {
    New-Item -Path $cacheDir -ItemType Directory | Out-Null
    Write-Host "`nCreated working folder at: $cacheDir" -ForegroundColor Cyan
} else {
    Write-Host "`nUsing working folder at: $cacheDir" -ForegroundColor Cyan
}

# Download Process
foreach ($font in $fontList) {
    $url = "https://fonts.google.com/download?family=$font"
    $zipPath = Join-Path $cacheDir "$font.zip"

    # Check Cache: Skip download if zip file exists
    if (Test-Path $zipPath) {
        Write-Host "[$font] Found in cache. Skipping download." -ForegroundColor Gray
    }
    else {
        Write-Host "[$font] Downloading..." -ForegroundColor Yellow
        try {
            Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing
            Write-Host "[$font] Download completed." -ForegroundColor Green
        }
        catch {
            Write-Host "[$font] Error downloading: $_" -ForegroundColor Red
            continue
        }
    }

    # Extract File
    try {
        Expand-Archive -Path $zipPath -DestinationPath $cacheDir -Force -ErrorAction SilentlyContinue
    }
    catch {
         Write-Host "[$font] Error extracting." -ForegroundColor Red
    }
}

# --- 4. INSTALLATION ---
Write-Host "`nStarting Installation..." -ForegroundColor Cyan

$shell = New-Object -ComObject Shell.Application
$windowsFonts = $shell.Namespace(0x14) # 0x14 = Windows Fonts folder
$fontFiles = Get-ChildItem -Path $cacheDir -Recurse -Include *.ttf, *.otf, *.ttc

foreach ($file in $fontFiles) {
    $fontName = $file.Name
    # Check if the font is already installed in Windows
    if (Test-Path "C:\Windows\Fonts\$fontName") {
        Write-Host "Skipping $fontName (Already installed)" -ForegroundColor DarkGray
    } else {
        Write-Host "Installing $fontName ..." -ForegroundColor Yellow
        try {
            $windowsFonts.CopyHere($file.FullName)
        } catch {
            Write-Host "Failed to install $fontName" -ForegroundColor Red
        }
    }
}

# --- FINISH ---
Write-Host "`n------------------------------------------------"

# Clean up if "No Cache" was selected
if ($shouldCleanup) {
    Write-Host " Cleaning up temporary files..." -ForegroundColor Magenta
    try {
        Remove-Item -Path $cacheDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host " Temp folder deleted." -ForegroundColor Green
    } catch {
        Write-Host " Could not delete temp folder. You may delete it manually at: $cacheDir" -ForegroundColor Red
    }
} else {
    Write-Host " Fonts stored at: $cacheDir" -ForegroundColor Cyan
}

Write-Host " Process Completed!" -ForegroundColor Green
Write-Host "------------------------------------------------"

Start-Sleep -Seconds 3
