-- Declare variables for the database names
DECLARE @db1 NVARCHAR(128) = 'DB_DEV';
DECLARE @db2 NVARCHAR(128) = 'DB_QA';

-- Use dynamic SQL to build the query
DECLARE @sql NVARCHAR(MAX);

SET @sql = N'
    SELECT
        ISNULL(c1.TABLE_SCHEMA, c2.TABLE_SCHEMA) AS TableSchema,
        ISNULL(c1.TABLE_NAME, c2.TABLE_NAME) AS TableName,
        ISNULL(c1.COLUMN_NAME, c2.COLUMN_NAME) AS ColumnName,
        CASE
            WHEN c1.COLUMN_NAME IS NULL THEN ''Missing in ' + QUOTENAME(@db1) + '''
            WHEN c2.COLUMN_NAME IS NULL THEN ''Missing in ' + QUOTENAME(@db2) + '''
            WHEN c1.DATA_TYPE <> c2.DATA_TYPE THEN ''Data Type Mismatch''
            WHEN c1.IS_NULLABLE <> c2.IS_NULLABLE THEN ''Nullability Mismatch''
            ELSE ''Difference''
        END AS DifferenceType,
        c1.DATA_TYPE AS ' + @db1 + '_DataType,
        c2.DATA_TYPE AS ' + @db2 + '_DataType,
        c1.IS_NULLABLE AS ' + @db1 + '_IsNullable,
        c2.IS_NULLABLE AS ' + @db2 + '_IsNullable
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
      AND ISNULL(c1.TABLE_SCHEMA, c2.TABLE_SCHEMA) = ''POSTS'';
      AND ISNULL(c1.TABLE_NAME, c2.TABLE_NAME) LIKE  ''WP_%'';
';

-- Execute the dynamic SQL
EXEC sp_executesql @sql;
