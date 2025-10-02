SELECT
	table_catalog AS DatabaseName,
	table_schema AS SchemaName,
	table_name AS TableName,
	Quotename(table_catalog) + '.'
       + Quotename(table_schema) + '.'
       + Quotename(table_name) AS FullyQualifiedDomainName,
	column_name AS ColumnName,
	DATA_TYPE AS ColumnType,
	CHARACTER_MAXIMUM_LENGTH AS MaxLengthCharacters,
	NUMERIC_PRECISION AS NumericPrecision,
	NUMERIC_SCALE AS NumericScale
FROM
	information_schema.columns
WHERE
	column_name = 'ID';