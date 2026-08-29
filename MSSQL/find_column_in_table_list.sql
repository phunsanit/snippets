DECLARE @SearchTerm NVARCHAR(100) = '%pp_%';

SELECT
	c.table_catalog AS DatabaseName,
	c.table_schema AS SchemaName,
	c.table_name AS TableName,
	c.column_name AS ColumnName,
	c.DATA_TYPE AS ColumnType,
	c.CHARACTER_MAXIMUM_LENGTH AS MaxLengthCharacters,
	c.NUMERIC_PRECISION AS NumericPrecision,
	c.NUMERIC_SCALE AS NumericScale,
	-- Retrieve Column Description
	ISNULL(ep.value, 'N/A') AS ColumnDescription
FROM
	information_schema.columns c
	-- Join to retrieve Column Description from sys.extended_properties
LEFT JOIN
	sys.tables t ON t.name = c.table_name
		AND SCHEMA_NAME(t.schema_id) = c.table_schema
LEFT JOIN
	sys.columns sc ON sc.object_id = t.object_id 
		AND sc.name = c.column_name
LEFT JOIN
	sys.extended_properties ep ON ep.major_id = t.object_id
		AND ep.minor_id = sc.column_id
		AND ep.name = 'MS_Description'
		AND ep.class_desc = 'OBJECT_OR_COLUMN'
WHERE
	-- 1. Filter by Schema
	-- c.table_schema  = 'pitt'
	AND
	-- 2. Filter by the specific list of Tables
	c.table_name IN (
		'OTC_REQUEST_BOOKING',
		'OTC_REQUEST_REQINFO',
		'OTC_REQUEST_SHAREDEPT',
		'OTC_REQUEST_TRANS',
		'OTC_TRANSCODE_ACCOUNT'
	)
	-- 3. Search by Column Name or Description using @SearchTerm variable
	AND (
		c.column_name LIKE @SearchTerm -- Search in column name
		OR
		CAST(ep.value AS NVARCHAR(MAX)) LIKE @SearchTerm -- Search in description
	)
ORDER BY
	DatabaseName,
	SchemaName,
	TableName,
	ColumnName;
