SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    fk.name AS ConstraintName,
    COUNT(fkc.parent_column_id) AS ColumnCount,
    STRING_AGG(c.name, ', ') WITHIN GROUP (ORDER BY fkc.constraint_column_id) AS Columns
FROM
    sys.foreign_keys AS fk
JOIN
    sys.tables AS t ON fk.parent_object_id = t.object_id
JOIN
    sys.foreign_key_columns AS fkc ON fkc.constraint_object_id = fk.object_id
JOIN
    sys.columns AS c ON c.object_id = fkc.parent_object_id AND c.column_id = fkc.parent_column_id
GROUP BY
    SCHEMA_NAME(t.schema_id),
    t.name,
    fk.name
HAVING
    COUNT(fkc.parent_column_id) > 1  -- Find only those with more than one column
ORDER BY
    SchemaName,
    TableName;