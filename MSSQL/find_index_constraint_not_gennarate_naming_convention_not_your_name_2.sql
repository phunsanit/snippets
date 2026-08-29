DECLARE @TableNameFilter NVARCHAR(100);
SET @TableNameFilter = '%_%'; -- แก้ไขชื่อตารางที่ต้องการกรองตรงนี้

;WITH AllObjectsToRename AS (
    -- 1. PRIMARY KEY (PK_<TableName>)
    -- PK มีได้แค่อันเดียวต่อตาราง ไม่ต้องใส่ชื่อ Column
    SELECT
        s.name AS SchemaName,
        t.name AS TableName,
        kc.name AS OldName,
        'PK' AS ObjectType,
        'PK_' + t.name AS ProposedNewName,
        'EXEC sp_rename N''' + QUOTENAME(s.name) + '.' + QUOTENAME(kc.name) + ''', N''' + 'PK_' + t.name + ''', N''OBJECT'';' AS RenameScript
    FROM sys.key_constraints kc
    JOIN sys.tables t ON kc.parent_object_id = t.object_id
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE kc.type = 'PK'
      AND t.name LIKE @TableNameFilter
      AND kc.name <> 'PK_' + t.name

    UNION ALL

    -- 2. DEFAULT CONSTRAINT (DF_<TableName>_<ColumnName>)
    SELECT
        s.name,
        t.name,
        dc.name,
        'DF',
        'DF_' + t.name + '_' + c.name,
        'EXEC sp_rename N''' + QUOTENAME(s.name) + '.' + QUOTENAME(dc.name) + ''', N''' + 'DF_' + t.name + '_' + c.name + ''', N''OBJECT'';'
    FROM sys.default_constraints dc
    JOIN sys.tables t ON dc.parent_object_id = t.object_id
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    JOIN sys.columns c ON dc.parent_object_id = c.object_id AND dc.parent_column_id = c.column_id
    WHERE t.name LIKE @TableNameFilter
      AND dc.name <> 'DF_' + t.name + '_' + c.name

    UNION ALL

    -- 3. CHECK CONSTRAINT (CK_<TableName>_<ColumnName>)
    -- ดึงคอลัมน์แรกที่เจอมาตั้งชื่อ
    SELECT
        s.name,
        t.name,
        cc.name,
        'CK',
        'CK_' + t.name + '_' + c.name,
        'EXEC sp_rename N''' + QUOTENAME(s.name) + '.' + QUOTENAME(cc.name) + ''', N''' + 'CK_' + t.name + '_' + c.name + ''', N''OBJECT'';'
    FROM sys.check_constraints cc
    JOIN sys.tables t ON cc.parent_object_id = t.object_id
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    -- ใช้ CROSS APPLY เพื่อดึง 1 คอลัมน์ที่เกี่ยวข้องกับ Check นี้
    CROSS APPLY (
        SELECT TOP 1 col.name
        FROM sys.columns col
        WHERE col.object_id = t.object_id AND col.column_id = cc.parent_column_id
    ) c
    WHERE t.name LIKE @TableNameFilter
      AND cc.name <> 'CK_' + t.name + '_' + c.name

    UNION ALL

    -- 4. FOREIGN KEY (FK_<SourceTable>_<TargetTable>_<SourceColumnName>)
    -- สูตร: FK + ตารางต้นทาง + ตารางปลายทาง + คอลัมน์ต้นทาง
    SELECT
        s.name,
        t.name,
        fk.name,
        'FK',
        'FK_' + t.name + '_' + rt.name + '_' + c.name,
        'EXEC sp_rename N''' + QUOTENAME(s.name) + '.' + QUOTENAME(fk.name) + ''', N''' + 'FK_' + t.name + '_' + rt.name + '_' + c.name + ''', N''OBJECT'';'
    FROM sys.foreign_keys fk
    JOIN sys.tables t ON fk.parent_object_id = t.object_id
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    JOIN sys.tables rt ON fk.referenced_object_id = rt.object_id -- Referenced Table
    -- ใช้ CROSS APPLY ดึงคอลัมน์แรก (Source Column) ที่ทำ FK
    CROSS APPLY (
        SELECT TOP 1 col.name
        FROM sys.foreign_key_columns fkc
        JOIN sys.columns col ON fkc.parent_column_id = col.column_id AND fkc.parent_object_id = col.object_id
        WHERE fkc.constraint_object_id = fk.object_id
        ORDER BY fkc.constraint_column_id
    ) c
    WHERE t.name LIKE @TableNameFilter
      AND fk.name <> 'FK_' + t.name + '_' + rt.name + '_' + c.name

    UNION ALL

    -- 5. INDEXES (IX_<TableName>_<ColumnName>)
    -- ไม่รวม PK และ Unique Key (เพราะ Unique Key มักจะตั้งชื่อ UQ_)
    SELECT
        s.name,
        t.name,
        i.name,
        'INDEX',
        'IX_' + t.name + '_' + c.name,
        'EXEC sp_rename N''' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + '.' + QUOTENAME(i.name) + ''', N''' + 'IX_' + t.name + '_' + c.name + ''', N''INDEX'';'
    FROM sys.indexes i
    JOIN sys.tables t ON i.object_id = t.object_id
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    -- ใช้ CROSS APPLY ดึงคอลัมน์แรกของ Index นั้นๆ
    CROSS APPLY (
        SELECT TOP 1 col.name
        FROM sys.index_columns ic
        JOIN sys.columns col ON ic.column_id = col.column_id AND ic.object_id = col.object_id
        WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id
        ORDER BY ic.key_ordinal, ic.index_column_id
    ) c
    WHERE i.is_primary_key = 0
      AND i.is_unique_constraint = 0
      AND i.type_desc <> 'HEAP' -- ไม่เอา Heap
      AND t.name LIKE @TableNameFilter
      AND i.name <> 'IX_' + t.name + '_' + c.name
)
SELECT
    SchemaName, TableName, ObjectType, OldName, ProposedNewName, RenameScript
FROM AllObjectsToRename
ORDER BY SchemaName, TableName, ObjectType;
