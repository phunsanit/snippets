SELECT table_catalog AS DatabaseName,
       table_schema AS SchemaName,
       table_name AS TableName,
       Quotename(table_catalog) + '.'
       + Quotename(table_schema) + '.'
       + Quotename(table_name) AS FullyQualifiedDomainName,
       column_name AS ColumnName
FROM   information_schema.columns
WHERE  column_name = 'dc_des_code';