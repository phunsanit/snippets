/*
 * Objective: Detect Schema Inconsistencies (Schema Drift)
 * * This query identifies columns across different tables that share the same
 * logical name (CleanedColumnName) but have conflicting definitions:
 * 1. Different Data Types (e.g., int vs bigint)
 * 2. Different Sizes/Precisions (e.g., varchar(50) vs varchar(100))
 * 3. Different Nullability rules (NULL vs NOT NULL)
 */

WITH RawColumns AS (
	SELECT
		table_schema AS SchemaName,
		table_name AS TableName,
		column_name AS ColumnName,

		-- Normalize data type for accurate comparison
		LOWER(RTRIM(LTRIM(data_type))) AS DataType,

		-- Capture Nullability (YES/NO)
		is_nullable AS IsNullable,

		-- Standardize Data Size representation based on the data type category
		CASE
			-- String types: use max character length
			WHEN character_maximum_length IS NOT NULL
				THEN CAST(character_maximum_length AS VARCHAR)
			-- Date/Time types: use precision (e.g., 3 for milliseconds)
			WHEN datetime_precision IS NOT NULL
				THEN CAST(datetime_precision AS VARCHAR)
			-- Numeric types: combine precision and scale (e.g., 18,2)
			WHEN numeric_precision IS NOT NULL AND numeric_scale IS NOT NULL
				THEN CAST(numeric_precision AS VARCHAR) + ',' + CAST(numeric_scale AS VARCHAR)
			ELSE 'N/A'
		END AS DataSize,

		-- Logic to clean column names by removing prefixes
		-- (e.g., converts 'tb_created_at' to 'created_at')
		CASE
			WHEN column_name LIKE '%_%' THEN SUBSTRING(column_name, CHARINDEX('_', column_name) + 1, LEN(column_name))
			ELSE column_name
		END AS CleanedColumnName
	FROM information_schema.columns
),
DiffCheck AS (
	-- Filter logic: Identify only the CleanedColumnNames that have inconsistencies.
	-- If a column name is consistent across all tables, it will be excluded here.
	SELECT CleanedColumnName
	FROM RawColumns
	GROUP BY CleanedColumnName
	HAVING
		COUNT(DISTINCT DataType) > 1	  -- Found different Data Types
		OR COUNT(DISTINCT DataSize) > 1   -- Found different Sizes/Precisions
		OR COUNT(DISTINCT IsNullable) > 1 -- Found different Nullability settings
)
SELECT
	r.SchemaName,
	r.TableName,
	r.ColumnName,
	r.CleanedColumnName,
	r.DataType,
	r.DataSize,
	r.IsNullable
FROM RawColumns r
INNER JOIN DiffCheck d ON r.CleanedColumnName = d.CleanedColumnName
ORDER BY
	r.CleanedColumnName, -- Group related columns together
	r.DataType,		  -- Sort to easily spot the differences
	r.DataSize,
	r.SchemaName;
