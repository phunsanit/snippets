-- Declare variables for the database names
DECLARE @db1 NVARCHAR(128) = 'DB_DEV';
DECLARE @db2 NVARCHAR(128) = 'DB_QA';

-- Use dynamic SQL to build the query
DECLARE @sql NVARCHAR(MAX);

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

    UNION ALL

    -- 2. PRIMARY KEY / UNIQUE CONSTRAINT COMPARISON (Based on the set of columns)
    WITH
    DB1_KEYS AS (
        SELECT
            c.TABLE_SCHEMA, c.TABLE_NAME, c.CONSTRAINT_TYPE,
            STRING_AGG(k.COLUMN_NAME, '', '') WITHIN GROUP (ORDER BY k.ORDINAL_POSITION) AS KeyColumns
        FROM ' + QUOTENAME(@db1) + '.INFORMATION_SCHEMA.TABLE_CONSTRAINTS c
        INNER JOIN ' + QUOTENAME(@db1) + '.INFORMATION_SCHEMA.KEY_COLUMN_USAGE k
            ON c.CONSTRAINT_NAME = k.CONSTRAINT_NAME AND c.TABLE_NAME = k.TABLE_NAME AND c.TABLE_SCHEMA = k.TABLE_SCHEMA
        WHERE c.CONSTRAINT_TYPE IN (''PRIMARY KEY'', ''UNIQUE'')
        GROUP BY c.TABLE_SCHEMA, c.TABLE_NAME, c.CONSTRAINT_TYPE
    ),
    DB2_KEYS AS (
        SELECT
            c.TABLE_SCHEMA, c.TABLE_NAME, c.CONSTRAINT_TYPE,
            STRING_AGG(k.COLUMN_NAME, '', '') WITHIN GROUP (ORDER BY k.ORDINAL_POSITION) AS KeyColumns
        FROM ' + QUOTENAME(@db2) + '.INFORMATION_SCHEMA.TABLE_CONSTRAINTS c
        INNER JOIN ' + QUOTENAME(@db2) + '.INFORMATION_SCHEMA.KEY_COLUMN_USAGE k
            ON c.CONSTRAINT_NAME = k.CONSTRAINT_NAME AND c.TABLE_NAME = k.TABLE_NAME AND c.TABLE_SCHEMA = k.TABLE_SCHEMA
        WHERE c.CONSTRAINT_TYPE IN (''PRIMARY KEY'', ''UNIQUE'')
        GROUP BY c.TABLE_SCHEMA, c.TABLE_NAME, c.CONSTRAINT_TYPE
    )
    SELECT
        ISNULL(k1.TABLE_SCHEMA, k2.TABLE_SCHEMA) AS TableSchema,
        ISNULL(k1.TABLE_NAME, k2.TABLE_NAME) AS TableName,
        ''KEY CONSTRAINT'' AS ObjectName,
        ISNULL(k1.CONSTRAINT_TYPE, k2.CONSTRAINT_TYPE) AS ObjectType,
        CASE
            WHEN k1.KeyColumns IS NULL THEN ''Missing '' + QUOTENAME(@db1) + '' ('' + ISNULL(k2.CONSTRAINT_TYPE, '''') + '')''
            WHEN k2.KeyColumns IS NULL THEN ''Missing '' + QUOTENAME(@db2) + '' ('' + ISNULL(k1.CONSTRAINT_TYPE, '''') + '')''
            WHEN k1.KeyColumns <> k2.KeyColumns THEN ''Column Set Mismatch''
            ELSE ''Constraint Exists But Differs'' -- Should not happen with the join keys
        END AS DifferenceType,
        ISNULL(k1.KeyColumns, ''<N/A>'') AS ' + @db1 + '_Details,
        ISNULL(k2.KeyColumns, ''<N/A>'') AS ' + @db2 + '_Details
    FROM DB1_KEYS k1
    FULL OUTER JOIN DB2_KEYS k2
        ON k1.TABLE_SCHEMA = k2.TABLE_SCHEMA
        AND k1.TABLE_NAME = k2.TABLE_NAME
        AND k1.CONSTRAINT_TYPE = k2.CONSTRAINT_TYPE
        AND k1.KeyColumns = k2.KeyColumns -- Check if the key structure (columns) is identical
    WHERE k1.KeyColumns IS NULL OR k2.KeyColumns IS NULL OR k1.KeyColumns <> k2.KeyColumns OR k1.CONSTRAINT_TYPE <> k2.CONSTRAINT_TYPE

    UNION ALL

    -- 3. FOREIGN KEY COMPARISON (FKs are compared by source table, target table, and column mapping)
    SELECT
        ISNULL(fk1.SchemaName, fk2.SchemaName) AS TableSchema,
        ISNULL(fk1.TableName, fk2.TableName) AS TableName,
        ISNULL(fk1.name, fk2.name) AS ObjectName,
        ''FOREIGN KEY'' AS ObjectType,
        CASE
            WHEN fk1.name IS NULL THEN ''Missing ' + QUOTENAME(@db1) + '''
            WHEN fk2.name IS NULL THEN ''Missing ' + QUOTENAME(@db2) + '''
            WHEN fk1.ReferenceDetails <> fk2.ReferenceDetails THEN ''Reference Mismatch''
            ELSE ''Difference''
        END AS DifferenceType,
        ISNULL(fk1.ReferenceDetails, ''<N/A>'') AS ' + @db1 + '_Details,
        ISNULL(fk2.ReferenceDetails, ''<N/A>'') AS ' + @db2 + '_Details
    FROM (
        SELECT
            f.name,
            SCHEMA_NAME(t.schema_id) AS SchemaName,
            t.name AS TableName,
            -- Combine all reference details into one string for comparison
            SCHEMA_NAME(r.schema_id) + ''.'' + r.name + '' ('' + STRING_AGG(c_s.name, '','') WITHIN GROUP (ORDER BY fk_c.constraint_column_id) + '' -> '' + STRING_AGG(c_r.name, '','') WITHIN GROUP (ORDER BY fk_c.constraint_column_id) + '')'' AS ReferenceDetails
        FROM ' + QUOTENAME(@db1) + '.sys.foreign_keys f
        JOIN ' + QUOTENAME(@db1) + '.sys.tables t ON f.parent_object_id = t.object_id
        JOIN ' + QUOTENAME(@db1) + '.sys.tables r ON f.referenced_object_id = r.object_id
        JOIN ' + QUOTENAME(@db1) + '.sys.foreign_key_columns fk_c ON f.object_id = fk_c.constraint_object_id
        JOIN ' + QUOTENAME(@db1) + '.sys.columns c_s ON fk_c.parent_object_id = c_s.object_id AND fk_c.parent_column_id = c_s.column_id
        JOIN ' + QUOTENAME(@db1) + '.sys.columns c_r ON fk_c.referenced_object_id = c_r.object_id AND fk_c.referenced_column_id = c_r.column_id
        GROUP BY f.name, SCHEMA_NAME(t.schema_id), t.name, SCHEMA_NAME(r.schema_id) + ''.'' + r.name
    ) fk1
    FULL OUTER JOIN (
        SELECT
            f.name,
            SCHEMA_NAME(t.schema_id) AS SchemaName,
            t.name AS TableName,
            SCHEMA_NAME(r.schema_id) + ''.'' + r.name + '' ('' + STRING_AGG(c_s.name, '','') WITHIN GROUP (ORDER BY fk_c.constraint_column_id) + '' -> '' + STRING_AGG(c_r.name, '','') WITHIN GROUP (ORDER BY fk_c.constraint_column_id) + '')'' AS ReferenceDetails
        FROM ' + QUOTENAME(@db2) + '.sys.foreign_keys f
        JOIN ' + QUOTENAME(@db2) + '.sys.tables t ON f.parent_object_id = t.object_id
        JOIN ' + QUOTENAME(@db2) + '.sys.tables r ON f.referenced_object_id = r.object_id
        JOIN ' + QUOTENAME(@db2) + '.sys.foreign_key_columns fk_c ON f.object_id = fk_c.constraint_object_id
        JOIN ' + QUOTENAME(@db2) + '.sys.columns c_s ON fk_c.parent_object_id = c_s.object_id AND fk_c.parent_column_id = c_s.column_id
        JOIN ' + QUOTENAME(@db2) + '.sys.columns c_r ON fk_c.referenced_object_id = c_r.object_id AND fk_c.referenced_column_id = c_r.column_id
        GROUP BY f.name, SCHEMA_NAME(t.schema_id), t.name, SCHEMA_NAME(r.schema_id) + ''.'' + r.name
    ) fk2
        -- Join condition for FKs is based on the source table and the full reference string (ReferenceDetails)
        ON fk1.SchemaName = fk2.SchemaName
        AND fk1.TableName = fk2.TableName
        AND fk1.ReferenceDetails = fk2.ReferenceDetails -- This is the key match: same source table, same reference
    WHERE fk1.ReferenceDetails IS NULL OR fk2.ReferenceDetails IS NULL OR fk1.ReferenceDetails <> fk2.ReferenceDetails
;';

-- Execute the dynamic SQL
EXEC sp_executesql @sql;
