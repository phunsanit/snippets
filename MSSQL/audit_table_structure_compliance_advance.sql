/*
    Script: Audit Table Structure Compliance (With Schema Name)
    Logic:
    1. ตรวจสอบ ibs_puid (varchar 100)
    2. ตรวจสอบ ibs_timestamp (datetime)
    3. ค้นหา Prefix จากคอลัมน์ที่ลงท้ายด้วย '_CREATE_BY'
    4. ตรวจสอบ Audit Columns ที่เหลือตาม Prefix นั้น (_CREATE_DT, _MODIFY_BY, _MODIFY_DT)
*/

USE INSAPP; -- อย่าลืมเปลี่ยนเป็นชื่อ Database ที่ต้องการตรวจสอบ

WITH TableList AS (
    SELECT
        t.object_id,
        s.name AS SchemaName, -- เพิ่ม Schema Name
        t.name AS TableName
    FROM sys.tables t
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id -- Join เพื่อเอาชื่อ Schema
    WHERE t.name <> 'sysdiagrams'
),
PrefixFinder AS (
    SELECT
        c.object_id,
        LEFT(c.name, LEN(c.name) - LEN('_CREATE_BY')) AS DetectedPrefix
    FROM sys.columns c
    WHERE c.name LIKE '%_CREATE_BY'
),
AuditResults AS (
    SELECT
        t.SchemaName, -- ส่งต่อค่า Schema Name
        t.TableName,
        p.DetectedPrefix,

        -- 1. Check 'ibs_puid' (Must be varchar(100))
        CASE WHEN EXISTS (
            SELECT 1 FROM sys.columns c
            JOIN sys.types ty ON c.user_type_id = ty.user_type_id
            WHERE c.object_id = t.object_id
            AND c.name = 'ibs_puid'
            AND ty.name = 'varchar'
            AND c.max_length = 100
        ) THEN 1 ELSE 0 END AS Has_IBS_PUID,

        -- 2. Check 'ibs_timestamp' (Must be datetime)
        CASE WHEN EXISTS (
            SELECT 1 FROM sys.columns c
            JOIN sys.types ty ON c.user_type_id = ty.user_type_id
            WHERE c.object_id = t.object_id
            AND c.name = 'ibs_timestamp'
            AND ty.name = 'datetime'
        ) THEN 1 ELSE 0 END AS Has_IBS_TIMESTAMP,

        -- 3. Check Audit Columns (Based on Detected Prefix)
        -- _CREATE_BY
        CASE WHEN p.DetectedPrefix IS NULL THEN 0
             WHEN EXISTS (
                SELECT 1 FROM sys.columns c JOIN sys.types ty ON c.user_type_id = ty.user_type_id
                WHERE c.object_id = t.object_id AND c.name = p.DetectedPrefix + '_CREATE_BY' AND ty.name = 'varchar' AND c.max_length = 30
             ) THEN 1 ELSE 0 END AS Valid_CREATE_BY,

        -- _CREATE_DT
        CASE WHEN p.DetectedPrefix IS NULL THEN 0
             WHEN EXISTS (
                SELECT 1 FROM sys.columns c JOIN sys.types ty ON c.user_type_id = ty.user_type_id
                WHERE c.object_id = t.object_id AND c.name = p.DetectedPrefix + '_CREATE_DT' AND ty.name = 'datetime'
             ) THEN 1 ELSE 0 END AS Valid_CREATE_DT,

        -- _MODIFY_BY
        CASE WHEN p.DetectedPrefix IS NULL THEN 0
             WHEN EXISTS (
                SELECT 1 FROM sys.columns c JOIN sys.types ty ON c.user_type_id = ty.user_type_id
                WHERE c.object_id = t.object_id AND c.name = p.DetectedPrefix + '_MODIFY_BY' AND ty.name = 'varchar' AND c.max_length = 30
             ) THEN 1 ELSE 0 END AS Valid_MODIFY_BY,

        -- _MODIFY_DT
        CASE WHEN p.DetectedPrefix IS NULL THEN 0
             WHEN EXISTS (
                SELECT 1 FROM sys.columns c JOIN sys.types ty ON c.user_type_id = ty.user_type_id
                WHERE c.object_id = t.object_id AND c.name = p.DetectedPrefix + '_MODIFY_DT' AND ty.name = 'datetime'
             ) THEN 1 ELSE 0 END AS Valid_MODIFY_DT

    FROM TableList t
    LEFT JOIN PrefixFinder p ON t.object_id = p.object_id
)
SELECT
    SchemaName, -- แสดง Schema Name
    TableName,
    ISNULL(DetectedPrefix, '(No Prefix Found)') AS Prefix,
    CASE
        WHEN Has_IBS_PUID = 1
             AND Has_IBS_TIMESTAMP = 1
             AND Valid_CREATE_BY = 1
             AND Valid_CREATE_DT = 1
             AND Valid_MODIFY_BY = 1
             AND Valid_MODIFY_DT = 1
        THEN 'PASS'
        ELSE 'FAIL'
    END AS Status,

    -- Error Message Generation
    STUFF(
        (CASE WHEN Has_IBS_PUID = 0 THEN ', Missing/Wrong ibs_puid' ELSE '' END) +
        (CASE WHEN Has_IBS_TIMESTAMP = 0 THEN ', Missing/Wrong ibs_timestamp' ELSE '' END) +
        (CASE WHEN DetectedPrefix IS NULL THEN ', No _CREATE_BY column found' ELSE
            (CASE WHEN Valid_CREATE_BY = 0 THEN ', Wrong Type ' + DetectedPrefix + '_CREATE_BY' ELSE '' END) +
            (CASE WHEN Valid_CREATE_DT = 0 THEN ', Missing/Wrong ' + DetectedPrefix + '_CREATE_DT' ELSE '' END) +
            (CASE WHEN Valid_MODIFY_BY = 0 THEN ', Missing/Wrong ' + DetectedPrefix + '_MODIFY_BY' ELSE '' END) +
            (CASE WHEN Valid_MODIFY_DT = 0 THEN ', Missing/Wrong ' + DetectedPrefix + '_MODIFY_DT' ELSE '' END)
         END), 1, 2, ''
    ) AS Issues
FROM AuditResults
ORDER BY Status, SchemaName, TableName; -- เรียงตาม Schema ด้วย
