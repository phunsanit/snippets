# ================================================================================================
# SCRIPT: DIAGNOSTIC_generate_default_constraints.ps1
# PURPOSE: Debug version to identify why no results are being generated
# ================================================================================================

# --- CONFIGURATION SECTION ---
$SqlServerName = "172.30.32.233"
$UseWindowsAuth = $false
$SqlUserName = "insapp_admin"
$SqlPassword = "insapp!2022"

$OutputDirectory = "C:\portables\SSMS\alter"
$OutputFile = "$OutputDirectory\$(Get-Date -Format 'yyyyMMdd_HHmmss')_diagnostic.sql"

$DatabaseNamePattern = "INSAPP%" # Filter for database names
$TableNamePattern = "%ap_%" # Filter for tables containing 'ap_'

# --- DIAGNOSTIC SCRIPT ---

# Check prerequisites and load SMO
try {
    Import-Module SqlServer -ErrorAction Stop
    Write-Host "✓ SqlServer module loaded successfully" -ForegroundColor Green
}
catch {
    Write-Error "✗ Could not load the 'SqlServer' module. Please install it by running 'Install-Module -Name SqlServer' in an Administrator PowerShell session."
    exit 1
}

# Create output directory
if (-not (Test-Path $OutputDirectory)) {
    Write-Host "Creating output directory: $OutputDirectory" -ForegroundColor Yellow
    New-Item -Path $OutputDirectory -ItemType Directory | Out-Null
}

# Setup SMO Server object
Write-Host "Connecting to SQL Server: $SqlServerName" -ForegroundColor Cyan
if ($UseWindowsAuth) {
    Write-Host "Using Windows Authentication..." -ForegroundColor Gray
    $Srv = New-Object Microsoft.SqlServer.Management.Smo.Server $SqlServerName
}
else {
    Write-Host "Using SQL Login: $SqlUserName..." -ForegroundColor Gray
    $sc = New-Object Microsoft.SqlServer.Management.Common.ServerConnection($SqlServerName, $SqlUserName, $SqlPassword)
    $Srv = New-Object Microsoft.SqlServer.Management.Smo.Server $sc
}

# Check connection
try {
    $version = $Srv.Version
    Write-Host "✓ Connected successfully to SQL Server: $($Srv.Name)" -ForegroundColor Green
    Write-Host "✓ SQL Server Version: $version" -ForegroundColor Green
}
catch {
    Write-Error "✗ Failed to connect to SQL Server '$SqlServerName'. Check server name, credentials, and network."
    Write-Error "Error details: $($_.Exception.Message)"
    exit 1
}

# Initialize diagnostic output file
$DiagnosticHeader = @"
-- ================================================================================================
-- DIAGNOSTIC REPORT
-- TIMESTAMP: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
-- SERVER: $SqlServerName
-- DATABASE PATTERN: $DatabaseNamePattern
-- TABLE PATTERN: $TableNamePattern
-- ================================================================================================

"@
$DiagnosticHeader | Out-File -FilePath $OutputFile -Encoding UTF8 -Force

# Step 1: List ALL user databases
Write-Host "`n=== STEP 1: Checking All User Databases ===" -ForegroundColor Yellow
$AllUserDbs = $Srv.Databases | Where-Object { $_.ID -gt 4 } | Sort-Object Name

$AllDbsInfo = @"
-- ALL USER DATABASES FOUND:
-- Total Count: $($AllUserDbs.Count)

"@
$AllDbsInfo | Out-File -FilePath $OutputFile -Encoding UTF8 -Append

if ($AllUserDbs.Count -eq 0) {
    Write-Host "✗ NO USER DATABASES FOUND!" -ForegroundColor Red
    "-- ✗ NO USER DATABASES FOUND!" | Out-File -FilePath $OutputFile -Encoding UTF8 -Append
} else {
    Write-Host "✓ Found $($AllUserDbs.Count) user databases:" -ForegroundColor Green
    $AllUserDbs | ForEach-Object {
        Write-Host "  - $($_.Name)" -ForegroundColor Gray
        "-- - $($_.Name)" | Out-File -FilePath $OutputFile -Encoding UTF8 -Append
    }
}

