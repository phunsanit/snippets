-- USE DB_DEV;
-- USE DB_QA;
-- USE DB_PROD;

SET NOCOUNT ON;

BEGIN TRY
BEGIN TRANSACTION

    -- =============================================
    -- 1. CONFIGURATION
    -- =============================================
    DECLARE @SchemaName NVARCHAR(128) = ''
    DECLARE @TableName NVARCHAR(128) = 'wp_posts'

    -- Table Description
    DECLARE @TableDesc NVARCHAR(4000) = N'สำหรับเก็บ post';

    -- Check for NULL or Empty Schema -> Default to 'dbo'
    IF @SchemaName IS NULL OR LTRIM(RTRIM(@SchemaName)) = ''
        SET @SchemaName = 'dbo';

    -- Standard Variables
    DECLARE @TempTableName NVARCHAR(128) = @TableName + '_dup'
    DECLARE @OldTableName NVARCHAR(128) = @TableName + '_old'
    DECLARE @TargetObjID INT = OBJECT_ID(QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName))

    -- Dynamic SQL Variables
    DECLARE @SqlDropFK NVARCHAR(MAX) = '', @SqlCreateFK NVARCHAR(MAX) = '', @SqlCreatePK_Indexes NVARCHAR(MAX) = ''
    DECLARE @CreateTableSQL NVARCHAR(MAX), @CopySQL NVARCHAR(MAX), @DropOldSQL NVARCHAR(MAX)
    DECLARE @ColList NVARCHAR(MAX) = '', @SharedColList NVARCHAR(MAX) = '', @Msg NVARCHAR(MAX)
    DECLARE @IdentityColName NVARCHAR(128) = NULL
    DECLARE @PreserveIdentity BIT = 0
    DECLARE @CurrentFullName NVARCHAR(256), @TempFullName NVARCHAR(256)

    -- Cursor Helpers
    DECLARE @Cur_ColName NVARCHAR(128), @Cur_DataType NVARCHAR(100), @Cur_IsNullable CHAR(1), @Cur_Desc NVARCHAR(4000)
    DECLARE @Cur_FKID INT, @Cur_FKName NVARCHAR(128), @Cur_ParentSchema NVARCHAR(128), @Cur_ParentTable NVARCHAR(128)
    DECLARE @Helper_FKCols NVARCHAR(MAX), @Helper_RefCols NVARCHAR(MAX)
    DECLARE @Cur_IdxID INT, @Cur_IdxName NVARCHAR(128), @Cur_IsPK BIT, @Cur_IsUnique BIT, @Cur_IdxType TINYINT
    DECLARE @Helper_IdxCols NVARCHAR(MAX), @Helper_IncCols NVARCHAR(MAX)

    -- =============================================
    -- 2. DEFINE NEW STRUCTURE
    -- =============================================
    DECLARE @ColumnDefs TABLE (
        ID INT IDENTITY(1,1),
        ColumnName NVARCHAR(128),
        DataType NVARCHAR(100),
        IsNullable CHAR(1), -- 'Y' = NULL, 'N' = NOT NULL
        Description NVARCHAR(4000)
    );

    -- Insert Columns
    INSERT INTO @ColumnDefs (ColumnName, DataType, IsNullable, Description)
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
    -- 2.1 AUTO-DISCOVERY & IDENTITY CHECK
    -- =============================================

    -- Detect Identity Column Name in New Structure
    SELECT TOP 1 @IdentityColName = ColumnName FROM @ColumnDefs WHERE DataType LIKE '%IDENTITY%';

    IF @TargetObjID IS NOT NULL
    BEGIN
        PRINT '... Auto-detecting missing columns from existing table ...'
        INSERT INTO @ColumnDefs (ColumnName, DataType, IsNullable, Description)
        SELECT
            c.name,
            CASE
                WHEN t.name IN ('varchar', 'char', 'varbinary', 'binary') THEN
                    t.name + '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length AS VARCHAR) END + ')'
                WHEN t.name IN ('nvarchar', 'nchar') THEN
                    t.name + '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length / 2 AS VARCHAR) END + ')'
                WHEN t.name IN ('decimal', 'numeric') THEN
                    t.name + '(' + CAST(c.precision AS VARCHAR) + ',' + CAST(c.scale AS VARCHAR) + ')'
                ELSE
                    t.name
            END,
            CASE WHEN c.is_nullable = 1 THEN 'Y' ELSE 'N' END,
            ISNULL(CAST(ep.value AS NVARCHAR(4000)), '')
        FROM sys.columns c
        JOIN sys.types t ON c.user_type_id = t.user_type_id
        LEFT JOIN sys.extended_properties ep ON ep.major_id = c.object_id AND ep.minor_id = c.column_id AND ep.name = 'MS_Description'
        WHERE c.object_id = @TargetObjID
          AND c.is_computed = 0
          AND c.name NOT IN (SELECT ColumnName FROM @ColumnDefs)
        ORDER BY c.column_id;
        PRINT '   -> Auto-discovery complete.'
    END

    -- =============================================
    -- 3. BACKUP RELATIONS
    -- =============================================
    IF @TargetObjID IS NOT NULL
    BEGIN
        PRINT '... Backing up Relations/Indexes ...'
        -- FKs
        DECLARE FKCursor CURSOR LOCAL FAST_FORWARD FOR SELECT fk.object_id, fk.name, SCHEMA_NAME(fk.schema_id), OBJECT_NAME(fk.parent_object_id) FROM sys.foreign_keys fk WHERE fk.referenced_object_id = @TargetObjID;
        OPEN FKCursor; FETCH NEXT FROM FKCursor INTO @Cur_FKID, @Cur_FKName, @Cur_ParentSchema, @Cur_ParentTable;
        WHILE @@FETCH_STATUS = 0 BEGIN
            SELECT @Helper_FKCols = STUFF((SELECT ',' + QUOTENAME(c.name) FROM sys.foreign_key_columns fkc JOIN sys.columns c ON fkc.parent_object_id = c.object_id AND fkc.parent_column_id = c.column_id WHERE fkc.constraint_object_id = @Cur_FKID ORDER BY fkc.constraint_column_id FOR XML PATH('')), 1, 1, '');
            SELECT @Helper_RefCols = STUFF((SELECT ',' + QUOTENAME(c.name) FROM sys.foreign_key_columns fkc JOIN sys.columns c ON fkc.referenced_object_id = c.object_id AND fkc.referenced_column_id = c.column_id WHERE fkc.constraint_object_id = @Cur_FKID ORDER BY fkc.constraint_column_id FOR XML PATH('')), 1, 1, '');
            SET @SqlDropFK += 'ALTER TABLE ' + QUOTENAME(@Cur_ParentSchema) + '.' + QUOTENAME(@Cur_ParentTable) + ' DROP CONSTRAINT ' + QUOTENAME(@Cur_FKName) + ';' + CHAR(13);
            SET @SqlCreateFK += 'ALTER TABLE ' + QUOTENAME(@Cur_ParentSchema) + '.' + QUOTENAME(@Cur_ParentTable) + ' WITH NOCHECK ADD CONSTRAINT ' + QUOTENAME(@Cur_FKName) + ' FOREIGN KEY (' + @Helper_FKCols + ') REFERENCES ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' (' + @Helper_RefCols + ');' + CHAR(13);
            FETCH NEXT FROM FKCursor INTO @Cur_FKID, @Cur_FKName, @Cur_ParentSchema, @Cur_ParentTable;
        END
        CLOSE FKCursor; DEALLOCATE FKCursor;

        -- Indexes
        DECLARE IdxCursor CURSOR LOCAL FAST_FORWARD FOR SELECT index_id, name, is_primary_key, is_unique, type FROM sys.indexes WHERE object_id = @TargetObjID AND type IN (1, 2) ORDER BY is_primary_key DESC;
        OPEN IdxCursor; FETCH NEXT FROM IdxCursor INTO @Cur_IdxID, @Cur_IdxName, @Cur_IsPK, @Cur_IsUnique, @Cur_IdxType;
        WHILE @@FETCH_STATUS = 0 BEGIN
            SELECT @Helper_IdxCols = STUFF((SELECT ',' + QUOTENAME(c.name) + CASE WHEN ic.is_descending_key = 1 THEN ' DESC' ELSE ' ASC' END FROM sys.index_columns ic JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id WHERE ic.object_id = @TargetObjID AND ic.index_id = @Cur_IdxID AND ic.is_included_column = 0 ORDER BY ic.key_ordinal FOR XML PATH('')), 1, 1, '');
            SELECT @Helper_IncCols = STUFF((SELECT ',' + QUOTENAME(c.name) FROM sys.index_columns ic JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id WHERE ic.object_id = @TargetObjID AND ic.index_id = @Cur_IdxID AND ic.is_included_column = 1 ORDER BY ic.column_id FOR XML PATH('')), 1, 1, '');
            IF @Cur_IsPK = 1 SET @SqlCreatePK_Indexes += 'ALTER TABLE ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' ADD CONSTRAINT ' + QUOTENAME(@Cur_IdxName) + ' PRIMARY KEY ' + CASE WHEN @Cur_IdxType = 1 THEN 'CLUSTERED' ELSE 'NONCLUSTERED' END + ' (' + @Helper_IdxCols + ');' + CHAR(13);
            ELSE SET @SqlCreatePK_Indexes += 'CREATE ' + CASE WHEN @Cur_IsUnique = 1 THEN 'UNIQUE ' ELSE '' END + 'NONCLUSTERED INDEX ' + QUOTENAME(@Cur_IdxName) + ' ON ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' (' + @Helper_IdxCols + ')' + CASE WHEN LEN(@Helper_IncCols) > 0 THEN ' INCLUDE (' + @Helper_IncCols + ')' ELSE '' END + ';' + CHAR(13);
            FETCH NEXT FROM IdxCursor INTO @Cur_IdxID, @Cur_IdxName, @Cur_IsPK, @Cur_IsUnique, @Cur_IdxType;
        END
        CLOSE IdxCursor; DEALLOCATE IdxCursor;
    END

    -- =============================================
    -- 4. BUILD SCRIPTS & CHECK SHARED IDENTITY
    -- =============================================
    DECLARE ScriptCursor CURSOR LOCAL FAST_FORWARD FOR SELECT ColumnName, DataType, IsNullable FROM @ColumnDefs ORDER BY ID;
    OPEN ScriptCursor;
    FETCH NEXT FROM ScriptCursor INTO @Cur_ColName, @Cur_DataType, @Cur_IsNullable;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Build Create List
        IF LEN(@ColList) > 0 SET @ColList += ', ' + CHAR(13) + CHAR(10) + '    ';
        SET @ColList += QUOTENAME(@Cur_ColName) + ' ' + @Cur_DataType + CASE WHEN @Cur_IsNullable = 'Y' THEN ' NULL' ELSE ' NOT NULL' END;

        -- Build Shared Column List
        IF @TargetObjID IS NOT NULL AND EXISTS (SELECT 1 FROM sys.columns WHERE object_id = @TargetObjID AND name = @Cur_ColName)
        BEGIN
            IF LEN(@SharedColList) > 0 SET @SharedColList += ', ';
            SET @SharedColList += QUOTENAME(@Cur_ColName);

            -- [KEY FIX] If this shared column is the Identity Column, mark flag to Preserve Identity
            IF @IdentityColName IS NOT NULL AND @Cur_ColName = @IdentityColName
            BEGIN
                SET @PreserveIdentity = 1;
            END
        END

        FETCH NEXT FROM ScriptCursor INTO @Cur_ColName, @Cur_DataType, @Cur_IsNullable;
    END
    CLOSE ScriptCursor; DEALLOCATE ScriptCursor;

    -- =============================================
    -- 5. EXECUTION
    -- =============================================

    -- 5.1 Create Temp Table
    SET @CreateTableSQL = 'CREATE TABLE ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TempTableName) + ' (' + @ColList + ');';
    PRINT 'Creating Temp Table...'
    EXEC sp_executesql @CreateTableSQL;

    -- 5.2 Copy Data
    IF @TargetObjID IS NOT NULL AND LEN(@SharedColList) > 0
    BEGIN
        IF LEN(@SqlDropFK) > 0 EXEC sp_executesql @SqlDropFK;

        PRINT 'Copying data...'
        SET @CopySQL = '';

        -- Only set IDENTITY_INSERT ON if we are actually copying the Identity Column
        IF @PreserveIdentity = 1
        BEGIN
             SET @CopySQL += 'SET IDENTITY_INSERT ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TempTableName) + ' ON; ';
        END

        SET @CopySQL += 'INSERT INTO ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TempTableName) + ' (' + @SharedColList + ') ' +
                        'SELECT ' + @SharedColList + ' FROM ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + '; ';

        IF @PreserveIdentity = 1
        BEGIN
             SET @CopySQL += 'SET IDENTITY_INSERT ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TempTableName) + ' OFF; ';
        END

        EXEC sp_executesql @CopySQL;
    END

    -- 5.3 Column Descriptions
    DECLARE DescCursor CURSOR LOCAL FAST_FORWARD FOR SELECT ColumnName, Description FROM @ColumnDefs WHERE Description IS NOT NULL AND Description <> '';
    OPEN DescCursor;
    FETCH NEXT FROM DescCursor INTO @Cur_ColName, @Cur_Desc;
    WHILE @@FETCH_STATUS = 0 BEGIN
        EXEC sp_addextendedproperty @name = N'MS_Description', @value = @Cur_Desc, @level0type = N'SCHEMA', @level0name = @SchemaName, @level1type = N'TABLE',  @level1name = @TempTableName, @level2type = N'COLUMN', @level2name = @Cur_ColName;
        FETCH NEXT FROM DescCursor INTO @Cur_ColName, @Cur_Desc;
    END
    CLOSE DescCursor; DEALLOCATE DescCursor;

    -- 5.4 Table Description
    PRINT 'Adding Table Description...'
    EXEC sp_addextendedproperty @name = N'MS_Description', @value = @TableDesc, @level0type = N'SCHEMA', @level0name = @SchemaName, @level1type = N'TABLE',  @level1name = @TempTableName;

    -- 5.5 Swap Tables
    IF @TargetObjID IS NOT NULL
    BEGIN
        PRINT 'Swapping tables...'
        SET @CurrentFullName = QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName);
        SET @TempFullName = QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TempTableName);

        EXEC sp_rename @CurrentFullName, @OldTableName;
        EXEC sp_rename @TempFullName, @TableName;

        SET @DropOldSQL = 'DROP TABLE ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@OldTableName) + ';';
        EXEC sp_executesql @DropOldSQL;

        IF LEN(@SqlCreatePK_Indexes) > 0 EXEC sp_executesql @SqlCreatePK_Indexes;
        IF LEN(@SqlCreateFK) > 0 EXEC sp_executesql @SqlCreateFK;
    END
    ELSE
    BEGIN
        SET @TempFullName = QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TempTableName);
        EXEC sp_rename @TempFullName, @TableName;
    END

COMMIT TRANSACTION
PRINT 'Migration Completed Successfully.'

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    SET @Msg = 'ERROR: ' + ERROR_MESSAGE() + ' (Line: ' + CAST(ERROR_LINE() AS NVARCHAR(10)) + ')';
    PRINT @Msg;
END CATCH;
