-- --------------------------------------------------------
-- การตั้งค่าตัวแปร: แก้ไข 'wp_posts' ให้เป็นชื่อตารางที่คุณต้องการ
-- --------------------------------------------------------
SET @table_name = 'wp_posts';
SET @next_auto_increment = 0;
SET @s_sql = ''; -- ตัวแปรสำหรับเก็บ Dynamic SQL

-- --------------------------------------------------------
-- Step 1: คำนวณค่า AUTO_INCREMENT ถัดไป
-- --------------------------------------------------------
-- คำนวณค่า MAX(ID) + 1 และเก็บไว้ในตัวแปร @next_auto_increment
SET @s_sql = CONCAT('SELECT COALESCE(MAX(ID), 0) + 1 INTO @next_auto_increment FROM `', @table_name, '`;');
PREPARE stmt1 FROM @s_sql;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

-- แสดงค่าที่คำนวณได้
SELECT @next_auto_increment AS next_auto_increment_value;

-- --------------------------------------------------------
-- Step 2: ปิดการใช้งานการจัดลำดับ AUTO_INCREMENT ใหม่ (NO_AUTO_VALUE_ON_ZERO)
-- --------------------------------------------------------
-- เพื่อให้มั่นใจว่าค่า ID ที่มีการเปลี่ยนแปลงจะถูกยอมรับแม้จะเป็น 0
SET SESSION sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

-- --------------------------------------------------------
-- Step 3: เปลี่ยนประเภทคอลัมน์ ID
-- --------------------------------------------------------
-- เปลี่ยนเป็น BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT
SET @s_sql = CONCAT('ALTER TABLE `', @table_name, '` CHANGE `ID` `ID` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT;');
PREPARE stmt3 FROM @s_sql;
EXECUTE stmt3;
DEALLOCATE PREPARE stmt3;

-- --------------------------------------------------------
-- Step 4: กำหนดค่า AUTO_INCREMENT Counter ใหม่
-- --------------------------------------------------------
-- ตั้งค่าเริ่มต้นของ AUTO_INCREMENT โดยใช้ค่าที่คำนวณได้จาก Step 1
SET @s_sql = CONCAT('ALTER TABLE `', @table_name, '` AUTO_INCREMENT = ', @next_auto_increment, ';');
PREPARE stmt4 FROM @s_sql;
EXECUTE stmt4;
DEALLOCATE PREPARE stmt4;

-- --------------------------------------------------------
-- การยืนยันผลลัพธ์
-- --------------------------------------------------------
SELECT CONCAT('สำเร็จ: อัปเดตตาราง ', @table_name, ' และตั้งค่า AUTO_INCREMENT เป็น ', @next_auto_increment) AS Status;