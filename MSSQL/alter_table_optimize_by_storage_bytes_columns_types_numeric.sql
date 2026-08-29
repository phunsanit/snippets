/*
Reference Storage Size:
1. DECIMAL / NUMERIC:
   https://learn.microsoft.com/en-us/sql/t-sql/data-types/decimal-and-numeric-transact-sql?view=sql-server-ver16#storage
   - Precision 1-9   : 5 bytes
   - Precision 10-19 : 9 bytes
   - Precision 20-28 : 13 bytes
   - Precision 29-38 : 17 bytes

2. FLOAT / REAL:
   https://learn.microsoft.com/en-us/sql/t-sql/data-types/float-and-real-transact-sql?view=sql-server-ver16#storage
   - REAL  (Precision 1-24)  : 4 bytes
   - FLOAT (Precision 25-53) : 8 bytes
*/

WITH ColumnsToOptimize AS (
    SELECT
        table_catalog,
        table_schema,
        table_name,
        column_name,
        DATA_TYPE,
        NUMERIC_PRECISION,
        NUMERIC_SCALE,

        -- 1. คำนวณ Storage Bytes ที่ใช้อยู่ปัจจุบัน
        CASE
            -- กลุ่ม DECIMAL / NUMERIC
            WHEN DATA_TYPE IN ('decimal', 'numeric') THEN
                CASE
                    WHEN NUMERIC_PRECISION BETWEEN 1 AND 9 THEN 5
                    WHEN NUMERIC_PRECISION BETWEEN 10 AND 19 THEN 9
                    WHEN NUMERIC_PRECISION BETWEEN 20 AND 28 THEN 13
                    WHEN NUMERIC_PRECISION BETWEEN 29 AND 38 THEN 17
                END
            -- กลุ่ม FLOAT / REAL
            WHEN DATA_TYPE IN ('float', 'real') THEN
                CASE
                    WHEN NUMERIC_PRECISION <= 24 THEN 4
                    WHEN NUMERIC_PRECISION BETWEEN 25 AND 53 THEN 8
                END
        END AS StorageBytes,

        -- 2. คำนวณ Precision สูงสุดที่แนะนำ (ใน Storage Bucket เดียวกัน)
        CASE
            -- กลุ่ม DECIMAL / NUMERIC
            WHEN DATA_TYPE IN ('decimal', 'numeric') THEN
                CASE
                    WHEN NUMERIC_PRECISION BETWEEN 1 AND 9 THEN 9
                    WHEN NUMERIC_PRECISION BETWEEN 10 AND 19 THEN 19
                    WHEN NUMERIC_PRECISION BETWEEN 20 AND 28 THEN 28
                    WHEN NUMERIC_PRECISION BETWEEN 29 AND 38 THEN 38
                END
            -- กลุ่ม FLOAT / REAL (Step มีแค่ 24 หรือ 53)
            WHEN DATA_TYPE IN ('float', 'real') THEN
                CASE
                    WHEN NUMERIC_PRECISION <= 24 THEN 24
                    WHEN NUMERIC_PRECISION BETWEEN 25 AND 53 THEN 53
                END
        END AS SuggestedPrecision
    FROM
        information_schema.columns
    WHERE
        DATA_TYPE IN ('decimal', 'numeric', 'float', 'real')
        AND table_schema NOT IN ('sys', 'information_schema') -- กรอง System Tables ออก
)
SELECT
    c.table_catalog AS DatabaseName,
    c.table_schema AS SchemaName,
    c.table_name AS TableName,
    c.column_name AS ColumnName,

    -- แสดง Type ปัจจุบัน
    CASE
        WHEN c.DATA_TYPE IN ('float', 'real') THEN UPPER(c.DATA_TYPE) + '(' + CAST(c.NUMERIC_PRECISION AS VARCHAR) + ')'
        ELSE UPPER(c.DATA_TYPE) + '(' + CAST(c.NUMERIC_PRECISION AS VARCHAR) + ', ' + CAST(c.NUMERIC_SCALE AS VARCHAR) + ')'
    END AS CurrentType,

    -- เหตุผลการ Optimization
    'Maximize Precision: Increase ' + CAST(c.NUMERIC_PRECISION AS VARCHAR) +
    ' -> ' + CAST(c.SuggestedPrecision AS VARCHAR) +
    ' (Both use ' + CAST(c.StorageBytes AS VARCHAR) + ' bytes)' AS OptimizationReason,

    -- สร้าง SuggestedType
    CASE
        -- Float ใช้พารามิเตอร์ตัวเดียว
        WHEN c.DATA_TYPE IN ('float', 'real') THEN
             'FLOAT(' + CAST(c.SuggestedPrecision AS VARCHAR(2)) + ')'
        -- Decimal ใช้พารามิเตอร์ (p, s)
        ELSE
             UPPER(c.DATA_TYPE) + '(' + CAST(c.SuggestedPrecision AS VARCHAR(2)) + ', ' + CAST(c.NUMERIC_SCALE AS VARCHAR(2)) + ')'
    END AS SuggestedType,

    -- สร้างสคริปต์ ALTER
    'ALTER TABLE ' + Quotename(c.table_schema) + '.' + Quotename(c.table_name) +
    ' ALTER COLUMN ' + Quotename(c.column_name) + ' ' +
    CASE
        WHEN c.DATA_TYPE IN ('float', 'real') THEN
             'FLOAT(' + CAST(c.SuggestedPrecision AS VARCHAR(2)) + ')'
        ELSE
             UPPER(c.DATA_TYPE) + '(' + CAST(c.SuggestedPrecision AS VARCHAR(2)) + ', ' + CAST(c.NUMERIC_SCALE AS VARCHAR(2)) + ')'
    END + ';' AS alter_sql
FROM
    ColumnsToOptimize AS c
WHERE
    -- กรองเอาเฉพาะตัวที่ Precision ไม่เต็ม Bucket
    c.SuggestedPrecision IS NOT NULL
    AND c.NUMERIC_PRECISION != c.SuggestedPrecision
ORDER BY
    DatabaseName,  -- เรียงตาม Database
    SchemaName,    -- เรียงตาม Schema
    TableName,     -- เรียงตาม Table
    ColumnName;    -- เรียงตาม Column
