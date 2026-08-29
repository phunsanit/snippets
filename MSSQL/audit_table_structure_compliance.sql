WITH RequiredColumns AS (
    -- กำหนดรายการคอลัมน์มาตรฐานที่ต้องมี
    SELECT col FROM (VALUES
        ('id'),
        ('created_by'),
        ('created_date'),
        ('deleted_by'),
        ('deleted_date'),
        ('updated_by'),
        ('updated_date')
    ) AS t(col)
),
TableList AS (
    -- ดึงรายชื่อตารางทั้งหมดที่ไม่ใช่ System Tables
    SELECT
        t.object_id,
        s.name AS SchemaName,
        t.name AS TableName
    FROM sys.tables t
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE t.is_ms_shipped = 0 -- ไม่รวมตารางของระบบ
      AND t.name <> 'sysdiagrams'
),
CheckAudit AS (
    -- ตรวจสอบว่าในแต่ละตาราง มีคอลัมน์ไหนอยู่บ้าง
    SELECT
        tl.SchemaName,
        tl.TableName,
        rc.col AS RequiredColumn,
        CASE WHEN c.column_id IS NOT NULL THEN 1 ELSE 0 END AS HasColumn
    FROM TableList tl
    CROSS JOIN RequiredColumns rc -- เอาตารางตั้งต้น x รายชื่อคอลัมน์ที่ต้องมี
    LEFT JOIN sys.columns c ON tl.object_id = c.object_id AND rc.col = c.name
)
SELECT
    SchemaName,
    TableName,
    CASE
        WHEN MIN(HasColumn) = 1 THEN 'PASS'
        ELSE 'FAIL'
    END AS Status,
    -- รวบรวมรายชื่อคอลัมน์ที่ขาด (Missing Columns)
    STUFF((
        SELECT ', ' + ca2.RequiredColumn
        FROM CheckAudit ca2
        WHERE ca2.SchemaName = ca.SchemaName
          AND ca2.TableName = ca.TableName
          AND ca2.HasColumn = 0
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, ''
    ) AS MissingColumns
FROM CheckAudit ca
GROUP BY SchemaName, TableName
ORDER BY Status, SchemaName, TableName;
