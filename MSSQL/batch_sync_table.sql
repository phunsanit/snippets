USE INSAPP_DEV;
-- USE INSAPP_QA;
-- USE INSAPP_PROD;

SET NOCOUNT ON;

BEGIN TRY
BEGIN TRANSACTION

    -- =============================================
    -- 1. ประกาศตัวแปร (DECLARE ONLY - GLOBAL)
    -- =============================================
    -- 1.1 Configuration & Object Names
    DECLARE @SchemaName NVARCHAR(128)
    DECLARE @TableName NVARCHAR(128)
    DECLARE @TempTableName NVARCHAR(128)
    DECLARE @OldTableName NVARCHAR(128)
    DECLARE @TargetObjID INT
    DECLARE @CurrentFullName NVARCHAR(256)
    DECLARE @TempFullName NVARCHAR(256)

    -- 1.2 Script Builders
    DECLARE @SqlDropFK NVARCHAR(MAX)
    DECLARE @SqlCreateFK NVARCHAR(MAX)
    DECLARE @SqlCreatePK_Indexes NVARCHAR(MAX)
    DECLARE @CreateTableSQL NVARCHAR(MAX)
    DECLARE @CreateTempSQL NVARCHAR(MAX)
    DECLARE @CopySQL NVARCHAR(MAX)
    DECLARE @AlterSQL NVARCHAR(MAX)
    DECLARE @DropOldSQL NVARCHAR(MAX)
    DECLARE @ColList NVARCHAR(MAX)
    DECLARE @SharedColList NVARCHAR(MAX)
    DECLARE @TempColList NVARCHAR(MAX)
    DECLARE @ColDef NVARCHAR(MAX) -- [ADDED] เพิ่มตัวแปรที่หายไป
    DECLARE @Msg NVARCHAR(MAX)

    -- 1.3 Cursor Helpers
    DECLARE @Cur_ColName NVARCHAR(128)
    DECLARE @Cur_DataType NVARCHAR(100)
    DECLARE @Cur_IsNullable CHAR(1)
    DECLARE @Cur_Desc NVARCHAR(4000)
    DECLARE @Cur_FKID INT
    DECLARE @Cur_FKName NVARCHAR(128)
    DECLARE @Cur_ParentSchema NVARCHAR(128)
    DECLARE @Cur_ParentTable NVARCHAR(128)
    DECLARE @Cur_IdxID INT
    DECLARE @Cur_IdxName NVARCHAR(128)
    DECLARE @Cur_IsPK BIT
    DECLARE @Cur_IsUnique BIT
    DECLARE @Cur_IdxType TINYINT
    DECLARE @Helper_FKCols NVARCHAR(MAX)
    DECLARE @Helper_RefCols NVARCHAR(MAX)
    DECLARE @Helper_IdxCols NVARCHAR(MAX)
    DECLARE @Helper_IncCols NVARCHAR(MAX)

    /*******************************************************
    * CONFIGURATION
    *******************************************************/
    SET @SchemaName = ''
    SET @TableName = 'wp_posts'

    IF ISNULL(@SchemaName, '') = '' SET @SchemaName = 'dbo'

    SET @TempTableName = @TableName + '_tmp'
    SET @OldTableName = @TableName + '_old'
    SET @TargetObjID = OBJECT_ID(QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName))

    -- Initialize strings to empty
    SET @SqlDropFK = ''
    SET @SqlCreateFK = ''
    SET @SqlCreatePK_Indexes = ''
    SET @ColList = ''
    SET @SharedColList = ''
    SET @TempColList = ''

    -- =============================================
    -- 3. ตารางเก็บ Column Definitions
    -- =============================================
    DECLARE @ColumnsToAdd TABLE (
        ID INT IDENTITY(1,1),
        ColumnName NVARCHAR(128),
        DataType NVARCHAR(100),
        IsNullable CHAR(1),
        Description NVARCHAR(4000)
    );

    -- Insert column definitions
    INSERT INTO @ColumnsToAdd (ColumnName, DataType, IsNullable, Description)
    VALUES
        ('ID', 'BIGINT IDENTITY(1,1)', 'N', 'Primary Key'),
        ('post_author', 'BIGINT', 'N', 'Author ID'),
        ('post_date', 'DATETIME2(0)', 'N', 'Post Date'),
        ('post_date_gmt', 'DATETIME2(0)', 'N', 'Post Date GMT'),
        ('post_content', 'NVARCHAR(MAX)', 'N', 'Post Content'),
        ('post_title', 'NVARCHAR(MAX)', 'N', 'Post Title'),
        ('post_excerpt', 'NVARCHAR(MAX)', 'N', 'Post Excerpt'),
        ('post_status', 'NVARCHAR(20)', 'N', 'Post Status (publish, draft, etc.)'),
        ('comment_status', 'NVARCHAR(20)', 'N', 'Comment Status (open/closed)'),
        ('ping_status', 'NVARCHAR(20)', 'N', 'Ping Status'),
        ('post_password', 'NVARCHAR(255)', 'N', 'Post Password'),
        ('post_name', 'NVARCHAR(200)', 'N', 'Post Name (Slug)'),
        ('to_ping', 'NVARCHAR(MAX)', 'N', 'URLs to ping'),
        ('pinged', 'NVARCHAR(MAX)', 'N', 'Pinged URLs'),
        ('post_modified', 'DATETIME2(0)', 'N', 'Modification Date'),
        ('post_modified_gmt', 'DATETIME2(0)', 'N', 'Modification Date GMT'),
        ('post_content_filtered', 'NVARCHAR(MAX)', 'N', 'Filtered Content'),
        ('post_parent', 'BIGINT', 'N', 'Parent Post ID'),
        ('guid', 'NVARCHAR(255)', 'N', 'Global Unique ID'),
        ('menu_order', 'INT', 'N', 'Menu Order'),
        ('post_type', 'NVARCHAR(20)', 'N', 'Post Type (post, page, etc.)'),
        ('post_mime_type', 'NVARCHAR(100)', 'N', 'Mime Type'),
        ('comment_count', 'BIGINT', 'N', 'Comment Count');

    -- =============================================
    -- 4. PREPARE RELATION SCRIPTS
    -- =============================================
    PRINT '... Generating script to handle Relations ...'

    -- 4.1 Foreign Keys
    DECLARE FKCursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT fk.object_id, fk.name, SCHEMA_NAME(fk.schema_id), OBJECT_NAME(fk.parent_object_id)
    FROM sys.foreign_keys fk
    WHERE fk.referenced_object_id = @TargetObjID;

    OPEN FKCursor;
    FETCH NEXT FROM FKCursor INTO @Cur_FKID, @Cur_FKName, @Cur_ParentSchema, @Cur_ParentTable;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @Helper_FKCols = STUFF((
            SELECT ',' + QUOTENAME(c.name)
            FROM sys.foreign_key_columns fkc
            JOIN sys.columns c ON fkc.parent_object_id = c.object_id AND fkc.parent_column_id = c.column_id
            WHERE fkc.constraint_object_id = @Cur_FKID
            ORDER BY fkc.constraint_column_id
            FOR XML PATH('')), 1, 1, '');

        SELECT @Helper_RefCols = STUFF((
            SELECT ',' + QUOTENAME(c.name)
            FROM sys.foreign_key_columns fkc
            JOIN sys.columns c ON fkc.referenced_object_id = c.object_id AND fkc.referenced_column_id = c.column_id
            WHERE fkc.constraint_object_id = @Cur_FKID
            ORDER BY fkc.constraint_column_id
            FOR XML PATH('')), 1, 1, '');

        SET @SqlDropFK += 'ALTER TABLE ' + QUOTENAME(@Cur_ParentSchema) + '.' + QUOTENAME(@Cur_ParentTable) + ' DROP CONSTRAINT ' + QUOTENAME(@Cur_FKName) + ';' + CHAR(13);
        SET @SqlCreateFK += 'ALTER TABLE ' + QUOTENAME(@Cur_ParentSchema) + '.' + QUOTENAME(@Cur_ParentTable) + ' WITH NOCHECK ADD CONSTRAINT ' + QUOTENAME(@Cur_FKName) + ' FOREIGN KEY (' + @Helper_FKCols + ') REFERENCES ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' (' + @Helper_RefCols + ');' + CHAR(13);

        FETCH NEXT FROM FKCursor INTO @Cur_FKID, @Cur_FKName, @Cur_ParentSchema, @Cur_ParentTable;
    END
    CLOSE FKCursor;
    DEALLOCATE FKCursor;

    -- 4.2 Indexes & PKs
    DECLARE IdxCursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT index_id, name, is_primary_key, is_unique, type
    FROM sys.indexes
    WHERE object_id = @TargetObjID AND type IN (1, 2)
    ORDER BY is_primary_key DESC;

    OPEN IdxCursor;
    FETCH NEXT FROM IdxCursor INTO @Cur_IdxID, @Cur_IdxName, @Cur_IsPK, @Cur_IsUnique, @Cur_IdxType;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @Helper_IdxCols = STUFF((
            SELECT ',' + QUOTENAME(c.name) + CASE WHEN ic.is_descending_key = 1 THEN ' DESC' ELSE ' ASC' END
            FROM sys.index_columns ic
            JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
            WHERE ic.object_id = @TargetObjID AND ic.index_id = @Cur_IdxID AND ic.is_included_column = 0
            ORDER BY ic.key_ordinal
            FOR XML PATH('')), 1, 1, '');

        SELECT @Helper_IncCols = STUFF((
            SELECT ',' + QUOTENAME(c.name)
            FROM sys.index_columns ic
            JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
            WHERE ic.object_id = @TargetObjID AND ic.index_id = @Cur_IdxID AND ic.is_included_column = 1
            ORDER BY ic.column_id
            FOR XML PATH('')), 1, 1, '');

        IF @Cur_IsPK = 1
        BEGIN
            SET @SqlCreatePK_Indexes += 'ALTER TABLE ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' ADD CONSTRAINT ' + QUOTENAME(@Cur_IdxName) + ' PRIMARY KEY ' +
                CASE WHEN @Cur_IdxType = 1 THEN 'CLUSTERED' ELSE 'NONCLUSTERED' END + ' (' + @Helper_IdxCols + ');' + CHAR(13);
        END
        ELSE
        BEGIN
            SET @SqlCreatePK_Indexes += 'CREATE ' + CASE WHEN @Cur_IsUnique = 1 THEN 'UNIQUE ' ELSE '' END + 'NONCLUSTERED INDEX ' + QUOTENAME(@Cur_IdxName) +
                ' ON ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' (' + @Helper_IdxCols + ')' +
                CASE WHEN LEN(@Helper_IncCols) > 0 THEN ' INCLUDE (' + @Helper_IncCols + ')' ELSE '' END + ';' + CHAR(13);
        END

        FETCH NEXT FROM IdxCursor INTO @Cur_IdxID, @Cur_IdxName, @Cur_IsPK, @Cur_IsUnique, @Cur_IdxType;
    END
    CLOSE IdxCursor;
    DEALLOCATE IdxCursor;

    -- =============================================
    -- 5. BUILD DDL SCRIPTS
    -- =============================================
    DECLARE ScriptCursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT ColumnName, DataType, IsNullable FROM @ColumnsToAdd ORDER BY ID;

    OPEN ScriptCursor;
    FETCH NEXT FROM ScriptCursor INTO @Cur_ColName, @Cur_DataType, @Cur_IsNullable;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @ColDef = QUOTENAME(@Cur_ColName) + ' ' + @Cur_DataType + CASE WHEN @Cur_IsNullable = 'Y' THEN ' NULL' ELSE ' NOT NULL' END;

        IF LEN(@ColList) > 0 SET @ColList += ', ';
        SET @ColList += @ColDef;

        IF LEN(@TempColList) > 0 SET @TempColList += ', ';
        SET @TempColList += QUOTENAME(@Cur_ColName) + ' ' + @Cur_DataType + ' NULL';

        IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = @TargetObjID AND name = @Cur_ColName)
        BEGIN
            IF LEN(@SharedColList) > 0 SET @SharedColList += ', ';
            SET @SharedColList += QUOTENAME(@Cur_ColName);
        END

        FETCH NEXT FROM ScriptCursor INTO @Cur_ColName, @Cur_DataType, @Cur_IsNullable;
    END
    CLOSE ScriptCursor;
    DEALLOCATE ScriptCursor;

    SET @CreateTableSQL = 'CREATE TABLE ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' (' + @ColList + ');';
    SET @CreateTempSQL = 'CREATE TABLE ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TempTableName) + ' (' + @TempColList + ');';

    -- =============================================
    -- 6. EXECUTION PHASE
    -- =============================================

    IF @TargetObjID IS NULL
    BEGIN
        PRINT 'Creating new table...'
        EXEC sp_executesql @CreateTableSQL;

        -- Add descriptions
        DECLARE DescCursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT ColumnName, Description FROM @ColumnsToAdd WHERE Description IS NOT NULL;
        OPEN DescCursor;
        FETCH NEXT FROM DescCursor INTO @Cur_ColName, @Cur_Desc;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC sp_addextendedproperty
                @name = N'MS_Description', @value = @Cur_Desc,
                @level0type = N'SCHEMA', @level0name = @SchemaName,
                @level1type = N'TABLE',  @level1name = @TableName,
                @level2type = N'COLUMN', @level2name = @Cur_ColName;
            FETCH NEXT FROM DescCursor INTO @Cur_ColName, @Cur_Desc;
        END
        CLOSE DescCursor;
        DEALLOCATE DescCursor;

        PRINT 'New table created successfully.'
    END
    ELSE
    BEGIN
        PRINT 'Table exists. Starting migration...'

        -- Drop referencing FKs
        IF LEN(@SqlDropFK) > 0
        BEGIN
            PRINT 'Dropping referencing FKs...'
            EXEC sp_executesql @SqlDropFK;
        END

        -- Create temp table
        EXEC sp_executesql @CreateTempSQL;

        -- Copy shared data
        IF LEN(@SharedColList) > 0
        BEGIN
            SET @CopySQL = 'INSERT INTO ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TempTableName) + ' (' + @SharedColList + ') SELECT ' + @SharedColList + ' FROM ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ';';
            PRINT 'Copying data...'
            EXEC sp_executesql @CopySQL;
        END

        -- Add descriptions to temp table
        DECLARE DescCursor2 CURSOR LOCAL FAST_FORWARD FOR
            SELECT ColumnName, Description FROM @ColumnsToAdd WHERE Description IS NOT NULL;
        OPEN DescCursor2;
        FETCH NEXT FROM DescCursor2 INTO @Cur_ColName, @Cur_Desc;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC sp_addextendedproperty
                @name = N'MS_Description', @value = @Cur_Desc,
                @level0type = N'SCHEMA', @level0name = @SchemaName,
                @level1type = N'TABLE',  @level1name = @TempTableName,
                @level2type = N'COLUMN', @level2name = @Cur_ColName;
            FETCH NEXT FROM DescCursor2 INTO @Cur_ColName, @Cur_Desc;
        END
        CLOSE DescCursor2;
        DEALLOCATE DescCursor2;

        -- Apply NOT NULL constraints
        DECLARE NNCursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT ColumnName, DataType FROM @ColumnsToAdd WHERE IsNullable = 'N';
        OPEN NNCursor;
        FETCH NEXT FROM NNCursor INTO @Cur_ColName, @Cur_DataType;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @AlterSQL = 'ALTER TABLE ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TempTableName) + ' ALTER COLUMN ' + QUOTENAME(@Cur_ColName) + ' ' + @Cur_DataType + ' NOT NULL;';
            BEGIN TRY
                EXEC sp_executesql @AlterSQL;
            END TRY
            BEGIN CATCH
                SET @Msg = 'Warning: Could not set NOT NULL on ' + @Cur_ColName;
                PRINT @Msg;
            END CATCH;
            FETCH NEXT FROM NNCursor INTO @Cur_ColName, @Cur_DataType;
        END
        CLOSE NNCursor;
        DEALLOCATE NNCursor;

        -- Swap tables using sp_rename
        PRINT 'Swapping tables...'
        SET @CurrentFullName = QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName);
        SET @TempFullName = QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TempTableName);

        EXEC sp_rename @CurrentFullName, @OldTableName;
        EXEC sp_rename @TempFullName, @TableName;

        -- Drop old table
        SET @DropOldSQL = 'DROP TABLE ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@OldTableName) + ';';
        EXEC sp_executesql @DropOldSQL;
        PRINT 'Old table dropped.'

        -- Recreate indexes and PK
        IF LEN(@SqlCreatePK_Indexes) > 0
        BEGIN
            PRINT 'Restoring PKs/Indexes...'
            EXEC sp_executesql @SqlCreatePK_Indexes;
        END

        -- Recreate foreign keys
        IF LEN(@SqlCreateFK) > 0
        BEGIN
            PRINT 'Restoring FKs...'
            EXEC sp_executesql @SqlCreateFK;
        END
    END

COMMIT TRANSACTION
PRINT 'Migration Completed Successfully.'

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    -- Reassign to variable first to handle potential concat issues in print
    SET @Msg = 'ERROR: ' + ERROR_MESSAGE() + ' (Line: ' + CAST(ERROR_LINE() AS NVARCHAR(10)) + ')';
    PRINT @Msg;
END CATCH;
