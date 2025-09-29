-- Declare variables for the database names
DECLARE @db1 NVARCHAR(128) = 'DB_DEV';
DECLARE @db2 NVARCHAR(128) = 'DB_QA';
-- Use dynamic SQL to build the query
DECLARE @sql NVARCHAR(MAX);

SET
@sql = N'
    -- CTE 1: Get all column descriptions from Database 1 (@db1)
    WITH Descriptions_DB1 AS (
        SELECT
            s.name AS TableSchema,
            t.name AS TableName,
            c.name AS ColumnName,
            CAST(p.value AS NVARCHAR(MAX)) AS Description -- Description is stored as the value of the Extended Property
        FROM ' + QUOTENAME(@db1) + '.sys.columns c
        JOIN ' + QUOTENAME(@db1) + '.sys.tables t ON t.object_id = c.object_id
        JOIN ' + QUOTENAME(@db1) + '.sys.schemas s ON s.schema_id = t.schema_id
        LEFT JOIN ' + QUOTENAME(@db1) + '.sys.extended_properties p
            -- Join on major_id (Table ID) and minor_id (Column ID)
            ON p.major_id = t.object_id
            AND p.minor_id = c.column_id
            AND p.class_desc = ''OBJECT_OR_COLUMN'' -- Ensure it is a column property
            AND p.name = ''MS_Description'' -- Filter for the standard description property name
    ),
    -- CTE 2: Get all column descriptions from Database 2 (@db2)
    Descriptions_DB2 AS (
        SELECT
            s.name AS TableSchema,
            t.name AS TableName,
            c.name AS ColumnName,
            CAST(p.value AS NVARCHAR(MAX)) AS Description
        FROM ' + QUOTENAME(@db2) + '.sys.columns c
        JOIN ' + QUOTENAME(@db2) + '.sys.tables t ON t.object_id = c.object_id
        JOIN ' + QUOTENAME(@db2) + '.sys.schemas s ON s.schema_id = t.schema_id
        LEFT JOIN ' + QUOTENAME(@db2) + '.sys.extended_properties p
            ON p.major_id = t.object_id
            AND p.minor_id = c.column_id
            AND p.class_desc = ''OBJECT_OR_COLUMN''
            AND p.name = ''MS_Description''
    )
    -- Perform a FULL OUTER JOIN to find differences
    SELECT
        ISNULL(d1.TableSchema, d2.TableSchema) AS TableSchema,
        ISNULL(d1.TableName, d2.TableName) AS TableName,
        ISNULL(d1.ColumnName, d2.ColumnName) AS ColumnName,
        CASE
            WHEN d1.Description IS NULL AND d2.Description IS NOT NULL THEN ''Missing Description in ' + QUOTENAME(@db1) + '''
            WHEN d1.Description IS NOT NULL AND d2.Description IS NULL THEN ''Missing Description in ' + QUOTENAME(@db2) + '''
            WHEN d1.Description <> d2.Description THEN ''Description Mismatch''
            ELSE ''No Difference Found'' -- Should be filtered out by the WHERE clause
        END AS DifferenceType,
        d1.Description AS ' + QUOTENAME(@db1 + '_Description') + N', -- FIX: Comma added to the dynamic string
        d2.Description AS ' + QUOTENAME(@db2 + '_Description') + N'
    FROM Descriptions_DB1 d1
    FULL OUTER JOIN Descriptions_DB2 d2
        ON d1.TableSchema = d2.TableSchema
        AND d1.TableName = d2.TableName
        AND d1.ColumnName = d2.ColumnName
    -- Filter for actual differences in the Description value
    -- We use ISNULL with a unique placeholder (N''NULL_PLACEHOLDER_42'') to correctly handle
    -- NULL vs NOT-NULL and direct Mismatch comparisons in a single, robust condition.
    WHERE
        ISNULL(d1.Description, N''NULL_PLACEHOLDER_42'') <> ISNULL(d2.Description, N''NULL_PLACEHOLDER_42'')
    ORDER BY TableSchema, TableName, ColumnName;
';
-- Execute the dynamic SQL
EXEC sp_executesql @sql;