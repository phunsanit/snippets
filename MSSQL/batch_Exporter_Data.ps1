# batch_Exporter_Data.ps1
# Batch table data export (INSERT statements) with TRUNCATE option
# Author: Pitt Phunsanit
# --- CONFIGURATION SECTION ---

# 1. Define your SQL Server Instance and Database
$SqlServerName = "LOCALHOST" # Example: "SQLDEV\INSTANCE1" or "LOCALHOST"
$DatabaseNameSource = "DB_QA" # Example: "DB_DEV"
$DatabaseNameTarget = "DB_QA" # Example: "DB_QA"

# 2. Define the Authentication Method (Choose one of the two blocks below)

# --- A) WINDOWS AUTHENTICATION (Recommended) ---
# $UseWindowsAuth = $true
# $SqlUserName = ""
# $SqlPassword = ""

# --- B) SQL SERVER AUTHENTICATION (Uncomment and fill in details) ---
$UseWindowsAuth = $false
$SqlUserName = "sa" # Example: "sa"
$SqlPassword = "your_password" # Example: "your_password"

# 3. Define the Output Directory
$OutputDirectory = "C:\portables\SSMS\exporter\$(Get-Date -Format 'yyyyMMdd_HHmmss')_data" # Change to your desired output path

# 4. Script Options
$IncludeTruncateStatements = $true # Set to $false if you don't want TRUNCATE TABLE statements
$IncludeTruncateComments = $true # Set to $false if you don't want decorative comments around TRUNCATE statements
$CommentOutTruncateStatements = $true # Set to $true to wrap TRUNCATE statements in /* */ block comments

# 5. List of Tables to Export (Parsed from your request)
$TableList = @(
    "CBSFINANCE.AC_NOTE",
    "CBSFINANCE.AP_ATTACHMENT",
    "CBSFINANCE.AP_BROKERAGE_DNCN",
    "CBSFINANCE.AP_NOTE_DNCN",
    "CBSFINANCE.AP_PAY_ORDER_APPROVE_LOG",
    "CBSFINANCE.AP_PAY_ORDER_DNCN",
    "CBSFINANCE.AP_PAY_ORDER_EMAIL_LOG",
    "CBSFINANCE.AP_PAY_ORDER_EMAIL",
    "CBSFINANCE.AP_PAY_ORDER_HEADER",
    "CBSFINANCE.AP_PAY_ORDER_MOBILE",
    "CBSFINANCE.AP_PAY_ORDER_OTHER",
    "CBSFINANCE.AP_PAY_ORDER_PREMIUM_TAX_LOG",
    "CBSFINANCE.AP_PAY_ORDER_PREMIUM_TAX",
    "CBSFINANCE.AP_PAY_ORDER_VAT_BROKERAGE",
    "CBSFINANCE.AP_PAYMENT_CHEQUE",
    "CBSFINANCE.AP_PAYMENT_CYCLE",
    "CBSFINANCE.AP_PAYMENT_VOUCHER",
    "CBSFINANCE.AP_PRE_PAY_STM_CHQ_INS",
    "CBSFINANCE.AP_PRE_PAY_STM_DNCN_LOG",
    "CBSFINANCE.AP_PRE_PAY_STM_DNCN",
    "CBSFINANCE.AP_PRE_PAY_STM_EMAIL_LOG",
    "CBSFINANCE.AP_PRE_PAY_STM_EMAIL",
    "CBSFINANCE.AP_PRE_PAY_STM_GROUP_LOG",
    "CBSFINANCE.AP_PRE_PAY_STM_GROUP_PARTNER_TEMP",
    "CBSFINANCE.AP_PRE_PAY_STM_GROUP_PARTNER",
    "CBSFINANCE.AP_PRE_PAY_STM_GROUP",
    "CBSFINANCE.AP_PRE_PAY_STM_HEADER_LOG",
    "CBSFINANCE.AP_PRE_PAY_STM_HEADER",
    "CBSFINANCE.AP_PRE_PAY_STM_MOBILE",
    "CBSFINANCE.AP_PRE_PAY_STM_TBA",
    "CBSFINANCE.AP_REGIS_CHEQUE_PAYMENT",
    "CBSFINANCE.AP_SEARCH_VALUE",
    "CBSFINANCE.AP_SET_PRE_PAYMENT_STM",
    "CBSFINANCE.AP_TMP_BROKERAGE_DNCN",
    "CBSFINANCE.AP_TMP_DNCN",
    "CBSFINANCE.AP_TMP_PRE_PAY_STM_HEADER",
    "CBSFINANCE.BEN_AP_BROKERAGE_DNCN",
    "CBSFINANCE.TMP_AP_BROKERAGE_DNCN"
)

