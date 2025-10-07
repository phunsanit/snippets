# ================================================================================================
# SCRIPT: generate_default_constraints_FIXED.ps1
# PURPOSE: Dynamically identifies columns that qualify for a DEFAULT constraint based on
#          specific rules and generates ALTER TABLE DDL statements across multiple databases.
#          Results are saved to SQL files in an output directory.
# NOTE: Requires the SqlServer module (typically installed with SSMS).
#       Must be executed with access to sys.databases (e.g., in a context with server-level permissions).
# AUTHOR: Adapted from SQL script by Pitt Phunsanit
# ================================================================================================

# --- CONFIGURATION SECTION ---

# 1. Define your SQL Server Instance and Database
$SqlServerName = "172.30.32.233" # Example: "SQLDEV\INSTANCE1" or "LOCALHOST"
$DatabaseNameSource = "INSAPP_QA" # Example: "DB_DEV"
$DatabaseNameTarget = "INSAPP" # Example: "DB_QA"

# 2. Define the Authentication Method (Choose one of the two blocks below)

# --- A) WINDOWS AUTHENTICATION (Recommended) ---
# $UseWindowsAuth = $true
# $SqlUserName = ""
# $SqlPassword = ""

# --- B) SQL SERVER AUTHENTICATION (Uncomment and fill in details) ---
$UseWindowsAuth = $false
$SqlUserName = "insapp_admin" # Example: "sa"
$SqlPassword = "insapp!2022" # Example: "your_password"

# 3. Define the Output Directory - FIXED: Ensure parent directory exists
$BaseOutputPath = "C:\portables\SSMS\exporter"
# Create base directory if it doesn't exist
if (-not (Test-Path $BaseOutputPath)) {
    Write-Host "Creating base output directory: $BaseOutputPath" -ForegroundColor Yellow
    New-Item -Path $BaseOutputPath -ItemType Directory -Force | Out-Null
}
$OutputDirectory = "$BaseOutputPath\$(Get-Date -Format 'yyyyMMdd_HHmmss')_data"

# 4. Script Options
$DatabaseNamePattern = "INSAPP%" # Filter for database names (e.g., 'INSAPP%')
$TableNamePattern = "%ap_%" # Filter for tables containing 'ap_' (with % before and after)

# --- SCRIPT LOGIC (DO NOT EDIT BELOW THIS LINE) ---

# Check prerequisites and load SMO
try {
    Import-Module SqlServer -ErrorAction Stop
    Write-Host "SqlServer module loaded successfully" -ForegroundColor Green
}
catch {
    Write-Error "Could not load the 'SqlServer' module. Please install it by running 'Install-Module -Name SqlServer' in an Administrator PowerShell session."
    exit 1
}

# Create output directory
if (-not (Test-Path $OutputDirectory)) {
    Write-Host "Creating output directory: $OutputDirectory" -ForegroundColor Yellow
    New-Item -Path $OutputDirectory -ItemType Directory -Force | Out-Null
} else {
    Write-Host "Output directory already exists: $OutputDirectory" -ForegroundColor Green
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
    Write-Host "Connected successfully to SQL Server: $($Srv.Name)" -ForegroundColor Green
    Write-Host "SQL Server Version: $($Srv.Version)" -ForegroundColor Green
}
catch {
    Write-Error "Failed to connect to SQL Server '$SqlServerName'. Check server name, credentials, and network."
    Write-Error "Error details: $($_.Exception.Message)"
    exit 1
}

# Track metrics
$StartTime = Get-Date
$DefaultCount = 0
$DbCount = 0

Write-Host "Starting default constraint DDL generation for databases matching: $DatabaseNamePattern"
Write-Host "Table filter: $TableNamePattern"
Write-Host "Start Time: $StartTime"
Write-Host "--------------------------------------------------------------------------------"

