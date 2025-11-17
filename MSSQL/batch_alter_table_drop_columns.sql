-- USE DB_DEV;
-- USE DB_QA;
-- USE DB_SIT;
-- USE DB_PRO;

-- 1. Configuration
DECLARE @SchemaName AS NVARCHAR(128) = N'PItt';
DECLARE @TableName AS NVARCHAR(128) = N'Phunsanit';

-- 2. stop scrip if column not null and empty
DECLARE @StopScript BIT = 0; -- flag to stop the script

-- 3. Variables for the script
DECLARE @FullTableName NVARCHAR(257);
DECLARE @TableObjectID INT;
DECLARE @CurrentColumnName NVARCHAR(128);
DECLARE @SqlStatement NVARCHAR(MAX);
DECLARE @HasData BIT = 0;
DECLARE @CheckSql NVARCHAR(MAX);
DECLARE @CheckParams NVARCHAR(100) = N'@HasData BIT OUTPUT';
DECLARE @DataTypeName NVARCHAR(128); -- <-- NEW: To store the column's data type

-- 4. Define the list of columns you want to drop
DECLARE @ColumnsToDrop TABLE (
    ColumnName NVARCHAR(128) PRIMARY KEY
);

INSERT INTO @ColumnsToDrop (ColumnName)
VALUES
    (N'created_at'),
    (N'created_by'),
    (N'deleted_at'),
    (N'deleted_by'),
    (N'updated_at'),
    (N'updated_by'),

-- 5. Store the actual commands to run (if checks pass)
DECLARE @CommandsToRun TABLE (
    SqlStatement NVARCHAR(MAX),
    ColumnName NVARCHAR(128)
);

-- 6. Safety Check: Stop if the table itself doesn't exist
SET @FullTableName = QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName);
SET @TableObjectID = OBJECT_ID(@FullTableName);

IF @TableObjectID IS NULL
BEGIN
    PRINT 'Error: The table ' + @FullTableName + ' does not exist. Halting script.';
    RETURN; -- Stops the script
END

PRINT '--- PRE-CHECK ---';
PRINT 'Checking columns on table: ' + @FullTableName;

-- 7. Create a cursor to loop through and check each column
DECLARE col_cursor CURSOR FOR
SELECT ColumnName FROM @ColumnsToDrop;

OPEN col_cursor;

FETCH NEXT FROM col_cursor INTO @CurrentColumnName;

-- 8. First Loop (Pre-Check)
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @HasData = 0; -- Reset flag for each column

    -- Check if the column exists on this specific table
    IF EXISTS (SELECT 1
               FROM sys.columns c
               WHERE c.object_id = @TableObjectID
                 AND c.name = @CurrentColumnName)
    BEGIN

        -- *** MODIFIED BLOCK ***
        -- First, get the column's data type
        SELECT @DataTypeName = ty.name
        FROM sys.columns c
        JOIN sys.types ty ON c.user_type_id = ty.user_type_id
        WHERE c.object_id = @TableObjectID
          AND c.name = @CurrentColumnName;

        -- Now build the data check SQL based on the type
        IF @DataTypeName IN (N'varchar', N'nvarchar', N'char', N'nchar', N'text', N'ntext')
        BEGIN
            -- For string types, check for NOT NULL AND not empty string (your request)
            -- This means NULLs or '' (empty strings) are OK to drop
            SET @CheckSql = N'SELECT TOP 1 @HasData = 1 FROM ' + @FullTableName +
                            N' WHERE ' + QUOTENAME(@CurrentColumnName) + N' IS NOT NULL' +
                            N' AND ' + QUOTENAME(@CurrentColumnName) + N' != '''''; -- '''' is an escaped '
            PRINT '  [INFO] Column ' + QUOTENAME(@CurrentColumnName) + ' is a string. Checking for data (not NULL and not '''').';
        END
        ELSE
        BEGIN
            -- For non-string types (int, datetime, etc.), just check for NOT NULL
            SET @CheckSql = N'SELECT TOP 1 @HasData = 1 FROM ' + @FullTableName +
                            N' WHERE ' + QUOTENAME(@CurrentColumnName) + N' IS NOT NULL';
            PRINT '  [INFO] Column ' + QUOTENAME(@CurrentColumnName) + ' is not a string. Checking for data (not NULL).';
        END

        -- Run the dynamic check
        EXEC sp_executesql @CheckSql, @CheckParams, @HasData = @HasData OUTPUT;
        -- *** END OF MODIFIED BLOCK ***

        IF @HasData = 1
        BEGIN
            -- Data found! Mark the script to stop.
            PRINT '  [ERROR] Column ' + QUOTENAME(@CurrentColumnName) + ' contains data. Script will be stopped.';
            SET @StopScript = 1;
        END
        ELSE
        BEGIN
            -- Column is empty (all NULL or ''). It is safe to drop.
            PRINT '  [OK] Column ' + QUOTENAME(@CurrentColumnName) + ' is empty. Queued for drop.';

            -- Add the drop command to our queue
            SET @SqlStatement = N'ALTER TABLE ' + @FullTableName +
                                N' DROP COLUMN ' + QUOTENAME(@CurrentColumnName);
            INSERT INTO @CommandsToRun (SqlStatement, ColumnName)
            VALUES (@SqlStatement, @CurrentColumnName);
        END
    END
    ELSE
    BEGIN
        -- Column does not exist, so skip it
        PRINT '  [INFO] Column ' + QUOTENAME(@CurrentColumnName) + ' (does not exist). Skipping.';
    END

    -- Get the next column from the list
    FETCH NEXT FROM col_cursor INTO @CurrentColumnName;
END;

-- 9. Clean up the check cursor
CLOSE col_cursor;
DEALLOCATE col_cursor;

-- 10. THE "STOP" CHECK
PRINT '---';
IF @StopScript = 1
BEGIN
    PRINT 'Execution HALTED. One or more columns contained data (see [ERROR] messages above).';
    PRINT 'No columns were dropped.';
    RETURN; -- This is the STOP you requested
END

-- 11. Execution (only runs if @StopScript is still 0)
PRINT 'All checks passed. Proceeding with drop operations...';

DECLARE exec_cursor CURSOR FOR
SELECT SqlStatement, ColumnName FROM @CommandsToRun;

OPEN exec_cursor;

FETCH NEXT FROM exec_cursor INTO @SqlStatement, @CurrentColumnName;

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN TRY
        EXEC sp_executesql @SqlStatement;
        PRINT '  Successfully dropped column: ' + QUOTENAME(@CurrentColumnName);
    END TRY
    BEGIN CATCH
        PRINT '  ERROR: Could not drop column ' + QUOTENAME(@CurrentColumnName) + '. Please check dependencies (indexes, constraints).';
        PRINT '  Error Message: ' + ERROR_MESSAGE();
    END CATCH

    FETCH NEXT FROM exec_cursor INTO @SqlStatement, @CurrentColumnName;
END;

-- 12. Clean up the execution cursor
CLOSE exec_cursor;
DEALLOCATE exec_cursor;

PRINT 'Column drop process complete.';
