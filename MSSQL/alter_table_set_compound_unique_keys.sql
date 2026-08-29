SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    i.name AS IndexName,
    COUNT(ic.column_id) AS ColumnCount,
    STRING_AGG(c.name, ', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS Columns,

    -- Adds a UQ *in addition* to the old index
    N'ALTER TABLE ' + QUOTENAME(SCHEMA_NAME(t.schema_id)) + N'.' + QUOTENAME(t.name) +
    N' ADD CONSTRAINT ' + QUOTENAME(N'UQ_' + i.name) +  -- Naming convention: UQ_<OldIndexName>
    N' UNIQUE (' +
    STRING_AGG(QUOTENAME(c.name), N', ') WITHIN GROUP (ORDER BY ic.key_ordinal) +
    N');' AS Add_UQ_Script,

    -- (Recommended): *Replaces* the old index with a UQ
    N'DROP INDEX ' + QUOTENAME(i.name) + N' ON ' + QUOTENAME(SCHEMA_NAME(t.schema_id)) + N'.' + QUOTENAME(t.name) + N';' +
    N' ALTER TABLE ' + QUOTENAME(SCHEMA_NAME(t.schema_id)) + N'.' + QUOTENAME(t.name) +
    N' ADD CONSTRAINT ' + QUOTENAME(N'UQ_' + i.name) +
    N' UNIQUE (' +
    STRING_AGG(QUOTENAME(c.name), N', ') WITHIN GROUP (ORDER BY ic.key_ordinal) +
    N');' AS Replace_With_UQ_Script
FROM
    sys.indexes AS i
JOIN
    sys.tables AS t ON i.object_id = t.object_id
JOIN
    sys.index_columns AS ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
JOIN
    sys.columns AS c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
WHERE
    i.is_unique = 0         -- Filter for NON-unique indexes
    AND i.is_primary_key = 0  -- Exclude Primary Keys
    AND i.type_desc != 'HEAP'
GROUP BY
    SCHEMA_NAME(t.schema_id),
    t.name,
    i.name
HAVING
    COUNT(ic.column_id) > 1  -- Find only those with more than one column
ORDER BY
    SchemaName,
    TableName;