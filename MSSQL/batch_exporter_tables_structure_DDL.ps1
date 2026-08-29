# batch_exporter_tables_structure_DDL.ps1
# batch table DLL (Data Definition Language)
# Author: Pitt Phunsanit
# --- CONFIGURATION SECTION ---

# 1. Define your SQL Server Instance and Database
$SqlServerName = "LOCALHOST" # Example: "SQLDEV\INSTANCE1" or "LOCALHOST"
$DatabaseNameSource = "DB_DEV" # Example: "DB_DEV"
$DatabaseNameTarget = "DB_QA" # Example: "DB_QA"

# 2. Define the Authentication Method (Choose one of the two blocks below)

# --- A) WINDOWS AUTHENTICATION (Recommended) ---
# $UseWindowsAuth = $true
# $SqlUserName = ""
# $SqlPassword = ""

# --- B) SQL SERVER AUTHENTICATION (Uncomment and fill in details) ---
$UseWindowsAuth = $false
$SqlUserName = "pitt" # Example: "sa"
$SqlPassword = "phunsanit" # Example: "your_password"

# 3. Define the Output Directory
$OutputDirectory = "C:\portables\SSMS\exporter\$(Get-Date -Format 'yyyyMMdd_HHmmss')_DDL" # Change to your desired output path

# 4. Script Options
$IncludeDropStatements = $true # Set to $false if you don't want DROP TABLE IF EXISTS statements
$IncludeDropComments = $true # Set to $false if you don't want decorative comments around DROP statements
$CommentOutDropStatements = $true # Set to $true to wrap DROP statements in /* */ block comments

# 5. List of Tables to Export (Parsed from your request)
$TableList = @(
    "PP.APPROVE_LOG",
    "PP.ORDER",
    "PP.PAY_ORDER_EMAIL_LOG",
    "PP.PAY_ORDER_PREMIUM_VAT",
    "PP.PAY_ORDER_VAT",
    "PP.PAY_ORDER",
    "PP.PAYMENT_CHEQUE",
    "PP.PAYMENT_CYCLE",
    "PP.PAYMENT_VOUCHER",
    "PP.PERMISSION",
    "PP.SEARCH",
    "PP.USERS"
)

# Requires PowerShell 5.1 or newer.
# REQUIRES: The SQL Server Management Objects (SMO) component must be installed
# on the machine running this script. This is typically included with a full SSMS installation.

# Check if running as Administrator
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $IsAdmin) {
    Write-Warning "This script is not running with Administrator privileges."
    Write-Host "To install SqlServer module, you need to:" -ForegroundColor Yellow
    Write-Host "  1. Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Cyan
    Write-Host "  2. Run: Install-Module -Name SqlServer -Force -AllowClobber" -ForegroundColor Cyan
    Write-Host "  3. Then run this script normally" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Continuing with current privileges..." -ForegroundColor Yellow
    Write-Host ""
}

# --- SCRIPT LOGIC (DO NOT EDIT BELOW THIS LINE) ---

Write-Host "--- SQL DDL Export using SMO ---"

# Load the SMO assembly
# Try to find common SMO installation paths
try {
    # Try to use SqlServer PowerShell module first (recommended approach)
    Import-Module SqlServer -ErrorAction Stop
    Write-Host "Using SqlServer PowerShell module"
}
catch {
    Write-Warning "SqlServer PowerShell module not found. For best compatibility, install it by running:"
    Write-Host "    Install-Module -Name SqlServer -Force -AllowClobber" -ForegroundColor Cyan
    Write-Host "Falling back to direct SMO assembly loading..." -ForegroundColor Yellow

    try {
        # Check SSMS 21 path first - load required dependencies
        Add-Type -Path "C:\Program Files\Microsoft SQL Server Management Studio 21\Release\Common7\IDE\Microsoft.SqlServer.ConnectionInfo.dll" -ErrorAction Stop
        Add-Type -Path "C:\Program Files\Microsoft SQL Server Management Studio 21\Release\Common7\IDE\Microsoft.SqlServer.Smo.dll" -ErrorAction Stop
    }
    catch {
        try {
            # Check SSMS 18/19 paths
            Add-Type -Path (Get-Item "C:\Program Files\Microsoft SQL Server\*\Tools\Binn\ManagementStudio\Microsoft.SqlServer.Smo.dll").FullName -ErrorAction Stop
        }
        catch {
            try {
                # Check general SQL Server path
                Add-Type -Path (Get-Item "C:\Program Files\Microsoft SQL Server\*\Shared\Microsoft.SqlServer.Smo.dll").FullName -ErrorAction Stop
            }
            catch {
                Write-Error "Could not load Microsoft.SqlServer.Smo.dll. Please ensure SMO is installed."
                Write-Host ""
                Write-Host "SOLUTION: Install the SqlServer PowerShell module by running:" -ForegroundColor Red
                Write-Host "    Install-Module -Name SqlServer -Force -AllowClobber" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "Or install SQL Server Management Studio (SSMS) which includes SMO components." -ForegroundColor Yellow
                exit 1
            }
        }
    }
}

# Create output directory if it doesn't exist
if (-not (Test-Path $OutputDirectory)) {
    Write-Host "Creating output directory: $OutputDirectory"
    New-Item -Path $OutputDirectory -ItemType Directory | Out-Null
}

