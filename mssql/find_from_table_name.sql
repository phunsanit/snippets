-- Declare variables
DECLARE @SEARCH NVARCHAR(255) = 'Pitt';-- Search from
DECLARE @SQL NVARCHAR(MAX) = '';

-- Build the dynamic SQL query by iterating through online databases
SELECT @SQL += '
    SELECT
        DB_NAME() AS DatabaseName,
        s.name COLLATE DATABASE_DEFAULT AS SchemaName,
        t.name COLLATE DATABASE_DEFAULT AS TableName,
        (DB_NAME() COLLATE DATABASE_DEFAULT + ''.'' + s.name COLLATE DATABASE_DEFAULT + ''.'' + t.name COLLATE DATABASE_DEFAULT) AS FullyQualifiedDomainName
    FROM ' + QUOTENAME(d.name) + '.sys.tables AS t
    INNER JOIN ' + QUOTENAME(d.name) + '.sys.schemas AS s ON t.schema_id = s.schema_id
    WHERE t.name LIKE ''%' + REPLACE(@SEARCH, '''', '''''') + '%''
    UNION ALL '
FROM sys.databases AS d
WHERE state = 0; -- Only online databases

-- Remove the trailing UNION ALL
IF LEN(@SQL) > 0
    SET @SQL = LEFT(@SQL, LEN(@SQL) - LEN(' UNION ALL '));

-- Execute the dynamic SQL if it's not empty, otherwise return a message
IF @SQL <> ''
BEGIN
    PRINT @SQL; -- Debug: View the generated SQL
    EXEC sp_executesql @SQL;
END
ELSE
BEGIN
    SELECT 'No tables found with ''' + @SEARCH + ''' in their names.' AS Result;
END