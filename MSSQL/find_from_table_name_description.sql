DECLARE @search NVARCHAR(max) = '%Pitt%';

SELECT
    DB_NAME() AS DatabaseName,
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    CAST(ep_t.value AS NVARCHAR(MAX)) AS TableDescription,

    -- New Columns Requested
    c.column_id AS ColumnOrder,
    c.name AS ColumnName,
    CAST(ep_c.value AS NVARCHAR(MAX)) AS ColumnDescription,

    -- Combined Name for reference
DB_NAME() + '.' + SCHEMA_NAME(t.schema_id) + '.' + t.name + '.' + c.name AS FullyQualifiedObjectName
FROM
    sys.tables t
INNER JOIN
    sys.columns c
    ON
t.object_id = c.object_id
-- Join for TABLE Description (minor_id = 0)
LEFT JOIN
    sys.extended_properties ep_t
    ON
t.object_id = ep_t.major_id
AND ep_t.minor_id = 0
AND ep_t.name = 'MS_Description'
-- Join for COLUMN Description (minor_id = column_id)
LEFT JOIN
    sys.extended_properties ep_c
    ON
c.object_id = ep_c.major_id
AND c.column_id = ep_c.minor_id
AND ep_c.name = 'MS_Description'
WHERE
    t.name LIKE @search
OR CAST(ep_t.value AS NVARCHAR(MAX)) LIKE @search
OR c.name LIKE @search
OR CAST(ep_c.value AS NVARCHAR(MAX)) LIKE @search
ORDER BY
    SchemaName
    ,TableName
    ,ColumnOrder;
