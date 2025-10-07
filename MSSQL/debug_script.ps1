# DEBUG VERSION - Add this debugging code to your script

# Add after the connection check (around line 65):
Write-Host "Connected successfully to SQL Server: $($Srv.Name)" -ForegroundColor Green
Write-Host "SQL Server Version: $($Srv.Version)" -ForegroundColor Green

# Add before processing databases (around line 125):
Write-Host "All databases found:" -ForegroundColor Cyan
$Srv.Databases | Where-Object { $_.ID -gt 4 } | ForEach-Object {
    Write-Host "  - $($_.Name)" -ForegroundColor Gray
}

Write-Host "Databases matching pattern '$DatabaseNamePattern':" -ForegroundColor Cyan
$Databases = $Srv.Databases | Where-Object { $_.ID -gt 4 -and $_.Name -like $DatabaseNamePattern } | Sort-Object Name
if ($Databases.Count -eq 0) {
    Write-Host "  NO DATABASES FOUND MATCHING PATTERN!" -ForegroundColor Red
} else {
    $Databases | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Yellow }
}

# Add inside the database processing loop (after line 130):
Write-Host "Testing table pattern '$TableNamePattern' in database '$DbName'..." -ForegroundColor Magenta

# Test query to count matching tables
$TestQuery = @"
SELECT COUNT(*) as TableCount
FROM sys.tables t
WHERE t.is_ms_shipped = 0
  AND t.name LIKE @TableNamePattern
"@

try {
    $TableCount = Invoke-Sqlcmd -ServerInstance $SqlServerName -Database $DbName -Query $TestQuery -Variable "TableNamePattern=$TableNamePattern" -ErrorAction Stop
    Write-Host "  -> Found $($TableCount.TableCount) tables matching pattern in $DbName" -ForegroundColor Cyan
} catch {
    Write-Host "  -> Error counting tables: $($_.Exception.Message)" -ForegroundColor Red
}

# Add explicit directory check:
Write-Host "Output directory path: $OutputDirectory" -ForegroundColor Cyan
Write-Host "Parent directory exists: $(Test-Path (Split-Path $OutputDirectory -Parent))" -ForegroundColor Cyan
Write-Host "Output directory exists: $(Test-Path $OutputDirectory)" -ForegroundColor Cyan