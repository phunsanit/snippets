<#
PowerShell move Windows Subsystem for Linux 2 (WSL2)
#by pitt phunsanit
https://pitt.plusmagi.com
phunsanit@gmail.com
#>

$distribution = "docker-desktop"
#$distribution = "Ubuntu"

$folderPath = "C:\UsersDatas\WSL\2\"

$exportPath = [string]::Concat($folderPath, $distribution, ".tar")
$importPath = [string]::Concat($folderPath, $distribution)

#make folder
#Check if Folder exists
If(!(Test-Path -Path $folderPath))
{
	#PowerShell create directory
	New-Item -ItemType Directory -Path $importPath
	Write-Host 'New folder "'$importPath'" created successfully!' -f Green
}
else
{
	Write-Host 'Folder "'$importPath'" already exists!' -f Yellow
}

#stop distribution
wsl -t $distribution

#export distribution
wsl --export $distribution $exportPath

#Unregister distribution
wsl --unregister $distribution

#import distribution
wsl --import $distribution $importPath $exportPath

#wsl --update

Write-Host 'move WSL"'$distribution'" to "'$importPath'" successfully!' -f Blue

#back home directory
cd $home

#show distribution
wsl --install -d $distribution
