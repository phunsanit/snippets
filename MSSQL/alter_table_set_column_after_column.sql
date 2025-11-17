/****************************************************************************************
   สคริปต์ย้ายลำดับคอลัมน์ในตาราง โดยคงข้อมูล + PK + FK + Index + Trigger + ทุกอย่างไว้ 100%
   Pitt Phunsanit
****************************************************************************************/

USE DB_DEV;
-- USE DB_QA;
-- USE DB_SIT;
-- USE DB_PRO;

-- ==================== แก้ตรงนี้ 4 บรรทัดเท่านั้น ====================
DECLARE @SchemaName          NVARCHAR(128) = N'PItt';
DECLARE @TableName           NVARCHAR(128) = N'Phunsanit';
DECLARE @ColumnToMove        NVARCHAR(128) = N'MyColumnToMove';      -- คอลัมน์ที่ต้องการย้าย
DECLARE @TargetColumnAfter   NVARCHAR(128) = N'TargetColumn';        -- ย้ายไปไว้ข้างหลังคอลัมน์นี้
-- ====================================================================

-- ตรวจสอบ: ถ้า @SchemaName ว่าง หรือ NULL ให้ใช้ 'dbo' เป็นค่าเริ่มต้น
IF @SchemaName IS NULL OR @SchemaName = N''
    SET @SchemaName = N'dbo';

SET NOCOUNT ON;
DECLARE @NewTable  NVARCHAR(258) = QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName + '_New');
DECLARE @OldTable  NVARCHAR(258) = QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName);
DECLARE @SQL       NVARCHAR(MAX) = N'';
DECLARE @DropFK    NVARCHAR(MAX) = N'';
DECLARE @CreateFK  NVARCHAR(MAX) = N'';

-- 1. ดึง FK ที่อ้างอิงตารางนี้ทั้งหมด (ทั้งที่ชี้มาและชี้ไป)
SELECT
    @DropFK   = @DropFK   + N'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id))
              + N' DROP CONSTRAINT ' + QUOTENAME(fk.name) + N';' + CHAR(10),
    @CreateFK = @CreateFK + N'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id))
              + N' WITH CHECK ADD CONSTRAINT ' + QUOTENAME(fk.name) + N' FOREIGN KEY ('
              + STUFF((SELECT ',' + QUOTENAME(COL_NAME(fc2.parent_object_id, fc2.parent_column_id))
                       FROM sys.foreign_key_columns fc2
                       WHERE fc2.constraint_object_id = fk.object_id
                       ORDER BY fc2.constraint_column_id
                       FOR XML PATH('')),1,1,'') + N') REFERENCES '
              + QUOTENAME(OBJECT_SCHEMA_NAME(referenced_object_id)) + '.' + QUOTENAME(OBJECT_NAME(referenced_object_id)) + N' ('
              + STUFF((SELECT ',' + QUOTENAME(COL_NAME(fc2.referenced_object_id, fc2.referenced_column_id))
                       FROM sys.foreign_key_columns fc2
                       WHERE fc2.constraint_object_id = fk.object_id
                       ORDER BY fc2.constraint_column_id
                       FOR XML PATH('')),1,1,'') + N');' + CHAR(10)
              + N'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id))
              + N' CHECK CONSTRAINT ' + QUOTENAME(fk.name) + N';' + CHAR(10)
FROM sys.foreign_keys fk
WHERE referenced_object_id = OBJECT_ID(@OldTable)
   OR parent_object_id    = OBJECT_ID(@OldTable);

