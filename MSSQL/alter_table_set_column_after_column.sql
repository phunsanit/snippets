/**************************************************************************************************
	Script to Reorder Columns (Final Fixed: PK Name Collision Handled)
	Fixes:
	1. Renames the OLD PK on the backup table first to free up the name.
	2. Handles Identity Check.
	3. Fully compatible syntax.
**************************************************************************************************/

-- USE DB_DEV;
-- USE DB_QA;
-- USE DB_PROD;

-- ==================== Edit only these 3 lines ====================
DECLARE @SchemaName NVARCHAR(128) = N'';
DECLARE @TableName  NVARCHAR(128) = N'Pitt_Posts';

-- Enter the column names to be ordered first
DECLARE @DesiredColumnOrder NVARCHAR(MAX) = N'
PP_ID,
PP_CREATE_BY,
PP_CREATE_DT,
PP_MODIFY_BY,
PP_MODIFY_DT,
PP_TIMESTAMP,

PP_TITLE,
PP_CONTENT
';
-- =================================================================

IF @SchemaName IS NULL OR @SchemaName = N'' SET @SchemaName = N'dbo';

SET NOCOUNT ON;
DECLARE @NewTable	 NVARCHAR(258) = QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName + '_New');
DECLARE @OldTable	 NVARCHAR(258) = QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName);
DECLARE @SQL		 NVARCHAR(MAX) = N'';
DECLARE @DropFK		 NVARCHAR(MAX) = N'';
DECLARE @CreateFK	 NVARCHAR(MAX) = N'';
DECLARE @ColList	 NVARCHAR(MAX) = N'';
DECLARE @PKCols		 NVARCHAR(MAX) = N'';
DECLARE @HasIdentity BIT = 0;

-- Clean spaces AND Newlines (CR/LF)
SET @DesiredColumnOrder = REPLACE(@DesiredColumnOrder, ' ', '');
SET @DesiredColumnOrder = REPLACE(@DesiredColumnOrder, CHAR(13), ''); -- Remove Carriage Return
SET @DesiredColumnOrder = REPLACE(@DesiredColumnOrder, CHAR(10), ''); -- Remove Line Feed

-- 1. Get FK Scripts
SELECT
	@DropFK   = @DropFK + N'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id))
				+ N' DROP CONSTRAINT ' + QUOTENAME(fk.name) + N';' + CHAR(10),
	@CreateFK = @CreateFK + N'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id))
				+ N' WITH CHECK ADD CONSTRAINT ' + QUOTENAME(fk.name) + N' FOREIGN KEY ('
				+ STUFF((SELECT ',' + QUOTENAME(COL_NAME(fc2.parent_object_id, fc2.parent_column_id))
							FROM sys.foreign_key_columns fc2
							WHERE fc2.constraint_object_id = fk.object_id
							ORDER BY fc2.constraint_column_id
							FOR XML PATH('')),1,1,'') + N') REFERENCES '
				+ QUOTENAME(OBJECT_SCHEMA_NAME(referenced_object_id)) + '.' + QUOTENAME(OBJECT_NAME(referenced_object_id)) + N' ('
				+ STUFF((SELECT ',' + QUOTENAME(COL_NAME(fc2.referenced_object_id, fc2.referenced_column_id))
							FROM sys.foreign_key_columns fc2
							WHERE fc2.constraint_object_id = fk.object_id
							ORDER BY fc2.constraint_column_id
							FOR XML PATH('')),1,1,'') + N');' + CHAR(10)
				+ N'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id))
				+ N' CHECK CONSTRAINT ' + QUOTENAME(fk.name) + N';' + CHAR(10)
FROM sys.foreign_keys fk
WHERE referenced_object_id = OBJECT_ID(@OldTable)
	OR parent_object_id = OBJECT_ID(@OldTable);

