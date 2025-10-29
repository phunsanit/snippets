SELECT
	DB_NAME() AS DatabaseName,
	SCHEMA_NAME(t.schema_id) AS SchemaName,
	t.name AS TableName,
	QUOTENAME(DB_NAME()) + '.' + QUOTENAME(SCHEMA_NAME(t.schema_id)) + '.' + QUOTENAME(t.name) AS FullyQualifiedDomainName,
	CAST(ep.value AS NVARCHAR(MAX)) AS Description
FROM
	sys.tables t
LEFT JOIN
	sys.extended_properties ep
	ON
	t.object_id = ep.major_id
	AND ep.name = 'MS_Description'
WHERE
	t.name LIKE '%note%'
	OR CAST(ep.value AS NVARCHAR(MAX)) LIKE '%note%';