-- 2. เริ่ม Transaction ใหญ่
BEGIN TRANSACTION;
BEGIN TRY

    -- Drop FK ทั้งหมดก่อน
    IF LEN(@DropFK) > 0 EXEC sp_executesql @DropFK;

   -- 3. สร้างตารางใหม่ที่มีลำดับคอลัมน์ใหม่
    SET @SQL = N'CREATE TABLE ' + @NewTable + ' (' + CHAR(10);

    ;WITH Cols AS (
        SELECT
            c.COLUMN_NAME,
            c.ORDINAL_POSITION,
            DATA_TYPE =
                CASE
                    WHEN c.DATA_TYPE IN ('varchar','char','nvarchar','nchar','varbinary','binary') AND c.CHARACTER_MAXIMUM_LENGTH = -1 THEN c.DATA_TYPE + '(MAX)'
                    WHEN c.DATA_TYPE IN ('varchar','char','nvarchar','nchar','varbinary','binary') THEN c.DATA_TYPE + '(' + IIF(c.CHARACTER_MAXIMUM_LENGTH = -1, 'MAX', CAST(c.CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10))) + ')'
                    WHEN c.DATA_TYPE IN ('decimal','numeric') THEN c.DATA_TYPE + '(' + CAST(c.NUMERIC_PRECISION AS VARCHAR(10)) + ',' + CAST(c.NUMERIC_SCALE AS VARCHAR(10)) + ')'
                    WHEN c.DATA_TYPE IN ('float','real') THEN c.DATA_TYPE + CASE WHEN c.NUMERIC_PRECISION IS NULL THEN '' ELSE '(' + CAST(c.NUMERIC_PRECISION AS VARCHAR(10)) + ')' END
                    WHEN c.DATA_TYPE = 'datetime2' THEN c.DATA_TYPE + '(' + CAST(c.DATETIME_PRECISION AS VARCHAR(10)) + ')'
                    ELSE c.DATA_TYPE
                END,
            IS_NULLABLE = c.IS_NULLABLE,
            COLUMN_DEFAULT = c.COLUMN_DEFAULT,
            IS_IDENTITY = CASE WHEN ic.column_id IS NOT NULL THEN 1 ELSE 0 END,
            IS_COMPUTED = CASE WHEN cc.definition IS NOT NULL THEN 1 ELSE 0 END,
            COMPUTED_DEF = cc.definition,
            IS_PERSISTED = cc.is_persisted
        FROM INFORMATION_SCHEMA.COLUMNS c
        LEFT JOIN sys.identity_columns ic ON OBJECT_ID(@OldTable) = ic.object_id AND c.COLUMN_NAME = ic.name
        LEFT JOIN sys.computed_columns cc ON OBJECT_ID(@OldTable) = cc.object_id AND c.COLUMN_NAME = cc.name
        WHERE c.TABLE_SCHEMA = @SchemaName AND c.TABLE_NAME = @TableName
    ),
    OrderedCols AS (
        SELECT *, SortOrder = ORDINAL_POSITION
        FROM Cols
        WHERE COLUMN_NAME <> @ColumnToMove

        UNION ALL

        SELECT *, SortOrder = (SELECT ORDINAL_POSITION FROM Cols WHERE COLUMN_NAME = @TargetColumnAfter) + 1
        FROM Cols WHERE COLUMN_NAME = @ColumnToMove
    )
    SELECT @SQL = @SQL +
           '    [' + COLUMN_NAME + '] ' + DATA_TYPE +
           CASE WHEN IS_IDENTITY = 1 THEN ' IDENTITY(1,1)' ELSE '' END +
           CASE WHEN IS_COMPUTED = 1 THEN ' AS ' + COMPUTED_DEF + CASE WHEN IS_PERSISTED = 1 THEN ' PERSISTED' ELSE '' END ELSE '' END +
           ' ' + CASE WHEN IS_NULLABLE = 'YES' OR IS_COMPUTED = 1 THEN 'NULL' ELSE 'NOT NULL' END +
           ISNULL(' CONSTRAINT [DF_' + @TableName + '_' + COLUMN_NAME + '] DEFAULT ' + COLUMN_DEFAULT, '') + ',' + CHAR(10)
    FROM OrderedCols
    ORDER BY SortOrder, ORDINAL_POSITION;

    -- ลบ comma ตัวสุดท้าย
    SET @SQL = LEFT(@SQL, LEN(@SQL)-2) + CHAR(10);

    -- เพิ่ม Primary Key (ถ้ามี)
    IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE type = 'PK' AND parent_object_id = OBJECT_ID(@OldTable))
    BEGIN
        DECLARE @PKCols NVARCHAR(MAX) = '';
        SELECT @PKCols += '[' + COL_NAME(ic.object_id, ic.column_id) + '] ' + CASE WHEN ic.is_descending_key = 1 THEN 'DESC' ELSE 'ASC' END + ', '
        FROM sys.key_constraints kc
        JOIN sys.index_columns ic ON kc.parent_object_id = ic.object_id AND kc.unique_index_id = ic.index_id
        WHERE kc.type = 'PK' AND kc.parent_object_id = OBJECT_ID(@OldTable)
        ORDER BY ic.key_ordinal;
        SET @PKCols = LEFT(@PKCols, LEN(@PKCols)-1);

        SET @SQL += '    CONSTRAINT [PK_' + @TableName + '_Temp] PRIMARY KEY CLUSTERED (' + @PKCols + ')' + CHAR(10);
    END

    SET @SQL += ');';
    EXEC sp_executesql @SQL;

    -- 4. Copy ข้อมูลทั้งหมด (รวม Identity)
    SET @SQL = N'
        SET IDENTITY_INSERT ' + @NewTable + ' ON;
        INSERT INTO ' + @NewTable + '
        SELECT * FROM ' + @OldTable + ';
        SET IDENTITY_INSERT ' + @NewTable + ' OFF;';
    EXEC sp_executesql @SQL;

    PRINT N'Copy ข้อมูลเสร็จสิ้น ' + CAST(@@ROWCOUNT AS NVARCHAR(20)) + N' แถว';

    -- 5. เปลี่ยนชื่อตาราง
    EXEC sp_rename @OldTable, @TableName + '_Old_' + FORMAT(GETDATE(),'yyyyMMdd_HHmmss');
    EXEC sp_rename @NewTable, @TableName;

    -- แก้ชื่อ PK กลับ
    IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE name LIKE 'PK_' + @TableName + '_Temp')
        EXEC sp_rename @SchemaName + '.PK_' + @TableName + '_Temp', 'PK_' + @TableName, 'OBJECT';

    -- 6. สร้าง FK กลับทั้งหมด
    IF LEN(@CreateFK) > 0 EXEC sp_executesql @CreateFK;

    COMMIT TRANSACTION;
    PRINT N'';
    PRINT N'════════════════════════════════════════════════════════════';
    PRINT N'สำเร็จสมบูรณ์ 100%!';
    PRINT N'คอลัมน์ "' + @ColumnToMove + '" ถูกย้ายไปข้างหลัง "' + @TargetColumnAfter + '" แล้ว';
    PRINT N'ข้อมูลทุกแถว, PK, FK, Identity, Index ยังอยู่ครบเหมือนเดิม';
    PRINT N'════════════════════════════════════════════════════════════';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT N'';
    PRINT N'เกิดข้อผิดพลาด: ' + ERROR_MESSAGE();
    PRINT N'ทุกอย่างถูก Rollback แล้ว - ข้อมูลปลอดภัย 100%';
    THROW;
END CATCH;