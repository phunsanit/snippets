# https://en.wikipedia.org/wiki/Software_versioning
function GetVersion {
    param (
        [string]$versionString
    )

    $cleanVersionString = $versionString -replace '^>\s*', ''

    $versionParts = $cleanVersionString -split '\.'

    $versionMajor = if ($versionParts.Length -ge 1) { $versionParts[0] } else { 0 }
    $versionMinor = if ($versionParts.Length -ge 2) { $versionParts[1] } else { 0 }

    return $versionMajor, $versionMinor
}

# Clear the screen
Clear-Host

# Run the winget list command and parse the result
$wingetList = winget list --disable-interactivity --nowarn

# Loop through the list of installed applications
foreach ($line in $wingetList) {
    $columns = $line -split '\s{2,}'
    $Update = $false

    $Name = $columns[0].Trim()

    # Skip the first line
    if ($Name -eq '' -or $Name -eq 'Name' -or $Name.StartsWith('-')) {
        continue
    }

    $Id = if ($columns.Length -ge 2) { $columns[1].Trim() } else { '' }
    $VersionInstalled = if ($columns.Length -ge 3) { $columns[2].Trim() } else { '' }
    $Source = if ($columns.Length -ge 4) { $columns[3].Trim() } else { '' }

    $VersionNew = winget show $Id | Select-String -Pattern 'Version:\s*(\S+)' -AllMatches | ForEach-Object { $_.Matches.Groups[1].Value }

    $VersionInstalledMajor, $VersionInstalledMinor = GetVersion -versionString $VersionInstalled
    $VersionNewMajor, $VersionNewMinor = GetVersion -versionString $VersionNew

    if ($VersionInstalledMajor -eq 0 -or $VersionInstalledMinor -eq 0) {
        #$Update = $true
    }
    elseif ($VersionInstalledMajor -lt $VersionNewMajor) {
        $Update = $true
    }
    elseif (($VersionInstalledMajor -eq $VersionNewMajor) -and ($VersionInstalledMinor -lt $VersionNewMinor)) {
        $Update = $true
    }

    if ($Update) {
        Write-Host "Updating $Name ($Id) from version ($VersionInstalled) to ($VersionNew)"
        try {
            winget upgrade --id $Id --accept-package-agreements --accept-source-agreements --silent

            Write-Host "Successfully updated $Name ($Id) to version $VersionNew"
        }
        catch {
            Write-Host "Failed to update $Name ($Id). Error: $_"
        }
    } else {
        Write-Host "Skip $Name ($Id)"
    }
}

# Display the parsed list in a table format
$parsedList | Format-Table -Property Name, Id, @{Name = 'Version Installed'; Expression = { $_.VersionInstalled } }, @{Name = 'Version New'; Expression = { $_.VersionNew } }, Update, Source -AutoSize