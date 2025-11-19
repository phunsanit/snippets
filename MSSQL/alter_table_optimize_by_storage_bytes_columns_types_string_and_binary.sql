/*
================================================================================
STORAGE OPTIMIZATION: FIXED-LENGTH VS VARIABLE-LENGTH
================================================================================
References (Microsoft Learn):
1. CHAR vs VARCHAR:
   https://learn.microsoft.com/en-us/sql/t-sql/data-types/char-and-varchar-transact-sql?view=sql-server-ver16#storage
   - CHAR(n): Spends 'n' bytes regardless of actual data length.
   - VARCHAR(n): Spends Actual Length + 2 bytes.

2. NCHAR vs NVARCHAR:
   https://learn.microsoft.com/en-us/sql/t-sql/data-types/nchar-and-nvarchar-transact-sql?view=sql-server-ver16#storage
   - NCHAR(n): Spends 'n * 2' bytes regardless of data.
   - NVARCHAR(n): Spends (Actual Length * 2) + 2 bytes.

3. BINARY vs VARBINARY:
   https://learn.microsoft.com/en-us/sql/t-sql/data-types/binary-and-varbinary-transact-sql?view=sql-server-ver16#storage
   - BINARY(n): Spends 'n' bytes.
   - VARBINARY(n): Spends Actual Length + 2 bytes.
================================================================================
*/

SET NOCOUNT ON;

DECLARE @AnalysisTable TABLE (
    DatabaseName NVARCHAR(128), -- เพิ่มเพื่อใช้เรียงลำดับ
    SchemaName NVARCHAR(128),
    TableName NVARCHAR(128),
    ColumnName NVARCHAR(128),
    DataType NVARCHAR(50),
    DefinedLength INT,
    ActualMaxLength INT,
    RowCountVal INT
);

DECLARE @Db NVARCHAR(128), @Schema NVARCHAR(128), @Table NVARCHAR(128), @Col NVARCHAR(128), @Type NVARCHAR(50), @Len INT;
DECLARE @SQL NVARCHAR(MAX);
DECLARE @ActualMax INT, @RowCnt INT;

-- 1. ดึง Column เป้าหมาย (เพิ่ม table_catalog สำหรับ DB Name)
DECLARE cur_all_cols CURSOR FOR
SELECT table_catalog, table_schema, table_name, column_name, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM information_schema.columns
WHERE DATA_TYPE IN ('char', 'nchar', 'binary', 'varchar', 'nvarchar', 'varbinary')
  AND CHARACTER_MAXIMUM_LENGTH > 0
  AND table_schema NOT IN ('sys', 'information_schema');

OPEN cur_all_cols;
FETCH NEXT FROM cur_all_cols INTO @Db, @Schema, @Table, @Col, @Type, @Len;

-- 2. วนลูป Scan หา Max Length ของจริง
WHILE @@FETCH_STATUS = 0
BEGIN
    RAISERROR ('Scanning: %s.%s.%s [%s]', 0, 1, @Db, @Schema, @Table, @Col) WITH NOWAIT;

    IF @Type IN ('char', 'nchar', 'varchar', 'nvarchar')
        SET @SQL = N'SELECT @MaxVal = MAX(LEN(' + QUOTENAME(@Col) + ')), @Cnt = COUNT(*) FROM ' + QUOTENAME(@Schema) + '.' + QUOTENAME(@Table);
    ELSE
        SET @SQL = N'SELECT @MaxVal = MAX(DATALENGTH(' + QUOTENAME(@Col) + ')), @Cnt = COUNT(*) FROM ' + QUOTENAME(@Schema) + '.' + QUOTENAME(@Table);

    EXEC sp_executesql @SQL, N'@MaxVal INT OUTPUT, @Cnt INT OUTPUT', @MaxVal = @ActualMax OUTPUT, @Cnt = @RowCnt OUTPUT;

    -- Insert ลงตารางพร้อมชื่อ Database
    INSERT INTO @AnalysisTable VALUES (@Db, @Schema, @Table, @Col, @Type, @Len, ISNULL(@ActualMax, 0), @RowCnt);

    FETCH NEXT FROM cur_all_cols INTO @Db, @Schema, @Table, @Col, @Type, @Len;
END

CLOSE cur_all_cols;
DEALLOCATE cur_all_cols;

-- 3. แสดงผลและสร้าง Script
SELECT
    DatabaseName, -- แสดงชื่อ DB เป็นคอลัมน์แรก
    SchemaName,
    TableName,
    ColumnName,

    -- Current State
    UPPER(DataType) + '(' + CAST(DefinedLength AS VARCHAR) + ')' AS CurrentType,
    ActualMaxLength,

    -- Target State
    CASE
        WHEN DataType IN ('char', 'varchar') THEN 'VARCHAR'
        WHEN DataType IN ('nchar', 'nvarchar') THEN 'NVARCHAR'
        WHEN DataType IN ('binary', 'varbinary') THEN 'VARBINARY'
    END +
    '(' + CAST(CASE WHEN ActualMaxLength < 1 THEN 1 ELSE ActualMaxLength END AS VARCHAR) + ')'
    AS TargetType,

    -- Priority
    CASE
        WHEN DataType IN ('char', 'nchar', 'binary') AND ActualMaxLength < DefinedLength THEN 'HIGH (Space Saving)'
        WHEN DataType IN ('varchar', 'nvarchar', 'varbinary') AND ActualMaxLength < DefinedLength THEN 'LOW (Schema Tightening)'
        ELSE 'SKIP'
    END AS Priority,

    -- Alter Script
    'ALTER TABLE ' + QUOTENAME(SchemaName) + '.' + QUOTENAME(TableName) +
    ' ALTER COLUMN ' + QUOTENAME(ColumnName) + ' ' +
    CASE
        WHEN DataType IN ('char', 'varchar') THEN 'VARCHAR'
        WHEN DataType IN ('nchar', 'nvarchar') THEN 'NVARCHAR'
        WHEN DataType IN ('binary', 'varbinary') THEN 'VARBINARY'
    END +
    '(' + CAST(CASE WHEN ActualMaxLength < 1 THEN 1 ELSE ActualMaxLength END AS VARCHAR) + ');'
    AS AlterScript

FROM @AnalysisTable
WHERE
    RowCountVal > 0
    AND ActualMaxLength < DefinedLength
ORDER BY
    Priority,
    DatabaseName,  -- เรียงตาม Database
    SchemaName,    -- เรียงตาม Schema
    TableName,     -- เรียงตาม Table
    ColumnName;    -- เรียงตาม Column
