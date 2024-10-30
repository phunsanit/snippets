# Get the full path to the script. Handles relative and absolute paths.
$scriptPath = Resolve-Path .\winget_update_major_minor_change.ps1

# Check if the script exists.
if (!(Test-Path $scriptPath)) {
    Write-Error "Error: Script '$scriptPath' not found. Check the path and ensure the script exists."
    exit 1
}

# Task name
$taskName = "WingetUpdateWeekly"

# Check if the task already exists and remove it if necessary. Improved error handling
try {
    $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue # SilentlyContinue for the case of not finding the task.
    if ($existingTask) {
        Write-Warning "Scheduled task '$taskName' already exists. Removing existing task..."
        Remove-ScheduledTask -TaskName $taskName -Force -ErrorAction Stop # Stop on error during removal
    }
}
catch {
    #This catch block now handles the error of *not finding* the task properly.
    Write-Warning "No existing task found. Proceeding to create a new one."
}

# Create the scheduled task
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Wednesday -At 12:00:00
$powershellPath = (Get-Command powershell.exe).Source
$action = New-ScheduledTaskAction -Execute $powershellPath -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`""

try {
    Register-ScheduledTask -Action $action -Force -RunLevel Highest -TaskName $taskName -Trigger $trigger
    Write-Host "Scheduled task '$taskName' created successfully. It will run every Wednesday at noon with administrator privileges."
}
catch {
    Write-Error "Error creating scheduled task: $_"
    exit 1
}