# --- SCRIPT LOGIC (DO NOT EDIT BELOW THIS LINE) ---

# Check prerequisites and load SMO
try {
    Import-Module SqlServer -ErrorAction Stop
}
catch {
    Write-Error "Could not load the 'SqlServer' module. Please install it by running 'Install-Module -Name SqlServer' in an Administrator PowerShell session."
    exit 1
}

# Create output directory
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

# Check connection
try {
    $null = $Srv.Version
}
catch {
    Write-Error "Failed to connect to SQL Server '$SqlServerName'. Check server name, credentials, and network."
    exit 1
}

$Db = $Srv.Databases[$DatabaseNameSource]
if ($Db -eq $null) {
    Write-Error "Database '$DatabaseNameSource' not found on server '$SqlServerName'."
    exit 1
}

# Configure Scripter for Data
$Scripter = New-Object Microsoft.SqlServer.Management.Smo.Scripter $Srv
$Scripter.Options.ScriptSchema = $false
$Scripter.Options.ScriptData = $true
$Scripter.Options.NoCommandTerminator = $false
$Scripter.Options.ScriptDrops = $false
$Scripter.Options.ToFileOnly = $true
$Scripter.Options.Encoding = [System.Text.Encoding]::UTF8

Write-Host "Scripting DATA for $($TableList.Count) tables from '$DatabaseNameSource'..."

# Process each table
$TableList | ForEach-Object {
    $FullName = $_
    if ($FullName -match "(.+)\.(.+)") {
        $SchemaName = $Matches[1]
        $TableName = $Matches[2]
    }
    else {
        Write-Warning "Skipping '$FullName': Invalid Schema.Table format."
        return
    }

    $Table = $Db.Tables[$TableName, $SchemaName]
    if ($Table -ne $null) {
        $OutputFile = Join-Path $OutputDirectory "$SchemaName.$TableName.sql"
        Write-Host "  -> Scripting data for $FullName to $OutputFile" -ForegroundColor Yellow

        try {
            $UseStatement = @"
-- ================================================================================================
-- batch_Exporter_Data.ps1
-- DATA EXPORT TIMESTAMP: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
-- SOURCE DATABASE: $DatabaseNameSource
-- TARGET DATABASE: $DatabaseNameTarget
-- ================================================================================================
USE [$DatabaseNameTarget];
GO

"@
            # Create TRUNCATE TABLE statement (if enabled)
            $TruncateStatement = ""
            if ($IncludeTruncateStatements) {
                if ($IncludeTruncateComments) {
                    $TruncateContent = @"
-- ================================================================================================
-- TRUNCATE TABLE: $SchemaName.$TableName
-- ================================================================================================
IF OBJECT_ID('[$SchemaName].[$TableName]', 'U') IS NOT NULL
    TRUNCATE TABLE [$SchemaName].[$TableName];
GO
"@
                    if ($CommentOutTruncateStatements) {
                        $TruncateStatement = @"
/*
$TruncateContent
*/

-- ================================================================================================
-- INSERT DATA: $SchemaName.$TableName
-- ================================================================================================

"@
                    }
                    else {
                        $TruncateStatement = @"
$TruncateContent

-- ================================================================================================
-- INSERT DATA: $SchemaName.$TableName
-- ================================================================================================

"@
                    }
                }
                else {
                    $TruncateContent = "-- Truncate table if exists`r`nIF OBJECT_ID('[$SchemaName].[$TableName]', 'U') IS NOT NULL`r`n    TRUNCATE TABLE [$SchemaName].[$TableName];`r`nGO"
                    if ($CommentOutTruncateStatements) {
                        $TruncateStatement = "/*`r`n$TruncateContent`r`n*/`r`n`r`n"
                    }
                    else {
                        $TruncateStatement = "$TruncateContent`r`n`r`n"
                    }
                }
            }

            # Write header statements to file
            $UseStatement + $TruncateStatement | Out-File -FilePath $OutputFile -Encoding UTF8 -Force

            # Append data (INSERT statements) to the same file
            $Scripter.Options.FileName = $OutputFile
            $Scripter.Options.AppendToFile = $true
            $Scripter.EnumScript(@($Table))
        }
        catch {
            Write-Error "Error scripting data for table $FullName`: $($_.Exception.Message)"
        }
    }
    else {
        Write-Warning "Table '$FullName' not found in database '$DatabaseNameSource'. Skipping."
    }
}

Write-Host "--- Data export process complete. Check files in '$OutputDirectory' ---"