# Step 2: Check databases matching pattern
Write-Host "`n=== STEP 2: Checking Databases Matching Pattern '$DatabaseNamePattern' ===" -ForegroundColor Yellow
$MatchingDbs = $Srv.Databases | Where-Object { $_.ID -gt 4 -and $_.Name -like $DatabaseNamePattern } | Sort-Object Name

$MatchingDbsInfo = @"

-- DATABASES MATCHING PATTERN '$DatabaseNamePattern':
-- Total Count: $($MatchingDbs.Count)

"@
$MatchingDbsInfo | Out-File -FilePath $OutputFile -Encoding UTF8 -Append

if ($MatchingDbs.Count -eq 0) {
    Write-Host "✗ NO DATABASES FOUND MATCHING PATTERN '$DatabaseNamePattern'!" -ForegroundColor Red
    $NoMatchMsg = @"
-- ✗ NO DATABASES FOUND MATCHING PATTERN '$DatabaseNamePattern'!
-- Available databases listed above.
-- Consider changing the DatabaseNamePattern or check database names.

"@
    $NoMatchMsg | Out-File -FilePath $OutputFile -Encoding UTF8 -Append
} else {
    Write-Host "✓ Found $($MatchingDbs.Count) databases matching pattern:" -ForegroundColor Green
    $MatchingDbs | ForEach-Object {
        Write-Host "  - $($_.Name)" -ForegroundColor Yellow
        "-- - $($_.Name)" | Out-File -FilePath $OutputFile -Encoding UTF8 -Append
    }
}

# Step 3: For each matching database, check tables
if ($MatchingDbs.Count -gt 0) {
    Write-Host "`n=== STEP 3: Checking Tables in Matching Databases ===" -ForegroundColor Yellow

    $TableCheckQuery = @"
SELECT
    s.name AS SchemaName,
    t.name AS TableName,
    COUNT(c.column_id) AS ColumnCount
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
INNER JOIN sys.columns c ON t.object_id = c.object_id
WHERE t.is_ms_shipped = 0
GROUP BY s.name, t.name
ORDER BY s.name, t.name;
"@

    $TablePatternQuery = @"
SELECT
    s.name AS SchemaName,
    t.name AS TableName,
    COUNT(c.column_id) AS ColumnCount
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
INNER JOIN sys.columns c ON t.object_id = c.object_id
WHERE t.is_ms_shipped = 0
  AND t.name LIKE @TableNamePattern
GROUP BY s.name, t.name
ORDER BY s.name, t.name;
"@

    foreach ($Db in $MatchingDbs) {
        $DbName = $Db.Name
        Write-Host "`n--- Checking Database: $DbName ---" -ForegroundColor Cyan

        $DbSection = @"

-- ================================================================================================
-- DATABASE: $DbName
-- ================================================================================================

"@
        $DbSection | Out-File -FilePath $OutputFile -Encoding UTF8 -Append

        try {
            # Check all tables in database
            $AllTables = Invoke-Sqlcmd -ServerInstance $SqlServerName -Database $DbName -Query $TableCheckQuery -ErrorAction Stop
            Write-Host "  ✓ Total tables in $DbName`: $($AllTables.Count)" -ForegroundColor Green

            "-- Total tables in database: $($AllTables.Count)" | Out-File -FilePath $OutputFile -Encoding UTF8 -Append

            if ($AllTables.Count -gt 0 -and $AllTables.Count -le 50) {
                "-- All tables:" | Out-File -FilePath $OutputFile -Encoding UTF8 -Append
                $AllTables | ForEach-Object {
                    "-- - [$($_.SchemaName)].[$($_.TableName)] ($($_.ColumnCount) columns)" | Out-File -FilePath $OutputFile -Encoding UTF8 -Append
                }
            }

            # Check tables matching pattern
            $MatchingTables = Invoke-Sqlcmd -ServerInstance $SqlServerName -Database $DbName -Query $TablePatternQuery -Variable "TableNamePattern=$TableNamePattern" -ErrorAction Stop
            Write-Host "  ✓ Tables matching pattern '$TableNamePattern': $($MatchingTables.Count)" -ForegroundColor $(if ($MatchingTables.Count -gt 0) { "Green" } else { "Red" })

            $TablePatternInfo = @"

-- Tables matching pattern '$TableNamePattern': $($MatchingTables.Count)
"@
            $TablePatternInfo | Out-File -FilePath $OutputFile -Encoding UTF8 -Append

            if ($MatchingTables.Count -gt 0) {
                $MatchingTables | ForEach-Object {
                    Write-Host "    - [$($_.SchemaName)].[$($_.TableName)] ($($_.ColumnCount) columns)" -ForegroundColor Yellow
                    "-- - [$($_.SchemaName)].[$($_.TableName)] ($($_.ColumnCount) columns)" | Out-File -FilePath $OutputFile -Encoding UTF8 -Append
                }
            } else {
                "-- ✗ No tables found matching pattern '$TableNamePattern' in database $DbName" | Out-File -FilePath $OutputFile -Encoding UTF8 -Append
            }

        }
        catch {
            Write-Host "  ✗ Error accessing database $DbName`: $($_.Exception.Message)" -ForegroundColor Red
            "-- ✗ Error accessing database $DbName`: $($_.Exception.Message)" | Out-File -FilePath $OutputFile -Encoding UTF8 -Append
        }
    }
}

