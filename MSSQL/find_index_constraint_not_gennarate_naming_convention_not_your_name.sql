-- 1. ประกาศและตั้งค่าตัวแปรสำหรับกรองชื่อตาราง
DECLARE @TableNameFilter NVARCHAR(100);
SET @TableNameFilter = '%_%'; -- แก้ไขเงื่อนไขของคุณที่นี่ที่เดียว

-- 2. ใช้ Common Table Expression (CTE) เพื่อรวมผลลัพธ์
;WITH AllObjectsToRename AS (

    -- ส่วนที่ 1: ค้นหา Constraints (PK, FK, UQ, DF, CK) ที่ชื่อผิด
    SELECT
        s.name AS SchemaName,
        t.name AS TableName,
        o.name AS OldName,
        o.type_desc AS ObjectType,

        (CASE o.type
            WHEN 'PK' THEN 'PK_' + t.name
            WHEN 'F'  THEN 'FK_' + t.name + '_' + o.name
            WHEN 'UQ' THEN 'UQ_' + t.name + '_' + o.name
            WHEN 'D'  THEN 'DF_' + t.name + '_' + o.name
            WHEN 'C'  THEN 'CK_' + t.name + '_' + o.name
            ELSE o.name
        END) AS ProposedNewName,

        'EXEC sp_rename N''' + QUOTENAME(s.name) + '.' + QUOTENAME(o.name) + ''', N''' +
        (CASE o.type
            WHEN 'PK' THEN 'PK_' + t.name
            WHEN 'F'  THEN 'FK_' + t.name + '_' + o.name
            WHEN 'UQ' THEN 'UQ_' + t.name + '_' + o.name
            WHEN 'D'  THEN 'DF_' + t.name + '_' + o.name
            WHEN 'C'  THEN 'CK_' + t.name + '_' + o.name
            ELSE o.name
        END)
        + ''', N''OBJECT'';' AS RenameScript
    FROM
        sys.objects AS o
    JOIN
        sys.tables AS t ON o.parent_object_id = t.object_id
    JOIN
        sys.schemas AS s ON t.schema_id = s.schema_id
    WHERE
        o.is_ms_shipped = 0
        AND o.type IN ('PK', 'F', 'UQ', 'D', 'C')
        AND t.name LIKE @TableNameFilter
        AND (
            (o.type = 'PK' AND o.name NOT LIKE 'PK_%') OR
            (o.type = 'F'  AND o.name NOT LIKE 'FK_%') OR
            (o.type = 'UQ' AND o.name NOT LIKE 'UQ_%') OR
            (o.type = 'D'  AND o.name NOT LIKE 'DF_%') OR
            (o.type = 'C'  AND o.name NOT LIKE 'CK_%')
        )

    UNION ALL

    -- ส่วนที่ 2: ค้นหา Indexes (IX) ที่ชื่อผิด
    SELECT
        s.name AS SchemaName,
        t.name AS TableName,
        i.name AS OldName,
        i.type_desc AS ObjectType,

        'IX_' + t.name + '_' + i.name AS ProposedNewName,

        'EXEC sp_rename N''' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + '.' + QUOTENAME(i.name) + ''', N''' +
        'IX_' + t.name + '_' + i.name +
        ''', N''INDEX'';' AS RenameScript
    FROM
        sys.indexes AS i
    JOIN
        sys.tables AS t ON i.object_id = t.object_id
    JOIN
        sys.schemas AS s ON t.schema_id = s.schema_id
    WHERE
        i.is_primary_key = 0
        AND i.is_unique_constraint = 0
        AND i.type_desc != 'HEAP'
        AND t.is_ms_shipped = 0
        AND i.name IS NOT NULL
        AND t.name LIKE @TableNameFilter
        AND i.name NOT LIKE 'IX_%'
)
-- 3. สั่ง SELECT และ ORDER BY จาก CTE ด้านบน
SELECT
    SchemaName,
    TableName,
    OldName,
    ObjectType,
    ProposedNewName,
    RenameScript
FROM
    AllObjectsToRename
ORDER BY
    SchemaName, TableName, ObjectType, OldName;
