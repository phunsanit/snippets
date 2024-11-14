<#
PowerShell: set Allow non-administrators to receive update notifications and Automatic Updates
#by pitt phunsanit
https://pitt.plusmagi.com
phunsanit@gmail.com
#>

#windows XP

# Set Registry path for Group Policy settings
$gpoPath = "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU"

# Enable "Allow non-administrators to receive update notifications"
New-ItemProperty -Path $gpoPath -Name NoNonAdminUpdateNotifications -PropertyType DWORD -Value 0 -Force

# Configure Automatic Updates to "Auto download and notify for install"
New-ItemProperty -Path $gpoPath -Name AUOptions -PropertyType DWORD -Value 2 -Force

# Write confirmation message
Write-Host "Group Policy settings for update notifications and configuration enabled successfully!"

Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name "AllowNonAdminsToReceiveUpdateNotifications" -Value 1 -Type DWORD

#windows 10 allow normal user update windows and automatic update with powershell

#windows 10 / 11
Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name "AllowNonAdminsToReceiveUpdateNotifications" -Value 1 -Type DWORD

#Run a Scheduled Script as Administrator
# Check for updates
$updates = Get-WUInstall -Available

# If updates are available, download and install them
if ($updates.Count -gt 0) {
    # Download updates
    Start-WUInstall -AcceptAll

    # Install updates (requires reboot confirmation)
    Restart-Computer -On UpdateInstallation -Force
} else {
    Write-Host "No updates available."
}

