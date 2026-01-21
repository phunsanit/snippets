/******************************************************************
	Query List Columns with Dynamic Filters (Supports LIKE)
	- FilterTable uses LIKE operator (allows %, _)
	- If Schema/Database is empty = Search All
******************************************************************/

-- ================= Define Search Criteria =================
DECLARE @FilterDatabase NVARCHAR(128) = '';		  -- Enter DB name or leave empty to search all
DECLARE @FilterSchema   NVARCHAR(128) = '';		  -- Enter 'dbo' or leave empty to search all schemas
DECLARE @FilterTable	NVARCHAR(128) = 'Pitt_%'; -- Can use %, e.g. 'PP_%', '%User%', 'Log_%'
-- =========================================================================

-- (Recommended) Comment out this line to allow cross-schema search (if you only want 'dbo', enable this)
IF @FilterSchema IS NULL OR @FilterSchema = '' SET @FilterSchema = 'dbo';

SELECT
	C.TABLE_CATALOG AS [Database],
	C.TABLE_SCHEMA AS [Schema],
	C.TABLE_NAME AS [Table],
	STRING_AGG(C.COLUMN_NAME, ',') WITHIN GROUP (ORDER BY C.ORDINAL_POSITION) AS [Columns]
FROM INFORMATION_SCHEMA.COLUMNS C
JOIN INFORMATION_SCHEMA.TABLES T
	ON C.TABLE_NAME = T.TABLE_NAME
	AND C.TABLE_SCHEMA = T.TABLE_SCHEMA
WHERE T.TABLE_TYPE = 'BASE TABLE' -- Only actual tables

-- 1. Filter Database (if empty = get all)
	AND (@FilterDatabase IS NULL OR @FilterDatabase = '' OR C.TABLE_CATALOG = @FilterDatabase)

-- 2. Filter Schema (if empty = get all)
	AND (@FilterSchema IS NULL OR @FilterSchema = '' OR C.TABLE_SCHEMA = @FilterSchema)

-- 3. Filter Table with LIKE (if empty = get all)
	AND (@FilterTable	IS NULL OR @FilterTable	= '' OR C.TABLE_NAME LIKE @FilterTable)

GROUP BY C.TABLE_CATALOG, C.TABLE_SCHEMA, C.TABLE_NAME
ORDER BY C.TABLE_SCHEMA, C.TABLE_NAME;
