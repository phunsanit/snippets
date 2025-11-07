SELECT
    FK.name AS ForeignKeyName,
    SCHEMA_NAME(PT.schema_id) AS ParentSchema,
    PT.name AS ParentTable,
    PC.name AS ParentColumn,
    'References' AS Relationship,
    SCHEMA_NAME(RT.schema_id) AS ReferencedSchema,
    RT.name AS ReferencedTable,
    RC.name AS ReferencedColumn
FROM
    sys.foreign_keys FK
INNER JOIN
    sys.foreign_key_columns FKC ON FK.object_id = FKC.constraint_object_id
INNER JOIN
    sys.tables PT ON FK.parent_object_id = PT.object_id -- Parent Table (the one with the FK)
INNER JOIN
    sys.columns PC ON FKC.parent_object_id = PC.object_id AND FKC.parent_column_id = PC.column_id -- Parent Column
INNER JOIN
    sys.tables RT ON FK.referenced_object_id = RT.object_id -- Referenced Table (the one with the PK)
INNER JOIN
    sys.columns RC ON FKC.referenced_object_id = RC.object_id AND FKC.referenced_column_id = RC.column_id -- Referenced Column
ORDER BY
    ParentTable, ReferencedTable;