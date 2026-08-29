SET NOCOUNT ON;

;WITH DirtyDescriptions AS (
    SELECT
        DB_NAME() AS DBName,
        SCHEMA_NAME(o.schema_id) AS SchemaName,
        OBJECT_NAME(o.object_id) AS TableName,
        c.name AS ColumnName,
        CAST(ep.value AS nvarchar(max)) AS OldDesc,
        LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(CAST(ep.value AS nvarchar(max)), CHAR(13), ' '), CHAR(10), ' '), '  ', ' '))) AS CleanDesc
    FROM sys.extended_properties ep
    INNER JOIN sys.objects o  ON ep.major_id = o.object_id
    LEFT  JOIN sys.columns c  ON ep.minor_id = c.column_id AND ep.major_id = c.object_id
    WHERE ep.name = N'MS_Description'
      AND ep.class = 1
      AND ep.value IS NOT NULL
      AND (
            CAST(ep.value AS nvarchar(max)) LIKE '%  %'
         OR CAST(ep.value AS nvarchar(max)) LIKE '%' + CHAR(13) + '%'
         OR CAST(ep.value AS nvarchar(max)) LIKE '%' + CHAR(10) + '%'
         OR LTRIM(RTRIM(CAST(ep.value AS nvarchar(max)))) <> CAST(ep.value AS nvarchar(max))
      )
)
SELECT
    ROW_NUMBER() OVER (ORDER BY SchemaName, TableName, ColumnName) AS [No],
    DBName + '.' + SchemaName + '.' + TableName AS [Full_Table_Name],
    ISNULL(ColumnName, '(Table Level)') AS [Column_Name],
    OldDesc AS [Old_Description],
    CleanDesc AS [New_Description],

    -- เปลี่ยน description ให้สะอาด
    N'USE ' + QUOTENAME(DBName) + N'; EXEC sp_updateextendedproperty ' +
    N'@name = N''MS_Description'', @value = N''' + REPLACE(CleanDesc, '''', '''''') + N''', ' +
    N'@level0type = N''SCHEMA'', @level0name = N''' + SchemaName + N''', ' +
    N'@level1type = N''TABLE'', @level1name = N''' + TableName + N'''' +
    CASE WHEN ColumnName IS NOT NULL
         THEN N', @level2type = N''COLUMN'', @level2name = N''' + ColumnName + N''''
         ELSE N''
    END + N';' AS [SQL_Command_To_Run]

FROM DirtyDescriptions
ORDER BY [No];
