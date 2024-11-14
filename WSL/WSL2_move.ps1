<#
PowerShell move Windows Subsystem for Linux 2 (WSL2) version 1.2
#by pitt phunsanit
https://pitt.plusmagi.com
phunsanit@gmail.com

replace $DistributionName with WSL Linux DistributionNames
example Alpine, docker-desktop-data, docker-desktop, Ubuntu

replace $folderPath with new path
#>

$DistributionName = 'Ubuntu'
$folderPath = 'C:\Users\Public\WSLs\'

# common

Clear-Host

$commandString = ''

#run and show message and exit batch
function CommandOrExitBatch {
	param(
		[Parameter(Mandatory=$true)]
		[string] $commandString
	  )

	Write-Host $commandString -f Yellow

	try{
		# Use strict mode within iex for better error handling
		#Invoke-Expression -Command { $commandString } -UseStrict  -ErrorAction Stop
		#Invoke-Expression -Command $commandString
		Invoke-Expression -Command $commandString
	} catch {
		Write-Error 'Script failed with error: ' + $($_.Exception.Message)
		# Assuming script sets exit code
		Write-Warning 'Exit code: ' + $($_.Exception.InnerException.ExitCode)

		Write-Output "This won't be executed"

		exit 1
	}

}

# process

#list installed linux DistributionNames
Write-Host 'list installed linux DistributionNames' -f Blue

$commandString = 'wsl --list --verbose'

CommandOrExitBatch -commandString $commandString

#confirm
Write-Host('WSL Linux DistributionNames is "' + $($DistributionName) + '"') -f Blue

#archive type
$archiveType = Read-Host "Select archive type (tar is default, q to quit): tar, vhd, q"
switch ($archiveType) {
	'tar' { Write-Host "Selected tar archive format." }
	'vhd'  { Write-Host "Specifies the export distribution should be a .vhdx file (this is only supported using WSL 2)" }
	'q' { Write-Host "Exiting..."; exit }  # Exit the batch script when q is chosen
	default { Write-Host "Invalid selection. Defaulting to tar archive format." ; $archiveType = "tar" }
}

Write-Host('You have chosen: ' + $archiveType)

if($archiveType -eq 'q')
{
	GOTO :eof  # Exit the subroutine
}

if($archiveType -eq 'vhd')
{
	$exportPath = [string]::Concat($folderPath, $DistributionName, '.vhdx')
}
else
{
	$exportPath = [string]::Concat($folderPath, $DistributionName, '.tar')
}
$importPath = [string]::Concat($folderPath, $DistributionName)

#make folder
#Check if Folder exists
If(!(Test-Path -Path $exportPath))
{
	#PowerShell create directory
	Write-Host('create directory "' + $($importPath) + '"') -f Blue

	$commandString = 'New-Item -ItemType Directory -Path ' + $importPath

	CommandOrExitBatch -commandString $commandString

	Write-Host('New folder "' + $($importPath) + '" created successfully.') -b White -f DarkGreen
}
Else
{
	Write-Host('Folder "' + $($importPath) + '" already exists.') -f Yellow
}

#stop distribution name
Write-Host 'stop DistributionName' -f Blue

$commandString = 'wsl --terminate ' + $DistributionName

CommandOrExitBatch -commandString $commandString

#export DistributionName
Write-Host 'export DistributionName' -f Blue

if($archiveType -eq 'vhd')
{
	$commandString = 'wsl --export --vhd ' + $DistributionName + ' ' + $exportPath
}
else
{
	$commandString = 'wsl --export ' + $DistributionName + ' ' + $exportPath
}

CommandOrExitBatch -commandString $commandString

#Unregister DistributionName
Write-Host 'Unregister DistributionName' -f Blue

$commandString = 'wsl --unregister ' + $DistributionName

CommandOrExitBatch -commandString $commandString

#import DistributionName
Write-Host 'import DistributionName' -f Blue

if($archiveType -eq 'vhd')
{
	$commandString = 'wsl --import --vhd ' + $DistributionName + ' ' + $importPath + ' ' + $exportPath
}
else {
	$commandString = 'wsl --import ' + $DistributionName + ' ' + $importPath + ' ' + $exportPath
}

CommandOrExitBatch -commandString $commandString

#update WSL
Write-Host 'update WSL' -f Blue

$commandString = 'wsl --update'

CommandOrExitBatch -commandString $commandString

#list installed linux DistributionNames
Write-Host 'list installed linux DistributionNames' -f Blue

$commandString = 'wsl --list --verbose'

CommandOrExitBatch -commandString $commandString

#summary
Write-Host('Move WSL "' + $($DistributionName) + '" to "' + $($importPath) + '" successfully?') -b White -f DarkGreen

#show file
Write-Host 'show file' -f Blue

$commandString = 'Get-ChildItem -Path ' + $folderPath

CommandOrExitBatch -commandString $commandString

#end of file