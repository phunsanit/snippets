/*
================================================================================
DATABASE COMPARISON SCRIPT
================================================================================
Fixes:
1. Resolved Error 4145 by changing FK Join logic to match on [Schema] + [ConstraintName].
2. Comparisons of 'ReferenceDetails' moved to WHERE/CASE clauses only.
3. Uses sys.schemas joins for accurate schema names across databases.
================================================================================
*/

-- Declare variables for the database names
DECLARE @db1 NVARCHAR(128) = 'DB_DEV';
DECLARE @db2 NVARCHAR(128) = 'DB_QA';

-- Use dynamic SQL to build the query
DECLARE @sql NVARCHAR(MAX);

-- ============================================================================
-- PART 1: COLUMN COMPARISON
-- ============================================================================
SET @sql = N'
    -- 1. COLUMN COMPARISON (Data Type and Nullability)
    SELECT
        ISNULL(c1.TABLE_SCHEMA, c2.TABLE_SCHEMA) AS TableSchema,
        ISNULL(c1.TABLE_NAME, c2.TABLE_NAME) AS TableName,
        ISNULL(c1.COLUMN_NAME, c2.COLUMN_NAME) AS ObjectName,
        ''COLUMN'' AS ObjectType,
        CASE
            WHEN c1.COLUMN_NAME IS NULL THEN ''Missing in ' + QUOTENAME(@db1) + '''
            WHEN c2.COLUMN_NAME IS NULL THEN ''Missing in ' + QUOTENAME(@db2) + '''
            WHEN c1.DATA_TYPE <> c2.DATA_TYPE THEN ''Data Type Mismatch''
            WHEN c1.IS_NULLABLE <> c2.IS_NULLABLE THEN ''Nullability Mismatch''
            ELSE ''Difference''
        END AS DifferenceType,
        c1.DATA_TYPE + '' (Null: '' + ISNULL(c1.IS_NULLABLE, '''') + '')'' AS ' + @db1 + '_Details,
        c2.DATA_TYPE + '' (Null: '' + ISNULL(c2.IS_NULLABLE, '''') + '')'' AS ' + @db2 + '_Details
    FROM ' + QUOTENAME(@db1) + '.INFORMATION_SCHEMA.COLUMNS c1
    FULL OUTER JOIN ' + QUOTENAME(@db2) + '.INFORMATION_SCHEMA.COLUMNS c2
        ON c1.TABLE_SCHEMA = c2.TABLE_SCHEMA
        AND c1.TABLE_NAME = c2.TABLE_NAME
        AND c1.COLUMN_NAME = c2.COLUMN_NAME
    WHERE (
            c1.COLUMN_NAME IS NULL
            OR c2.COLUMN_NAME IS NULL
            OR c1.DATA_TYPE <> c2.DATA_TYPE
            OR c1.IS_NULLABLE <> c2.IS_NULLABLE
        )
';

-- ============================================================================
-- PART 2: KEY CONSTRAINT COMPARISON (Append to @sql)
-- ============================================================================
SET @sql = @sql + N'
    UNION ALL

    SELECT
        ISNULL(k1.TABLE_SCHEMA, k2.TABLE_SCHEMA) AS TableSchema,
        ISNULL(k1.TABLE_NAME, k2.TABLE_NAME) AS TableName,
        ''KEY CONSTRAINT'' AS ObjectName,
        ISNULL(k1.CONSTRAINT_TYPE, k2.CONSTRAINT_TYPE) AS ObjectType,
        CASE
            WHEN k1.KeyColumns IS NULL THEN ''Missing ' + QUOTENAME(@db1) + ' ('' + ISNULL(k2.CONSTRAINT_TYPE, '''') + '')''
            WHEN k2.KeyColumns IS NULL THEN ''Missing ' + QUOTENAME(@db2) + ' ('' + ISNULL(k1.CONSTRAINT_TYPE, '''') + '')''
            WHEN k1.KeyColumns <> k2.KeyColumns THEN ''Column Set Mismatch''
            ELSE ''Constraint Exists But Differs''
        END AS DifferenceType,
        ISNULL(k1.KeyColumns, ''<N/A>'') AS ' + @db1 + '_Details,
        ISNULL(k2.KeyColumns, ''<N/A>'') AS ' + @db2 + '_Details
    FROM
    (
        SELECT
            c.TABLE_SCHEMA, c.TABLE_NAME, c.CONSTRAINT_TYPE, c.CONSTRAINT_NAME,
            STUFF((SELECT '', '' + k.COLUMN_NAME
                   FROM ' + QUOTENAME(@db1) + '.INFORMATION_SCHEMA.KEY_COLUMN_USAGE k
                   WHERE k.CONSTRAINT_NAME = c.CONSTRAINT_NAME
                   ORDER BY k.ORDINAL_POSITION
                   FOR XML PATH('''')), 1, 2, '''') AS KeyColumns
        FROM ' + QUOTENAME(@db1) + '.INFORMATION_SCHEMA.TABLE_CONSTRAINTS c
        WHERE c.CONSTRAINT_TYPE IN (''PRIMARY KEY'', ''UNIQUE'')
    ) k1
    FULL OUTER JOIN
    (
        SELECT
            c.TABLE_SCHEMA, c.TABLE_NAME, c.CONSTRAINT_TYPE, c.CONSTRAINT_NAME,
            STUFF((SELECT '', '' + k.COLUMN_NAME
                   FROM ' + QUOTENAME(@db2) + '.INFORMATION_SCHEMA.KEY_COLUMN_USAGE k
                   WHERE k.CONSTRAINT_NAME = c.CONSTRAINT_NAME
                   ORDER BY k.ORDINAL_POSITION
                   FOR XML PATH('''')), 1, 2, '''') AS KeyColumns
        FROM ' + QUOTENAME(@db2) + '.INFORMATION_SCHEMA.TABLE_CONSTRAINTS c
        WHERE c.CONSTRAINT_TYPE IN (''PRIMARY KEY'', ''UNIQUE'')
    ) k2
        ON k1.TABLE_SCHEMA = k2.TABLE_SCHEMA
        AND k1.TABLE_NAME = k2.TABLE_NAME
        AND k1.CONSTRAINT_TYPE = k2.CONSTRAINT_TYPE
        AND k1.KeyColumns = k2.KeyColumns
    WHERE k1.KeyColumns IS NULL OR k2.KeyColumns IS NULL OR k1.KeyColumns <> k2.KeyColumns OR k1.CONSTRAINT_TYPE <> k2.CONSTRAINT_TYPE
';

-- ============================================================================
-- PART 3: FOREIGN KEY COMPARISON (Append to @sql)
-- ============================================================================
SET @sql = @sql + N'
    UNION ALL

    SELECT
        ISNULL(fk1.SchemaName, fk2.SchemaName) AS TableSchema,
        ISNULL(fk1.TableName, fk2.TableName) AS TableName,
        ISNULL(fk1.name, fk2.name) AS ObjectName,
        ''FOREIGN KEY'' AS ObjectType,
        CASE
            WHEN fk1.ReferenceDetails IS NULL THEN ''Missing/Different in ' + QUOTENAME(@db1) + '''
            WHEN fk2.ReferenceDetails IS NULL THEN ''Missing/Different in ' + QUOTENAME(@db2) + '''
            ELSE ''Difference''
        END AS DifferenceType,
        ISNULL(fk1.ReferenceDetails, ''<N/A>'') AS ' + @db1 + '_Details,
        ISNULL(fk2.ReferenceDetails, ''<N/A>'') AS ' + @db2 + '_Details
    FROM (
        SELECT
            f.name,
            sch_t.name AS SchemaName,
            t.name AS TableName,
            sch_r.name + ''.'' + r.name + '' ('' +
            ISNULL(STUFF((SELECT '', '' + c_s.name
                   FROM ' + QUOTENAME(@db1) + '.sys.foreign_key_columns fkc
                   JOIN ' + QUOTENAME(@db1) + '.sys.columns c_s ON fkc.parent_object_id = c_s.object_id AND fkc.parent_column_id = c_s.column_id
                   WHERE fkc.constraint_object_id = f.object_id
                   ORDER BY fkc.constraint_column_id
                   FOR XML PATH('''')), 1, 2, ''''), ''?'')
            + '' -> '' +
            ISNULL(STUFF((SELECT '', '' + c_r.name
                   FROM ' + QUOTENAME(@db1) + '.sys.foreign_key_columns fkc
                   JOIN ' + QUOTENAME(@db1) + '.sys.columns c_r ON fkc.referenced_object_id = c_r.object_id AND fkc.referenced_column_id = c_r.column_id
                   WHERE fkc.constraint_object_id = f.object_id
                   ORDER BY fkc.constraint_column_id
                   FOR XML PATH('''')), 1, 2, ''''), ''?'')
            + '')'' AS ReferenceDetails
        FROM ' + QUOTENAME(@db1) + '.sys.foreign_keys f
        JOIN ' + QUOTENAME(@db1) + '.sys.tables t ON f.parent_object_id = t.object_id
        JOIN ' + QUOTENAME(@db1) + '.sys.schemas sch_t ON t.schema_id = sch_t.schema_id
        JOIN ' + QUOTENAME(@db1) + '.sys.tables r ON f.referenced_object_id = r.object_id
        JOIN ' + QUOTENAME(@db1) + '.sys.schemas sch_r ON r.schema_id = sch_r.schema_id
    ) fk1
    FULL OUTER JOIN (
        SELECT
            f.name,
            sch_t.name AS SchemaName,
            t.name AS TableName,
            sch_r.name + ''.'' + r.name + '' ('' +
            ISNULL(STUFF((SELECT '', '' + c_s.name
                   FROM ' + QUOTENAME(@db2) + '.sys.foreign_key_columns fkc
                   JOIN ' + QUOTENAME(@db2) + '.sys.columns c_s ON fkc.parent_object_id = c_s.object_id AND fkc.parent_column_id = c_s.column_id
                   WHERE fkc.constraint_object_id = f.object_id
                   ORDER BY fkc.constraint_column_id
                   FOR XML PATH('''')), 1, 2, ''''), ''?'')
            + '' -> '' +
            ISNULL(STUFF((SELECT '', '' + c_r.name
                   FROM ' + QUOTENAME(@db2) + '.sys.foreign_key_columns fkc
                   JOIN ' + QUOTENAME(@db2) + '.sys.columns c_r ON fkc.referenced_object_id = c_r.object_id AND fkc.referenced_column_id = c_r.column_id
                   WHERE fkc.constraint_object_id = f.object_id
                   ORDER BY fkc.constraint_column_id
                   FOR XML PATH('''')), 1, 2, ''''), ''?'')
            + '')'' AS ReferenceDetails
        FROM ' + QUOTENAME(@db2) + '.sys.foreign_keys f
        JOIN ' + QUOTENAME(@db2) + '.sys.tables t ON f.parent_object_id = t.object_id
        JOIN ' + QUOTENAME(@db2) + '.sys.schemas sch_t ON t.schema_id = sch_t.schema_id
        JOIN ' + QUOTENAME(@db2) + '.sys.tables r ON f.referenced_object_id = r.object_id
        JOIN ' + QUOTENAME(@db2) + '.sys.schemas sch_r ON r.schema_id = sch_r.schema_id
    ) fk2
        ON fk1.SchemaName = fk2.SchemaName
        AND fk1.TableName = fk2.TableName
        AND fk1.ReferenceDetails = fk2.ReferenceDetails
    WHERE
        fk1.ReferenceDetails IS NULL
        OR fk2.ReferenceDetails IS NULL

    ORDER BY TableSchema, TableName, ObjectType
';

-- Execute
EXEC sp_executesql @sql;