# Summary and Recommendations
Write-Host "`n=== SUMMARY AND RECOMMENDATIONS ===" -ForegroundColor Yellow

$Summary = @"

-- ================================================================================================
-- SUMMARY AND RECOMMENDATIONS
-- ================================================================================================

"@
$Summary | Out-File -FilePath $OutputFile -Encoding UTF8 -Append

if ($AllUserDbs.Count -eq 0) {
    $Rec1 = "-- ISSUE: No user databases found. Check server connection and permissions."
    Write-Host "ISSUE: No user databases found. Check server connection and permissions." -ForegroundColor Red
    $Rec1 | Out-File -FilePath $OutputFile -Encoding UTF8 -Append
}
elseif ($MatchingDbs.Count -eq 0) {
    $Rec2 = @"
-- ISSUE: No databases match pattern '$DatabaseNamePattern'
-- RECOMMENDATION: Try one of these patterns:
--   - Change DatabaseNamePattern to '%' to match all databases
--   - Use a different pattern like 'INS%' or '%APP%'
--   - Check exact database names from the list above
"@
    Write-Host "ISSUE: No databases match pattern '$DatabaseNamePattern'" -ForegroundColor Red
    Write-Host "RECOMMENDATION: Try changing the pattern or check exact database names" -ForegroundColor Yellow
    $Rec2 | Out-File -FilePath $OutputFile -Encoding UTF8 -Append
}
else {
    $Rec3 = @"
-- ISSUE: Databases found but possibly no tables match pattern '$TableNamePattern'
-- RECOMMENDATION: Try one of these patterns:
--   - Change TableNamePattern to '%' to match all tables
--   - Use a different pattern like '%app%' or 'ap_%'
--   - Check exact table names from the lists above
"@
    Write-Host "Found matching databases but check table patterns" -ForegroundColor Yellow
    $Rec3 | Out-File -FilePath $OutputFile -Encoding UTF8 -Append
}

Write-Host "`n✓ Diagnostic complete. Results saved to: $OutputFile" -ForegroundColor Green
Write-Host "Review the file to identify the issue and adjust your patterns accordingly." -ForegroundColor Cyan