# Setup SMO Server object
if ($UseWindowsAuth) {
    Write-Host "Connecting to $SqlServerName using Windows Authentication..."
    $Srv = New-Object Microsoft.SqlServer.Management.Smo.Server $SqlServerName
}
else {
    Write-Host "Connecting to $SqlServerName using SQL Login: $SqlUserName..."
    $sc = New-Object Microsoft.SqlServer.Management.Common.ServerConnection($SqlServerName, $SqlUserName, $SqlPassword)
    $Srv = New-Object Microsoft.SqlServer.Management.Smo.Server $sc
}

# Check for successful connection
if ($Srv -eq $null) {
    Write-Error "Failed to connect to SQL Server $SqlServerName. Check server name and credentials."
    exit 1
}

# Get the target database
$Db = $Srv.Databases[$DatabaseNameSource]
if ($Db -eq $null) {
    Write-Error "Database '$DatabaseNameSource' not found on server '$SqlServerName'."
    exit 1
}

# Configure Scripting Options
$Scripter = New-Object Microsoft.SqlServer.Management.Smo.Scripter $Srv

$Scripter.Options.ScriptSchema = $true
$Scripter.Options.ScriptData = $false
$Scripter.Options.NoCommandTerminator = $false
$Scripter.Options.DriAll = $true # Include all constraints (PK, FK, CHECK, UQ, etc.)
$Scripter.Options.Indexes = $true # Include indexes
$Scripter.Options.Triggers = $true # Include triggers
$Scripter.Options.ScriptDrops = $false # We'll handle drops manually
$Scripter.Options.ExtendedProperties = $true # Include descriptions (extended properties)

try { $Scripter.Options.ScriptCheckConstraints = $true } catch { } # Include check constraints if supported
try { $Scripter.Options.IncludeIfNotExists = $true } catch { } # Use IF NOT EXISTS for CREATE statements if supported

Write-Host "Scripting DDL for $($TableList.Count) tables in database '$DatabaseNameSource'..."

# Process each table
$TableList | ForEach-Object {
    $FullName = $_

    # Parse schema and table name
    if ($FullName -match "(.+)\.(.+)") {
        $SchemaName = $Matches[1]
        $TableName = $Matches[2]
    }
    else {
        Write-Warning "Skipping '$FullName': Could not parse Schema.Table format."
        return # Skip this item
    }

    $Table = $Db.Tables[$TableName, $SchemaName]

    if ($Table -ne $null) {
        $OutputFile = Join-Path $OutputDirectory "$SchemaName.$TableName.sql"
        Write-Host "  -> Scripting $FullName to $OutputFile" -ForegroundColor Yellow

        try {
            # Create USE DATABASE statement
            $UseStatement = @"
-- ================================================================================================
-- batch_Exporter_DDL.ps1
-- DDL EXPORT TIMESTAMP: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
-- ================================================================================================
-- SOURCE DATABASE: $DatabaseNameSource
-- target DATABASE: $DatabaseNameTarget
-- ================================================================================================
USE [$DatabaseNameTarget]; --- create in DATABASE: $DatabaseNameTarget from structure in $DatabaseNameSource
GO

"@

            # Create DROP TABLE IF EXISTS statement (if enabled)
            $DropStatement = ""
            if ($IncludeDropStatements) {
                if ($IncludeDropComments) {
                    $DropContent = @"
-- ================================================================================================
-- DROP TABLE IF EXISTS: $SchemaName.$TableName
-- ================================================================================================
IF OBJECT_ID('[$SchemaName].[$TableName]', 'U') IS NOT NULL
    DROP TABLE [$SchemaName].[$TableName];
GO
"@
                    if ($CommentOutDropStatements) {
                        $DropStatement = @"
/*
$DropContent
*/

-- ================================================================================================
-- CREATE TABLE: $SchemaName.$TableName
-- ================================================================================================

"@
                    }
                    else {
                        $DropStatement = @"
$DropContent

-- ================================================================================================
-- CREATE TABLE: $SchemaName.$TableName
-- ================================================================================================

"@
                    }
                }
                else {
                    $DropContent = "-- Drop table if exists`r`nIF OBJECT_ID('[$SchemaName].[$TableName]', 'U') IS NOT NULL`r`n    DROP TABLE [$SchemaName].[$TableName];`r`nGO"
                    if ($CommentOutDropStatements) {
                        $DropStatement = "/*`r`n$DropContent`r`n*/`r`n`r`n"
                    }
                    else {
                        $DropStatement = "$DropContent`r`n`r`n"
                    }
                }
            }

            # Use Script() method which returns a StringCollection (lines of SQL)
            $ScriptLines = $Scripter.Script($Table)

            # Combine USE statement, DROP statement (if enabled) with CREATE script and save to file
            $UseStatement + $DropStatement + ($ScriptLines -join "`r`n") | Out-File -FilePath $OutputFile -Encoding UTF8 -Force

        }
        catch {
            Write-Error "Error scripting table $FullName`: $($_.Exception.Message)"
        }
    }
    else {
        Write-Warning "Table '$FullName' not found in database '$DatabaseNameSource'. Skipping."
    }
}

Write-Host "--- Process complete. Check files in $OutputDirectory ---"