SELECT
    CONCAT(
        'SELECT ''', T.Real_Table_Name, ''' AS table_Name,',
        T.PK_Col, ''' AS PK_column,',
        'COALESCE(MAX(`', T.PK_Col, '`), 0) AS max_existing_id, ',
        T.System_AutoInc, ' AS running_auto_increment, ',
        -- ส่วนเช็คเงื่อนไขและสร้างคำสั่งแก้
        'CASE WHEN ', T.System_AutoInc, ' <= COALESCE(MAX(`', T.PK_Col, '`), 0) ',
        'THEN CONCAT(''ALTER TABLE `', T.Real_Table_Name, '` AUTO_INCREMENT = '', MAX(`', T.PK_Col, '`) + 1, '';'') ',
        'ELSE '''' END AS SQL_Fix_Command ',

        'FROM `', T.Real_Table_Name, '` UNION ALL '
    ) as Copy_This_Code
FROM (
    SELECT
        t.TABLE_NAME as Real_Table_Name,
        t.AUTO_INCREMENT as System_AutoInc,
        k.COLUMN_NAME as PK_Col
    FROM information_schema.TABLES t
    JOIN information_schema.KEY_COLUMN_USAGE k
        ON t.TABLE_SCHEMA = k.TABLE_SCHEMA
        AND t.TABLE_NAME = k.TABLE_NAME
    WHERE t.TABLE_SCHEMA = DATABASE()
      AND t.AUTO_INCREMENT IS NOT NULL
      AND k.CONSTRAINT_NAME = 'PRIMARY'

      -- กรองเฉพาะตารางที่มีคำว่า 'wp_' (หรือเปลี่ยนเป็น '%' เพื่อเอาทั้งหมด)
      AND t.TABLE_NAME LIKE '%wp_%'

    GROUP BY t.TABLE_NAME
    HAVING COUNT(k.COLUMN_NAME) = 1
) AS T;
