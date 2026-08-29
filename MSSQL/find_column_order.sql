SELECT table_catalog AS DatabaseName,
	table_schema AS SchemaName,
	table_name AS TableName,
	Quotename(table_catalog) + '.'
	+ Quotename(table_schema) + '.'
	+ Quotename(table_name) AS FullyQualifiedDomainName,
	ordinal_position AS ColumnOrder, -- Shows the column's position
	column_name AS ColumnName
FROM information_schema.columns
WHERE table_name LIKE 'AP_%' -- Filters by table prefix
ORDER BY databasename,
	schemaname,
	tablename,
	columnorder;