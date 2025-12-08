/*
================================================================================
SAFE STORAGE OPTIMIZATION: FIXED-LENGTH TO VARIABLE-LENGTH
================================================================================
Objective:
   Convert CHAR/NCHAR/BINARY to VARCHAR/NVARCHAR/VARBINARY
   to save storage space while KEEPING THE ORIGINAL DEFINED LENGTH.

   Safe Conversion Rule:
   Current: CHAR(100) -> Target: VARCHAR(100)
   (Does not reduce size to actual data length to prevent future truncation errors)

References:
   CHAR(n) takes n bytes.
   VARCHAR(n) takes actual_length + 2 bytes.
================================================================================
*/

SET NOCOUNT ON;

DECLARE @AnalysisTable TABLE (
    DatabaseName NVARCHAR(128),
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

-- ============================================================================
-- 1. ดึง Column เป้าหมาย
-- เลือกเฉพาะ CHAR, NCHAR, BINARY เท่านั้น (ไม่เอา VARCHAR เพราะเราไม่ลดขนาด)
-- ============================================================================
DECLARE cur_all_cols CURSOR FOR
SELECT
    TABLE_CATALOG,
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE DATA_TYPE IN ('char', 'nchar', 'binary') -- <--- Focus only on fixed types
  AND CHARACTER_MAXIMUM_LENGTH > 0
  AND TABLE_SCHEMA NOT IN ('sys', 'information_schema');

OPEN cur_all_cols;
FETCH NEXT FROM cur_all_cols INTO @Db, @Schema, @Table, @Col, @Type, @Len;

-- ============================================================================
-- 2. วนลูป Scan ข้อมูลจริง (เพื่อดูว่าปัจจุบันใช้พื้นที่คุ้มค่าหรือไม่)
-- ============================================================================
WHILE @@FETCH_STATUS = 0
BEGIN
    RAISERROR ('Scanning: %s.%s.%s [%s] (%s)', 0, 1, @Db, @Schema, @Table, @Col, @Type) WITH NOWAIT;

    -- สร้าง Dynamic SQL เพื่อหา Max Length จริง และจำนวน Row
    IF @Type IN ('char', 'nchar')
        SET @SQL = N'SELECT @MaxVal = MAX(LEN(' + QUOTENAME(@Col) + ')), @Cnt = COUNT(*) FROM ' + QUOTENAME(@Schema) + '.' + QUOTENAME(@Table);
    ELSE
        SET @SQL = N'SELECT @MaxVal = MAX(DATALENGTH(' + QUOTENAME(@Col) + ')), @Cnt = COUNT(*) FROM ' + QUOTENAME(@Schema) + '.' + QUOTENAME(@Table);

    -- รัน SQL และเก็บผลลัพธ์
    EXEC sp_executesql @SQL, N'@MaxVal INT OUTPUT, @Cnt INT OUTPUT', @MaxVal = @ActualMax OUTPUT, @Cnt = @RowCnt OUTPUT;

    -- Insert ข้อมูลลงตารางพัก
    INSERT INTO @AnalysisTable
    VALUES (@Db, @Schema, @Table, @Col, @Type, @Len, ISNULL(@ActualMax, 0), @RowCnt);

    FETCH NEXT FROM cur_all_cols INTO @Db, @Schema, @Table, @Col, @Type, @Len;
END

CLOSE cur_all_cols;
DEALLOCATE cur_all_cols;

-- ============================================================================
-- 3. แสดงผลและสร้าง Script (Safe Conversion Logic)
-- ============================================================================
SELECT
    SchemaName,
    TableName,
    ColumnName,

    -- Information
    RowCountVal AS [Total Rows],
    UPPER(DataType) + '(' + CAST(DefinedLength AS VARCHAR) + ')' AS [Current Type],
    ActualMaxLength AS [Max Data Length],

    -- Potential Wasted Space (Estimate per row)
    CASE
        WHEN DataType = 'char' THEN DefinedLength - ActualMaxLength
        WHEN DataType = 'nchar' THEN (DefinedLength * 2) - (ActualMaxLength * 2)
        ELSE 0
    END AS [Est. Bytes Saved/Row],

    -- Target Type: เปลี่ยน Type แต่ใช้ DefinedLength ตัวเดิม
    CASE
        WHEN DataType = 'char' THEN 'VARCHAR'
        WHEN DataType = 'nchar' THEN 'NVARCHAR'
        WHEN DataType = 'binary' THEN 'VARBINARY'
    END +
    '(' + CAST(DefinedLength AS VARCHAR) + ')' AS [Target Type],

    -- Generate ALTER Script (Conditional)
    CASE
        -- เงื่อนไข: ถ้าข้อมูลจริง (Actual) เต็มความจุ (Defined) แปลว่า Save = 0 --> ไม่แสดง Script
        WHEN ActualMaxLength >= DefinedLength THEN NULL
        ELSE
            'ALTER TABLE ' + QUOTENAME(SchemaName) + '.' + QUOTENAME(TableName) +
            ' ALTER COLUMN ' + QUOTENAME(ColumnName) + ' ' +
            CASE
                WHEN DataType = 'char' THEN 'VARCHAR'
                WHEN DataType = 'nchar' THEN 'NVARCHAR'
                WHEN DataType = 'binary' THEN 'VARBINARY'
            END +
            '(' + CAST(DefinedLength AS VARCHAR) + ');'
    END AS [Alter Script]

FROM @AnalysisTable
WHERE
    RowCountVal > 0 -- แสดงเฉพาะที่มี alter ได้
ORDER BY
    [Est. Bytes Saved/Row] DESC, -- เรียงตามความคุ้มค่าที่จะแก้
    SchemaName,
    TableName,
    ColumnName;
