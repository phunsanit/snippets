/*
https://learn.microsoft.com/en-us/sql/t-sql/data-types/time-transact-sql?view=sql-server-ver16#table-structure

Reference Storage Size:
1. DATETIME2 & TIME: https://learn.microsoft.com/en-us/sql/t-sql/data-types/datetime2-transact-sql?view=sql-server-ver16#table-structure
   - Precision 0-2: 6 bytes
   - Precision 3-4: 7 bytes
   - Precision 5-7: 8 bytes
2. DATETIME (Legacy):
   - Fixed 8 bytes (Less precision than datetime2)
3. DECIMAL/NUMERIC:
   - Precision 1-9: 5 bytes
   - Precision 10-19: 9 bytes
   - Precision 20-28: 13 bytes
   - Precision 29-38: 17 bytes
*/

WITH StorageCalc AS (
    SELECT
        table_catalog,
        table_schema,
        table_name,
        column_name,
        DATA_TYPE,
        COALESCE(NUMERIC_PRECISION, DATETIME_PRECISION) AS CurrentPrecision,
        NUMERIC_SCALE AS CurrentScale,

        -- คำนวณขนาด Storage ปัจจุบัน (โดยประมาณ) เพื่อเปรียบเทียบ
        CASE
            WHEN DATA_TYPE = 'datetime' THEN 8
            WHEN DATA_TYPE IN ('datetime2', 'time') THEN
                CASE
                    WHEN DATETIME_PRECISION <= 2 THEN 6
                    WHEN DATETIME_PRECISION <= 4 THEN 7
                    ELSE 8
                END
             -- (ละเว้นกลุ่ม Decimal ไว้คงเดิมสำหรับ logic นี้)
        END AS CurrentStorageBytes
    FROM
        information_schema.columns
    WHERE
        DATA_TYPE IN ('decimal', 'numeric', 'datetime', 'datetime2', 'time', 'datetimeoffset')
        AND table_schema NOT IN ('sys', 'information_schema') -- กรอง System tables ออก
),
OptimizationLogic AS (
    SELECT
        *,
        CASE
            -------------------------------------------------------
            -- 1. เปลี่ยน DATETIME (8 bytes) เป็น DATETIME2(3) (7 bytes)
            --    ประหยัดพื้นที่ได้จริง 1 Byte และแม่นยำกว่าเดิม
            -------------------------------------------------------
                WHEN DATA_TYPE = 'datetime' THEN 'datetime2'

            ELSE DATA_TYPE
        END AS SuggestedDataType,

        CASE
            -------------------------------------------------------
            -- กลุ่ม DECIMAL (เหมือนเดิม)
            -------------------------------------------------------
            WHEN DATA_TYPE IN ('decimal', 'numeric') THEN
                CASE
                    WHEN CurrentPrecision BETWEEN 1 AND 9 THEN 9
                    WHEN CurrentPrecision BETWEEN 10 AND 19 THEN 19
                    WHEN CurrentPrecision BETWEEN 20 AND 28 THEN 28
                    WHEN CurrentPrecision BETWEEN 29 AND 38 THEN 38
                END

            -------------------------------------------------------
                -- 2. กรณีเจอ DATETIME เดิม ให้แนะนำ Precision 2 (6 bytes)
                --    (ประหยัดกว่าเดิม 2 bytes และครอบคลุมวินาที)
                -------------------------------------------------------
                WHEN DATA_TYPE = 'datetime' THEN 2

            -------------------------------------------------------
            -- 3. ปรับ DATETIME2 / TIME / OFFSET ให้คุ้ม Storage Bucket
            -------------------------------------------------------
            WHEN DATA_TYPE IN ('datetime2', 'time', 'datetimeoffset') THEN
                CASE
                    -- ใช้ 6 Bytes เท่ากัน -> เอาให้สุดที่ 2
                    WHEN CurrentPrecision BETWEEN 0 AND 2 THEN 2
                    -- ใช้ 7 Bytes เท่ากัน -> เอาให้สุดที่ 4
                    WHEN CurrentPrecision BETWEEN 3 AND 4 THEN 4
                    -- ใช้ 8 Bytes เท่ากัน -> เอาให้สุดที่ 7
                    WHEN CurrentPrecision BETWEEN 5 AND 7 THEN 7
                END
        END AS SuggestedPrecision
    FROM StorageCalc
)
SELECT
    table_catalog AS DatabaseName,
    table_schema AS SchemaName,
    table_name AS TableName,
    column_name AS ColumnName,

    -- แสดงสถานะปัจจุบัน
    UPPER(DATA_TYPE) +
    CASE
        WHEN DATA_TYPE IN ('decimal', 'numeric') THEN '(' + CAST(CurrentPrecision AS VARCHAR) + ',' + CAST(CurrentScale AS VARCHAR) + ')'
        WHEN DATA_TYPE = 'datetime' THEN '' -- datetime ไม่มี precision ให้โชว์
        ELSE '(' + CAST(CurrentPrecision AS VARCHAR) + ')'
    END AS CurrentType,

    -- คำแนะนำใหม่
    UPPER(SuggestedDataType) +
    CASE
        WHEN SuggestedDataType IN ('decimal', 'numeric') THEN '(' + CAST(SuggestedPrecision AS VARCHAR) + ',' + CAST(CurrentScale AS VARCHAR) + ')'
        ELSE '(' + CAST(SuggestedPrecision AS VARCHAR) + ')'
    END AS SuggestedType,

    -- ไฮไลท์ว่าทำไมถึงแนะนำ
    CASE
        WHEN DATA_TYPE = 'datetime' THEN 'Save 1 Byte & Better Precision'
        WHEN SuggestedPrecision > CurrentPrecision THEN 'Maximize Precision for same Storage Size'
        ELSE 'Optimize Type'
    END AS OptimizationReason,

    -- Script ALTER
    'ALTER TABLE ' + Quotename(table_schema) + '.' + Quotename(table_name) +
    ' ALTER COLUMN ' + Quotename(column_name) + ' ' +
    UPPER(SuggestedDataType) +
    CASE
        WHEN SuggestedDataType IN ('decimal', 'numeric') THEN '(' + CAST(SuggestedPrecision AS VARCHAR) + ',' + CAST(CurrentScale AS VARCHAR) + ')'
        ELSE '(' + CAST(SuggestedPrecision AS VARCHAR) + ')'
    END + ';' AS AlterScript

FROM OptimizationLogic
WHERE
    -- กรองเฉพาะแถวที่ควรแก้ (Type เปลี่ยน หรือ Precision เปลี่ยน)
    (DATA_TYPE != SuggestedDataType)
    OR (CurrentPrecision != SuggestedPrecision)
ORDER BY
    DatabaseName,  -- เรียงตาม Database
    SchemaName,    -- เรียงตาม Schema
    TableName,     -- เรียงตาม Table
    ColumnName;    -- เรียงตาม Column
