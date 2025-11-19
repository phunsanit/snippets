/*
Reference Storage Size:
1. BIT:
   https://learn.microsoft.com/en-us/sql/t-sql/data-types/bit-transact-sql?view=sql-server-ver16#storage
   - The SQL Server Database Engine optimizes storage of bit columns.
   - If there are 8 or fewer bit columns in a table, the columns are stored as 1 byte.
   - If there are from 9 up to 16 bit columns, they are stored as 2 bytes, and so on.
   (Formula: CEILING(TotalBits / 8) Bytes)
*/

WITH BitColumnStats AS (
    SELECT
        table_catalog,
        table_schema,
        table_name,
        COUNT(*) AS TotalBitColumns
    FROM
        information_schema.columns
    WHERE
        DATA_TYPE = 'bit'
        AND table_schema NOT IN ('sys', 'information_schema')
    GROUP BY
        table_catalog, table_schema, table_name
)
SELECT
    table_catalog AS DatabaseName,
    table_schema AS SchemaName,
    table_name AS TableName,
    TotalBitColumns,

    -- คำนวณจำนวน Bytes ที่ใช้จริงสำหรับกลุ่ม BIT นี้
    -- สูตร: ปัดเศษขึ้นของ (จำนวนคอลัมน์ / 8)
    CEILING(TotalBitColumns / 8.0) AS StorageBytesUsed,

    -- คำนวณว่าเหลือที่ว่างอีกกี่ Bit ใน Byte ก้อนปัจจุบัน
    (CAST(CEILING(TotalBitColumns / 8.0) AS INT) * 8) - TotalBitColumns AS FreeBitsAvailable,

    -- วิเคราะห์และให้คำแนะนำ
    CASE
        WHEN (CAST(CEILING(TotalBitColumns / 8.0) AS INT) * 8) - TotalBitColumns = 0 THEN
            'Full Packing: Efficiently used. (Next BIT column will cost +1 Byte)'
        ELSE
            'Free Capacity: Can add ' +
            CAST((CAST(CEILING(TotalBitColumns / 8.0) AS INT) * 8) - TotalBitColumns AS VARCHAR) +
            ' more BIT column(s) without increasing row size.'
    END AS EfficiencyInsight

FROM
    BitColumnStats
ORDER BY
    DatabaseName,  -- เรียงตาม Database
    SchemaName,    -- เรียงตาม Schema
    TableName;     -- เรียงตาม Table (ไม่มี ColumnName เพราะเป็นการนับรวมทั้งตาราง)