-- 2. Begin Transaction
BEGIN TRANSACTION;
BEGIN TRY

	-- Drop FKs
	IF LEN(@DropFK) > 0 EXEC sp_executesql @DropFK;

	-- 3. Prepare Columns Data
	DECLARE @ColsTable TABLE (
		ColName	    NVARCHAR(128),
		DataType	NVARCHAR(128),
		IsNullable  VARCHAR(3),
		ColDefault  NVARCHAR(MAX),
		IsIdentity  BIT,
		IsComputed  BIT,
		ComputedDef NVARCHAR(MAX),
		IsPersisted BIT,
		SortOrder   INT
	);

	INSERT INTO @ColsTable
	SELECT
		c.COLUMN_NAME,
		DATA_TYPE =
				CASE
					WHEN c.DATA_TYPE IN ('varchar','char','nvarchar','nchar','varbinary','binary') AND c.CHARACTER_MAXIMUM_LENGTH = -1 THEN c.DATA_TYPE + '(MAX)'
					WHEN c.DATA_TYPE IN ('varchar','char','nvarchar','nchar','varbinary','binary') THEN c.DATA_TYPE + '(' + CASE WHEN c.CHARACTER_MAXIMUM_LENGTH = -1 THEN 'MAX' ELSE CAST(c.CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10)) END + ')'
					WHEN c.DATA_TYPE IN ('decimal','numeric') THEN c.DATA_TYPE + '(' + CAST(c.NUMERIC_PRECISION AS VARCHAR(10)) + ',' + CAST(c.NUMERIC_SCALE AS VARCHAR(10)) + ')'
					WHEN c.DATA_TYPE IN ('float','real') THEN c.DATA_TYPE + CASE WHEN c.NUMERIC_PRECISION IS NULL THEN '' ELSE '(' + CAST(c.NUMERIC_PRECISION AS VARCHAR(10)) + ')' END
					WHEN c.DATA_TYPE = 'datetime2' THEN c.DATA_TYPE + '(' + CAST(c.DATETIME_PRECISION AS VARCHAR(10)) + ')'
					ELSE c.DATA_TYPE
				END,
		IS_NULLABLE = c.IS_NULLABLE,
		COLUMN_DEFAULT = c.COLUMN_DEFAULT,
		IS_IDENTITY = CASE WHEN ic.column_id IS NOT NULL THEN 1 ELSE 0 END,
		IS_COMPUTED = CASE WHEN cc.definition IS NOT NULL THEN 1 ELSE 0 END,
		COMPUTED_DEF = cc.definition,
		IS_PERSISTED = cc.is_persisted,
		SortOrder = CASE
							WHEN CHARINDEX(',' + c.COLUMN_NAME + ',', ',' + @DesiredColumnOrder + ',') > 0
							THEN CHARINDEX(',' + c.COLUMN_NAME + ',', ',' + @DesiredColumnOrder + ',')
							ELSE 100000 + c.ORDINAL_POSITION
					END
	FROM INFORMATION_SCHEMA.COLUMNS c
	LEFT JOIN sys.identity_columns ic ON OBJECT_ID(@OldTable) = ic.object_id AND c.COLUMN_NAME = ic.name
	LEFT JOIN sys.computed_columns cc ON OBJECT_ID(@OldTable) = cc.object_id AND c.COLUMN_NAME = cc.name
	WHERE c.TABLE_SCHEMA = @SchemaName AND c.TABLE_NAME = @TableName;

	-- Check Identity
	IF EXISTS (SELECT 1 FROM @ColsTable WHERE IsIdentity = 1) SET @HasIdentity = 1;

	-- 4. Build CREATE TABLE Script
	SET @SQL = N'CREATE TABLE ' + @NewTable + ' (' + CHAR(10);

	DECLARE @ColsDef NVARCHAR(MAX);
	SELECT @ColsDef = STUFF((
		SELECT ',' + CHAR(10) + ' [' + ColName + '] ' + DataType +
					CASE WHEN IsIdentity = 1 THEN ' IDENTITY(1,1)' ELSE '' END +
					CASE WHEN IsComputed = 1 THEN ' AS ' + ComputedDef + CASE WHEN IsPersisted = 1 THEN ' PERSISTED' ELSE ' ' END ELSE ' ' END +
					' ' + CASE WHEN IsNullable = 'YES' OR IsComputed = 1 THEN 'NULL' ELSE 'NOT NULL' END +
					-- Add '_New' to constraint name to avoid duplicate object name error
					ISNULL(' CONSTRAINT [DF_' + @TableName + '_New_' + ColName + '] DEFAULT ' + ColDefault, ' ')
		FROM @ColsTable
		ORDER BY SortOrder
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '');

	SET @SQL = @SQL + @ColsDef;

	-- Add PK
	IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE type = 'PK' AND parent_object_id = OBJECT_ID(@OldTable))
	BEGIN
		SELECT @PKCols = STUFF((
				SELECT ', [' + COL_NAME(ic.object_id, ic.column_id) + '] ' + CASE WHEN ic.is_descending_key = 1 THEN 'DESC' ELSE 'ASC' END
				FROM sys.key_constraints kc
				JOIN sys.index_columns ic ON kc.parent_object_id = ic.object_id AND kc.unique_index_id = ic.index_id
				WHERE kc.type = 'PK' AND kc.parent_object_id = OBJECT_ID(@OldTable)
				ORDER BY ic.key_ordinal
				FOR XML PATH('')), 1, 2, '');

		SET @SQL = @SQL + CHAR(10) + ', CONSTRAINT [PK_' + @TableName + '_Temp] PRIMARY KEY CLUSTERED (' + @PKCols + ')';
	END

	SET @SQL = @SQL + CHAR(10) + ');';

	EXEC sp_executesql @SQL;

	-- 5. Copy Data
	SELECT @ColList = STUFF((
		SELECT ', [' + ColName + ']'
		FROM @ColsTable
		WHERE IsComputed = 0
		ORDER BY SortOrder
		FOR XML PATH('')), 1, 2, '');

	SET @SQL = N'';
	IF @HasIdentity = 1
		SET @SQL = @SQL + N'SET IDENTITY_INSERT ' + @NewTable + ' ON; ' + CHAR(10);

	SET @SQL = @SQL + N'INSERT INTO ' + @NewTable + ' (' + @ColList + ') ' + CHAR(10) +
					  N'SELECT ' + @ColList + ' FROM ' + @OldTable + '; ' + CHAR(10);

	IF @HasIdentity = 1
		SET @SQL = @SQL + N'SET IDENTITY_INSERT ' + @NewTable + ' OFF;';

	EXEC sp_executesql @SQL;
	PRINT N'Data copy completed ' + CAST(@@ROWCOUNT AS NVARCHAR(20)) + N' rows';

	-- 6. Swap table names & FIX PK NAMES
	DECLARE @Timestamp NVARCHAR(20);
	DECLARE @BackupName NVARCHAR(128);

	SET @Timestamp = CONVERT(VARCHAR(8), GETDATE(), 112) + '_' + REPLACE(CONVERT(VARCHAR(8), GETDATE(), 108), ':', '');
	SET @BackupName = @TableName + '_Old_' + @Timestamp;

	-- 6.1 Rename Old Table to Backup Name
	EXEC sp_rename @OldTable, @BackupName;

	-- 6.2 Rename the PK on the Backup Table to free up the original name
	DECLARE @CurrentOldPKName NVARCHAR(128);
	DECLARE @NewBackupPKName NVARCHAR(128);

	-- Find the name of the PK currently attached to the backup table
	SELECT @CurrentOldPKName = name
	FROM sys.key_constraints
	WHERE parent_object_id = OBJECT_ID(@SchemaName + '.' + @BackupName)
		AND type = 'PK';

	IF @CurrentOldPKName IS NOT NULL
	BEGIN
		-- Rename it: e.g. PK_MyTable -> PK_MyTable_Old_2024...
		SET @NewBackupPKName = @CurrentOldPKName + '_Old_' + @Timestamp;
		DECLARE @FullOldPKName NVARCHAR(258) = @SchemaName + '.' + @CurrentOldPKName;
		-- Check if length exceeds limit (optional safety, usually fine)
		IF LEN(@NewBackupPKName) > 128 SET @NewBackupPKName = LEFT(@NewBackupPKName, 128);
		EXEC sp_rename @FullOldPKName, @NewBackupPKName, 'OBJECT';
	END

	-- 6.3 Rename New Table to Original Name
	EXEC sp_rename @NewTable, @TableName;

	-- 6.4 Rename New PK Temp -> Original PK Name
	DECLARE @OldTempPKName NVARCHAR(128);
	DECLARE @RealPKName NVARCHAR(128);
	SET @OldTempPKName = @SchemaName + '.PK_' + @TableName + '_Temp';
	SET @RealPKName = 'PK_' + @TableName;

	IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE name LIKE 'PK_' + @TableName + '_Temp')
		EXEC sp_rename @OldTempPKName, @RealPKName, 'OBJECT';

	-- 7. Recreate FKs
	IF LEN(@CreateFK) > 0 EXEC sp_executesql @CreateFK;

	COMMIT TRANSACTION;
	PRINT N'';
	PRINT N'SUCCESS! Columns reordered.';
	PRINT N'-------------------------------------------------------';

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
	PRINT N'ERROR: ' + ERROR_MESSAGE();
	THROW;
END CATCH;