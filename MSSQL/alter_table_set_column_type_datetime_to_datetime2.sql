/*
DATETIME2 เดิม ให้แนะนำ Precision 2 (6 bytes)
*/
SELECT
    DB_NAME() AS DatabaseName,
    s.name AS SchemaName,
    t.name AS TableName,
    'ALTER TABLE ' + QUOTENAME(DB_NAME()) + '.' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) +
    ' ALTER COLUMN ' + QUOTENAME(c.name) + ' datetime2(2);' AS alter_sql
FROM
    sys.columns AS c
JOIN
    sys.tables AS t ON c.object_id = t.object_id
JOIN
    sys.schemas AS s ON t.schema_id = s.schema_id
JOIN
    sys.types AS ty ON c.user_type_id = ty.user_type_id
WHERE
    ty.name = 'datetime';
