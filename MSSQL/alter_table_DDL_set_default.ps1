# ================================================================================================
# SCRIPT: generate_default_constraints.ps1
# PURPOSE: Dynamically identifies columns that qualify for a DEFAULT constraint based on
#          specific rules and generates ALTER TABLE DDL statements across multiple databases.
#          Results are saved to SQL files in an output directory.
# NOTE: Requires the SqlServer module (typically installed with SSMS).
#       Must be executed with access to sys.databases (e.g., in a context with server-level permissions).
# AUTHOR: Adapted from SQL script by Pitt Phunsanit
# ================================================================================================

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
$SqlUserName = "sa" # Example: "sa"
$SqlPassword = "your_password" # Example: "your_password"

# 3. Define the Output Directory (files will be created per database/schema)
$OutputDirectory = "C:\portables\SSMS\alter\$(Get-Date -Format 'yyyyMMdd_HHmmss')"

# 4. Script Options
$DatabaseNamePattern = "DB_DEV*" # Filter for database names - PowerShell -like operator uses * wildcard
$TableNamePattern = "%wp_%" # Filter for tables containing 'wp_' (with % before and after)
$IncludeGoStatements = $false # Set to $false if your target program doesn't support GO statements

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
    New-Item -Path $OutputDirectory -ItemType Directory -Force | Out-Null
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

# Track metrics
$StartTime = Get-Date
$DefaultCount = 0
$DbCount = 0

Write-Host "Starting default constraint DDL generation for databases matching: $DatabaseNamePattern"
Write-Host "Table filter: $TableNamePattern"
Write-Host "Include GO statements: $IncludeGoStatements"
Write-Host "Start Time: $StartTime"
Write-Host "--------------------------------------------------------------------------------"

# Get list of databases matching the pattern
$Databases = $Srv.Databases | Where-Object { $_.ID -gt 4 -and $_.Name -like $DatabaseNamePattern } | Sort-Object Name

