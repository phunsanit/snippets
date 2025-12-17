WITH RawColumns AS (
    SELECT
        table_catalog AS DatabaseName,
        table_schema AS SchemaName,
        table_name AS TableName,
        column_name AS ColumnName,
        data_type AS DataType,
        -- จัดการเรื่อง DataSize
        CASE
            WHEN character_maximum_length IS NOT NULL THEN CAST(character_maximum_length AS VARCHAR)
            WHEN datetime_precision IS NOT NULL THEN CAST(datetime_precision AS VARCHAR)
            WHEN numeric_precision IS NOT NULL AND numeric_scale IS NOT NULL
                THEN CAST(numeric_precision AS VARCHAR) + ',' + CAST(numeric_scale AS VARCHAR)
            WHEN numeric_precision IS NOT NULL THEN CAST(numeric_precision AS VARCHAR)
            ELSE 'N/A'
        END AS DataSize,
        -- ตัด Prefix ออก (สมมติว่า prefix จบด้วย underscore เช่น 'pp_column_name')
        -- หากไม่มีขีดล่างจะใช้ชื่อเดิม
        CASE
            WHEN column_name LIKE '%_%' THEN SUBSTRING(column_name, CHARINDEX('_', column_name) + 1, LEN(column_name))
            ELSE column_name
        END AS CleanedColumnName
    FROM information_schema.columns
),
ColumnStats AS (
    -- นับว่าในแต่ละ CleanedColumnName มี Type หรือ Size ที่ต่างกันกี่แบบ
    SELECT
        CleanedColumnName,
        COUNT(DISTINCT DataType) AS DistinctTypes,
        COUNT(DISTINCT DataSize) AS DistinctSizes
    FROM RawColumns
    GROUP BY CleanedColumnName
)
SELECT
    r.DatabaseName,
    r.SchemaName,
    r.TableName,
    r.DatabaseName + '.' + r.SchemaName + '.' + r.TableName AS FullyQualifiedDomainName,
    r.ColumnName,
    r.CleanedColumnName,
    r.DataType,
    r.DataSize
FROM RawColumns r
JOIN ColumnStats s ON r.CleanedColumnName = s.CleanedColumnName
-- เงื่อนไข: แสดงเฉพาะ column ที่มี type หรือ size ไม่เหมือนเพื่อนในชื่อ cleaned เดียวกัน
WHERE s.DistinctTypes > 1 OR s.DistinctSizes > 1
ORDER BY
    r.CleanedColumnName,
    r.SchemaName,
    r.TableName;