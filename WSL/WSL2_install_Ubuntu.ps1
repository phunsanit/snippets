<#
PowerShell install Windows Subsystem for Linux 2 (WSL2)
#by pitt phunsanit
https://pitt.plusmagi.com
phunsanit@gmail.com
#>

#Enabling Windows Services for the WSL.
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

#Windows' Virtual Machine Platform.
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

#set the default version of the WSL to version 2.
wsl --set-default-version 2

#install WSL
wsl --install -d Ubuntu

#list installed distributions
wsl -l -v