# batch_Excute_All_SQL_In_Folder.ps1
#
# This script executes all .sql files found in the script's directory (or a specified path)
# against a target SQL Server database. It now captures and displays the output,
# including row counts from INSERT/UPDATE/DELETE operations.

# --- Configuration Section ---

# Define your server and database
# !!! IMPORTANT: Update these variables for your environment !!!
$SqlServerNameE="MAGI-01-MELCHIO"
$DatabaseNameTargetE="INSAPP"

# Path to the folder containing your SQL scripts
# It attempts to find the path of the first .sql file, otherwise defaults to the current directory.
$SCRIPT_PATH = Get-Item -Path ".\*.sql" | Select-Object -ExpandProperty DirectoryName -First 1

# If the path is not found, use the current directory
if (-not $SCRIPT_PATH) {
    $SCRIPT_PATH = Get-Location
}

# --- Execution Section ---

Write-Host "--- Starting SQL Batch Execution ---" -ForegroundColor Green
Write-Host "Server: $SqlServerNameE" -ForegroundColor Yellow
Write-Host "Database: $DatabaseNameTargetE" -ForegroundColor Yellow
Write-Host "Script Path: $SCRIPT_PATH" -ForegroundColor Yellow
Write-Host "------------------------------------" -ForegroundColor Green

# Find all .sql files and sort them by name (ensures numbered files run in order)
$SqlFiles = Get-ChildItem -Path $SCRIPT_PATH -Filter "*.sql" | Sort-Object Name

# Loop through each file and execute it using sqlcmd
foreach ($File in $SqlFiles) {
    $SqlFilePath = $File.FullName
    Write-Host "`n[START] Executing $($File.Name)..." -ForegroundColor Cyan

    # Use the call operator (&) and assign the output to $SqlOutput.
    # This captures the standard output (row counts, messages, etc.) from sqlcmd.
    # -E uses Windows Authentication. Use -U username -P password for SQL Auth.
    # -b (on error) exits the script immediately.
    $SqlOutput = & sqlcmd -S $SqlServerNameE -d $DatabaseNameTargetE -E -i "$SqlFilePath" -b

    # Check the exit code of sqlcmd. $LASTEXITCODE holds the return code of the last native executable.
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error executing $($File.Name)! Stopping script."
        Write-Host "--- SQLCMD Error Output ---" -ForegroundColor Red
        # Display the error output captured by PowerShell (if any)
        $SqlOutput
        Write-Host "---------------------------" -ForegroundColor Red
        # Stop the PowerShell script
        exit 1
    } else {
        Write-Host "[SUCCESS] $($File.Name) executed successfully." -ForegroundColor Green
        Write-Host "--- SQL Output (Row Counts/Messages) ---" -ForegroundColor DarkYellow
        # Display the captured successful output
        $SqlOutput
        Write-Host "----------------------------------------" -ForegroundColor DarkYellow
    }
}

Write-Host "`nAll scripts executed successfully! Press any key to continue..." -ForegroundColor Green
# Wait for user input before closing the window (optional, useful when running in a new window)
$host.UI.RawUI.ReadKey("NoEcho,IncludeKeypress") | Out-Null