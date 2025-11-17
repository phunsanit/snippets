/*
-- 1. Primary Keys & Unique Constraints
*/
SELECT
    s.name AS SchemaName,
    t.name AS TableName,
    kc.name AS ObjectName,
    kc.type_desc AS ObjectType, -- 'PRIMARY_KEY_CONSTRAINT' or 'UNIQUE_CONSTRAINT'
    NULL AS RelatedColumn,
    NULL AS Definition
FROM
    sys.key_constraints AS kc
INNER JOIN
    sys.tables AS t ON kc.parent_object_id = t.object_id
INNER JOIN
    sys.schemas AS s ON t.schema_id = s.schema_id
WHERE
    kc.is_system_named = 0

UNION ALL

/*
-- 2. Foreign Keys
*/
SELECT
    s.name AS SchemaName,
    t.name AS TableName,
    fk.name AS ObjectName,
    'FOREIGN_KEY_CONSTRAINT' AS ObjectType,
    NULL AS RelatedColumn, -- FKs can span multiple columns
    NULL AS Definition
FROM
    sys.foreign_keys AS fk
INNER JOIN
    sys.tables AS t ON fk.parent_object_id = t.object_id
INNER JOIN
    sys.schemas AS s ON t.schema_id = s.schema_id
WHERE
    fk.is_system_named = 0

UNION ALL

/*
-- 3. Check Constraints
*/
SELECT
    s.name AS SchemaName,
    t.name AS TableName,
    cc.name AS ObjectName,
    'CHECK_CONSTRAINT' AS ObjectType,
    c.name AS RelatedColumn, -- Column name if it's a column-level check
    cc.definition AS Definition
FROM
    sys.check_constraints AS cc
INNER JOIN
    sys.tables AS t ON cc.parent_object_id = t.object_id
INNER JOIN
    sys.schemas AS s ON t.schema_id = s.schema_id
LEFT JOIN
    sys.columns AS c ON cc.parent_object_id = c.object_id AND cc.parent_column_id = c.column_id
WHERE
    cc.is_system_named = 0

UNION ALL

/*
-- 4. Default Constraints (From your original query)
*/
SELECT
    s.name AS SchemaName,
    t.name AS TableName,
    dc.name AS ObjectName,
    'DEFAULT_CONSTRAINT' AS ObjectType,
    c.name AS RelatedColumn,
    dc.definition AS Definition
FROM
    sys.default_constraints AS dc
INNER JOIN
    sys.tables AS t ON dc.parent_object_id = t.object_id
INNER JOIN
    sys.schemas AS s ON t.schema_id = s.schema_id
INNER JOIN
    sys.columns AS c ON dc.parent_object_id = c.object_id AND dc.parent_column_id = c.column_id
WHERE
    dc.is_system_named = 0

ORDER BY
    SchemaName, TableName, ObjectType, ObjectName;