# Debug: Show all available databases
Write-Host "All user databases found:" -ForegroundColor Cyan
$AllUserDbs = $Srv.Databases | Where-Object { $_.ID -gt 4 } | Sort-Object Name
if ($AllUserDbs.Count -eq 0) {
    Write-Host "  NO USER DATABASES FOUND!" -ForegroundColor Red
} else {
    $AllUserDbs | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Gray }
}

# Get list of databases matching the pattern
$Databases = $Srv.Databases | Where-Object { $_.ID -gt 4 -and $_.Name -like $DatabaseNamePattern } | Sort-Object Name

Write-Host "Databases matching pattern '$DatabaseNamePattern':" -ForegroundColor Cyan
if ($Databases.Count -eq 0) {
    Write-Host "  NO DATABASES FOUND MATCHING PATTERN!" -ForegroundColor Red
    Write-Host "  Consider checking your DatabaseNamePattern: '$DatabaseNamePattern'" -ForegroundColor Red
    Write-Host "  Available databases listed above." -ForegroundColor Red
    exit 1
} else {
    $Databases | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Yellow }
}

# SQL query to identify eligible columns and generate DDL
$Query = @"
WITH EligibleColumns AS (
    SELECT
        DB_NAME() AS DatabaseName,
        s.name AS SchemaName,
        t.name AS TableName,
        c.name AS ColumnName,
        c.column_id,
        ty.name AS DataType,
        c.is_nullable AS IsNullable,
        CASE
            WHEN dc.object_id IS NOT NULL THEN NULL
            ELSE
                CASE
                    WHEN EXISTS (
                        SELECT 1
                        FROM sys.index_columns ic
                        INNER JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
                        WHERE i.is_primary_key = 1
                          AND ic.object_id = t.object_id
                          AND ic.column_id = c.column_id
                    ) AND ty.name = 'uniqueidentifier' THEN 'NEWID()'
                    WHEN c.is_nullable = 0 AND ty.name IN ('datetime', 'date', 'time', 'datetime2', 'smalldatetime', 'datetimeoffset') THEN 'GETDATE()'
                    WHEN ty.name IN ('varchar', 'nvarchar', 'char', 'nchar', 'text', 'ntext') THEN ''''''
                    ELSE NULL
                END
        END AS DefaultValue
    FROM sys.tables t
    INNER JOIN sys.columns c ON t.object_id = c.object_id
    INNER JOIN sys.types ty ON c.system_type_id = ty.system_type_id AND c.user_type_id = ty.user_type_id
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    LEFT JOIN sys.default_constraints dc ON c.object_id = dc.parent_object_id AND c.column_id = dc.parent_column_id
    WHERE t.is_ms_shipped = 0
      AND t.name LIKE @TableNamePattern
)
SELECT
    DatabaseName,
    SchemaName,
    TableName,
    ColumnName,
    DataType AS Columntype,
    CONCAT(
        N'ALTER TABLE ', QUOTENAME(SchemaName), N'.', QUOTENAME(TableName),
        N' ADD CONSTRAINT ', QUOTENAME(CONCAT(N'DF_', TableName, N'_', ColumnName, N'_', REPLACE(CONVERT(NVARCHAR(50), NEWID()), N'-', N''))),
        N' DEFAULT ', DefaultValue, N' FOR ', QUOTENAME(ColumnName), N';'
    ) AS [alter_sql_for_column]
FROM EligibleColumns
WHERE DefaultValue IS NOT NULL
ORDER BY DatabaseName, SchemaName, TableName, column_id;
"@

# Test query to count matching tables
$TableCountQuery = @"
SELECT COUNT(*) as TableCount
FROM sys.tables t
WHERE t.is_ms_shipped = 0
  AND t.name LIKE @TableNamePattern
"@

