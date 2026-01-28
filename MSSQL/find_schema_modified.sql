SELECT
    name AS TableName
    ,create_date AS CreatedDate
    ,modify_date AS LastModifiedDate
FROM
    sys.objects
WHERE
    TYPE = 'U' -- 'U' คือ User Table
    AND name LIKE 'pp_%'
ORDER BY
    modify_date DESC;
/*
https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-objects-transact-sql?view=sql-server-ver17

F	Foreign Key Constraint	ข้อกำหนดคีย์นอก (ความสัมพันธ์ระหว่างตาราง)
FN	Scalar Function	ฟังก์ชันที่คืนค่ามาเป็นค่าเดียว
P	Stored Procedure	ชุดคำสั่ง SQL (SQL Stored Procedure)
PK	Primary Key Constraint	ข้อกำหนดคีย์หลัก
S	System Table	ตารางของระบบ (Internal System Table)
TF	Table-valued Function	ฟังก์ชันที่คืนค่ามาเป็นตาราง
TR	Trigger	ตัวดักจับเหตุการณ์ (DML Trigger)
U	User Table	ตารางที่ผู้ใช้สร้างขึ้น (ที่คุณเพิ่ง Query ไป)
V	View	วิวที่สร้างขึ้นเพื่อรวมข้อมูล
*/