# Process each database using SMO
foreach ($Db in $Databases) {
    $DbCount++
    $DbName = $Db.Name
    Write-Host "Processing database: $DbName" -ForegroundColor Yellow

    try {
        # Use SMO to access database objects directly
        $Database = $Srv.Databases[$DbName]

        if (-not $Database) {
            Write-Host "  -> Database $DbName not accessible" -ForegroundColor Red
            continue
        }

        # Create database subdirectory
        $DatabaseDirectory = $OutputDirectory

        # Track current schema files
        $CurrentSchemaFiles = @{}
        $SchemaRowCounts = @{}

        $RowCount = 0
        $TablesProcessed = 0

        # Filter tables that match the pattern
        $MatchingTables = $Database.Tables | Where-Object {
            -not $_.IsSystemObject -and
            $_.Name -like $TableNamePattern.Replace('%', '*')  # Convert SQL wildcard to PowerShell wildcard
        }

        Write-Host "  -> Found $($MatchingTables.Count) tables matching pattern '$TableNamePattern'" -ForegroundColor Cyan

        foreach ($Table in $MatchingTables) {
            $TablesProcessed++
            $TableName = $Table.Name
            $SchemaName = $Table.Schema

            Write-Host "    -> Processing table [$SchemaName].[$TableName]" -ForegroundColor Gray

            # Initialize schema file if not exists
            if (-not $CurrentSchemaFiles.ContainsKey($SchemaName)) {
                $SchemaFileName = "${DbName}.${SchemaName}_alter.sql"
                $SchemaOutputFile = Join-Path $DatabaseDirectory $SchemaFileName
                $CurrentSchemaFiles[$SchemaName] = $SchemaOutputFile
                $SchemaRowCounts[$SchemaName] = 0

                # Write schema file header
                $SchemaHeader = @"
-- ================================================================================================
-- generate_default_constraints.ps1
-- DDL GENERATION TIMESTAMP: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
-- SERVER: $SqlServerName
-- DATABASE: $DbName
-- SCHEMA: $SchemaName
-- TABLE PATTERN: $TableNamePattern
-- INCLUDE GO STATEMENTS: $IncludeGoStatements
-- ================================================================================================
USE [$DbName];
$(if ($IncludeGoStatements) { "GO" })

"@
                $SchemaHeader | Out-File -FilePath $SchemaOutputFile -Encoding UTF8 -Force
                Write-Host "    -> Created schema file: $SchemaFileName" -ForegroundColor Cyan
            }

            # Check each column in the table
            foreach ($Column in $Table.Columns) {
                $ColumnName = $Column.Name
                $DataType = $Column.DataType.Name
                $IsNullable = $Column.Nullable

                # Skip if column already has a default constraint
                if ($Column.DefaultConstraint) {
                    continue
                }

                # Determine default value based on column properties
                $DefaultValue = $null

                # Check if it's a primary key with uniqueidentifier
                $IsPrimaryKey = $Table.Indexes | Where-Object { $_.IndexedColumns[$ColumnName] -and $_.IndexKeyType -eq "DriPrimaryKey" }

                if ($IsPrimaryKey -and $DataType -eq "uniqueidentifier") {
                    $DefaultValue = "NEWID()"
                }
                elseif (-not $IsNullable -and $DataType -in @('datetime', 'date', 'time', 'datetime2', 'smalldatetime', 'datetimeoffset')) {
                    $DefaultValue = "GETDATE()"
                }
                elseif ($DataType -in @('varchar', 'nvarchar', 'char', 'nchar', 'text', 'ntext')) {
                    $DefaultValue = "''"
                }

                # Generate DDL statement and write immediately to file
                if ($DefaultValue) {
                    $ConstraintName = "DF_${SchemaName}_${TableName}_${ColumnName}"
                    $DDLStatement = "ALTER TABLE [$SchemaName].[$TableName] ADD CONSTRAINT [$ConstraintName] DEFAULT $DefaultValue FOR [$ColumnName];"

                    # Write immediately to the schema file
                    $SchemaOutputFile = $CurrentSchemaFiles[$SchemaName]
                    $DDLStatement | Out-File -FilePath $SchemaOutputFile -Encoding UTF8 -Append
                    if ($IncludeGoStatements) {
                        "GO" | Out-File -FilePath $SchemaOutputFile -Encoding UTF8 -Append
                    }

                    $RowCount++
                    $SchemaRowCounts[$SchemaName]++
                }
            }
        }

        # Report created files for this database
        foreach ($SchemaName in $CurrentSchemaFiles.Keys) {
            $SchemaOutputFile = $CurrentSchemaFiles[$SchemaName]
            $StatementsCount = $SchemaRowCounts[$SchemaName]
            if ($StatementsCount -gt 0) {
                Write-Host "  -> Completed file: $(Split-Path $SchemaOutputFile -Leaf) ($StatementsCount statements)" -ForegroundColor Green
            } else {
                # Remove empty files
                if (Test-Path $SchemaOutputFile) {
                    Remove-Item $SchemaOutputFile -Force
                    Write-Host "  -> Removed empty file: $(Split-Path $SchemaOutputFile -Leaf)" -ForegroundColor Gray
                }
            }
        }

        $DefaultCount += $RowCount

        if ($RowCount -gt 0) {
            Write-Host "  -> Generated $RowCount DDL statements from $TablesProcessed tables in $DbName" -ForegroundColor Green
        }
        else {
            Write-Host "  -> No eligible columns found in $DbName ($TablesProcessed tables checked)" -ForegroundColor Gray
        }
    }
    catch {
        Write-Error "Error processing database $DbName`: $($_.Exception.Message)"
    }
}

# Calculate metrics
$FinishTime = Get-Date
$ExecuteTimeMs = ($FinishTime - $StartTime).TotalMilliseconds

# Summary
Write-Host "--------------------------------------------------------------------------------"
Write-Host "DDL generation complete."
Write-Host "Updated Rows (DDL statements generated): $DefaultCount"
Write-Host "Databases Processed: $DbCount"
Write-Host "Start Time: $StartTime"
Write-Host "Finish Time: $FinishTime"
Write-Host "Execute Time (ms): $ExecuteTimeMs"
Write-Host "Output files saved to: $OutputDirectory"

# List created files
if (Test-Path $OutputDirectory) {
    $CreatedFiles = Get-ChildItem -Path $OutputDirectory -Filter "*.sql"
    if ($CreatedFiles.Count -gt 0) {
        Write-Host "`nCreated files:" -ForegroundColor Cyan
        $CreatedFiles | ForEach-Object {
            Write-Host "  $($_.Name) ($([math]::Round($_.Length/1KB, 2)) KB)" -ForegroundColor Gray
        }
    } else {
        Write-Host "No SQL files were created." -ForegroundColor Yellow
    }
}