# Process each database
foreach ($Db in $Databases) {
    $DbCount++
    $DbName = $Db.Name
    Write-Host "Processing database: $DbName" -ForegroundColor Yellow

    # First, check how many tables match the pattern
    try {
        $TableCountResult = Invoke-Sqlcmd -ServerInstance $SqlServerName -Database $DbName -Query $TableCountQuery -Variable "TableNamePattern=$TableNamePattern" -ErrorAction Stop
        $TableCount = $TableCountResult.TableCount
        Write-Host "  -> Found $TableCount tables matching pattern '$TableNamePattern' in $DbName" -ForegroundColor Cyan

        if ($TableCount -eq 0) {
            Write-Host "  -> Skipping $DbName - no matching tables found" -ForegroundColor Gray
            continue
        }
    }
    catch {
        Write-Host "  -> Error checking tables in $DbName`: $($_.Exception.Message)" -ForegroundColor Red
        continue
    }

    $OutputFile = Join-Path $OutputDirectory "$DbName.default_constraints.sql"

    try {
        # Execute the query using Invoke-Sqlcmd
        $Results = Invoke-Sqlcmd -ServerInstance $SqlServerName -Database $DbName -Query $Query -Variable "TableNamePattern=$TableNamePattern" -ErrorAction Stop

        # Write header to output file
        $Header = @"
-- ================================================================================================
-- generate_default_constraints.ps1
-- DDL GENERATION TIMESTAMP: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
-- DATABASE: $DbName
-- TABLE PATTERN: $TableNamePattern
-- ================================================================================================
USE [$DbName];
GO

"@
        $Header | Out-File -FilePath $OutputFile -Encoding UTF8 -Force

        # Write DDL statements to file
        if ($Results) {
            $RowCount = $Results.Count
            $DefaultCount += $RowCount
            Write-Host "  -> Generated $RowCount DDL statements for $DbName" -ForegroundColor Green
            foreach ($Row in $Results) {
                $Row.alter_sql_for_column | Out-File -FilePath $OutputFile -Encoding UTF8 -Append
                "GO" | Out-File -FilePath $OutputFile -Encoding UTF8 -Append
            }
        }
        else {
            Write-Host "  -> No eligible columns found in $DbName" -ForegroundColor Gray
            "-- No eligible columns found for default constraints" | Out-File -FilePath $OutputFile -Encoding UTF8 -Append
        }

        Write-Host "  -> Output file created: $OutputFile" -ForegroundColor Green
    }
    catch {
        Write-Error "Error processing database $DbName`: $($_.Exception.Message)"
        # Still create the file with error information
        $ErrorHeader = @"
-- ================================================================================================
-- ERROR occurred while processing database: $DbName
-- Error: $($_.Exception.Message)
-- Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
-- ================================================================================================
"@
        $ErrorHeader | Out-File -FilePath $OutputFile -Encoding UTF8 -Force
    }
}

# Calculate metrics
$FinishTime = Get-Date
$ExecuteTimeMs = ($FinishTime - $StartTime).TotalMilliseconds

# Summary
Write-Host "=================================================================================" -ForegroundColor Cyan
Write-Host "DDL generation complete." -ForegroundColor Green
Write-Host "Updated Rows (DDL statements generated): $DefaultCount" -ForegroundColor Green
Write-Host "Databases Processed: $DbCount" -ForegroundColor Green
Write-Host "Start Time: $StartTime" -ForegroundColor Gray
Write-Host "Finish Time: $FinishTime" -ForegroundColor Gray
Write-Host "Execute Time (ms): $ExecuteTimeMs" -ForegroundColor Gray
Write-Host "Output files saved to: $OutputDirectory" -ForegroundColor Yellow

# List created files
if (Test-Path $OutputDirectory) {
    $CreatedFiles = Get-ChildItem -Path $OutputDirectory -Filter "*.sql"
    if ($CreatedFiles.Count -gt 0) {
        Write-Host "Created files:" -ForegroundColor Cyan
        $CreatedFiles | ForEach-Object { Write-Host "  - $($_.Name) ($([math]::Round($_.Length/1KB, 2)) KB)" -ForegroundColor Gray }
    } else {
        Write-Host "No SQL files were created in the output directory." -ForegroundColor Red
    }
} else {
    Write-Host "Output directory does not exist!" -ForegroundColor Red
}