SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    kc.name AS ConstraintName,
    COUNT(ic.column_id) AS ColumnCount,
    STRING_AGG(c.name, ', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS Columns
FROM
    sys.key_constraints AS kc
JOIN
    sys.tables AS t ON kc.parent_object_id = t.object_id
JOIN
    sys.index_columns AS ic ON ic.object_id = t.object_id AND ic.index_id = kc.unique_index_id
JOIN
    sys.columns AS c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
WHERE
    kc.type = 'PK'  -- Filter for Primary Keys
GROUP BY
    SCHEMA_NAME(t.schema_id),
    t.name,
    kc.name
HAVING
    COUNT(ic.column_id) > 1  -- Find only those with more than one column
ORDER BY
    SchemaName,
    TableName;
