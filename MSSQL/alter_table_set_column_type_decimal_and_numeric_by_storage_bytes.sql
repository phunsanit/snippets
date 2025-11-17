-- ใช้ CTE เพื่อคำนวณ Precision ที่แนะนำตามกลยุทธ์ Storage
WITH ColumnsToOptimize AS (
    SELECT
        table_catalog,
        table_schema,
        table_name,
        column_name,
        DATA_TYPE,
        NUMERIC_PRECISION,
        NUMERIC_SCALE,

        -- นี่คือตรรกะจากตาราง Storage (5/9/13/17 bytes)
        CASE
            WHEN NUMERIC_PRECISION BETWEEN 1 AND 9 THEN 9
            WHEN NUMERIC_PRECISION BETWEEN 10 AND 19 THEN 19
            WHEN NUMERIC_PRECISION BETWEEN 20 AND 28 THEN 28
            WHEN NUMERIC_PRECISION BETWEEN 29 AND 38 THEN 38
        END AS SuggestedPrecision
    FROM
        information_schema.columns
    WHERE
        DATA_TYPE IN ('decimal', 'numeric')
)
-- เลือกเฉพาะคอลัมน์ที่ Precision ปัจจุบัน ไม่ใช่ค่าที่ดีที่สุด
SELECT
    c.table_catalog AS DatabaseName,
    c.table_schema AS SchemaName,
    c.table_name AS TableName,
    c.column_name AS ColumnName,
    c.DATA_TYPE AS CurrentColumnType,
    c.NUMERIC_PRECISION AS CurrentPrecision,
    c.NUMERIC_SCALE AS CurrentScale,

    -- สร้าง SuggestedType โดยใช้ Precision ที่แนะนำ และ Scale เดิม
    'DECIMAL(' + CAST(c.SuggestedPrecision AS VARCHAR(2)) + ', ' + CAST(c.NUMERIC_SCALE AS VARCHAR(2)) + ')' AS SuggestedType,

    -- สร้างสคริปต์ ALTER
    'ALTER TABLE ' + Quotename(c.table_schema) + '.' + Quotename(c.table_name) +
    ' ALTER COLUMN ' + Quotename(c.column_name) +
    ' DECIMAL(' + CAST(c.SuggestedPrecision AS VARCHAR(2)) + ', ' + CAST(c.NUMERIC_SCALE AS VARCHAR(2)) + ');' AS alter_sql
FROM
    ColumnsToOptimize AS c
WHERE
    -- แสดงเฉพาะรายการที่ Precision ปัจจุบัน "ไม่เท่ากับ" ค่าที่แนะนำ
    c.NUMERIC_PRECISION != c.SuggestedPrecision;
