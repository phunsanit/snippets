WITH ColumnPrefixes AS (
    SELECT
        s.name AS SchemaName,
        t.name AS TableName,
        c.name AS ColumnName,
        -- แก้ไขจุดที่ทำให้เกิด Error 537
        CASE
            WHEN CHARINDEX('_', c.name) > 0
            THEN LEFT(c.name, CHARINDEX('_', c.name) - 1)
            ELSE '[No Prefix]'
        END AS Prefix
    FROM sys.tables t
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    INNER JOIN sys.columns c ON t.object_id = c.object_id
    WHERE t.is_ms_shipped = 0
      AND t.name <> 'sysdiagrams'
),
PrefixStats AS (
    SELECT
        SchemaName,
        TableName,
        COUNT(DISTINCT Prefix) AS PrefixCount,
        -- ใช้ STRING_AGG (สำหรับ SQL 2017+) หรือ XML PATH (สำหรับ SQL รุ่นเก่า)
        STUFF((
            SELECT DISTINCT ', ' + cp2.Prefix
            FROM ColumnPrefixes cp2
            WHERE cp2.SchemaName = cp.SchemaName AND cp2.TableName = cp.TableName
            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, ''
        ) AS FoundPrefixes
    FROM ColumnPrefixes cp
    GROUP BY SchemaName, TableName
)
SELECT
    SchemaName,
    TableName,
    PrefixCount,
    FoundPrefixes
FROM PrefixStats
WHERE PrefixCount != 2
ORDER BY SchemaName, TableName;
