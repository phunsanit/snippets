--
-- https://9548a1c567facd1d4e460301c18c5b9ab12ab1c2ccde585a.plusmagi.com/index.php?route=/sql&pos=6937&db=WordPress700&table=wp700_terms&sql_query=SELECT+*+FROM+`wp700_terms`+%0AORDER+BY+`wp700_terms`.`term_id`+ASC+&sql_signature=df483cf3ab162cd80d271bb149dbcb8e156d2325d016058ee3e37edf65ef0f07&session_max_rows=25&is_browse_distinct=0
-- 219

-- =====================================================================
-- 1. สร้าง Temporary Table สำหรับพักคำศัพท์ใหม่จาก JSON เท่านั้น
-- =====================================================================
CREATE TEMPORARY TABLE temp_next_tags (

id INT AUTO_INCREMENT PRIMARY KEY,

tag_name VARCHAR(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;

-- =====================================================================
-- 2. ดึงเฉพาะ Tag ที่ยังไม่มีในระบบเข้ามาพักไว้ (กรองตัวซ้ำออกปกติ)
-- =====================================================================
INSERT INTO temp_next_tags (tag_name)
SELECT DISTINCT TRIM(j.tag)
FROM JSON_TABLE(

'["Automatically","mounts","remote","SMB","share","downloads","directories","folder","local","destination","using","rsync","deep","auditing","","ีีupdate","","CONFIGURATION","","","","paths","","SMB","server","","array","","Mac","","contains","backslashes","\","","spaces","","SINGLE","QUOTES","","windows","share","folder","","","ไฟล์","โพลเดอร์","ซับโพลเดอร์","","ดาน์โหลดม","","ข้าม","path","windows","","smb://","MacOs","Downloadsฃ","","windows","share","folder","","Automatically","mounts","","remote","SMB","share","","downloads","","","","","","","","","","","directories","folder","local","destination","using","rsync","","deep","auditing","","","array","array","","auditing","auditing","auditing","auditing","Automatically","Automatically","Automatically","Automatically","backslashes","backslashes","backslashes","Bash","below","can","chmod","CONFIGURATION","CONFIGURATION","CONFIGURATION","contains","contains","contains","copy-paste","deep","deep","deep","deep","desired","destination","destination","destination","destination","details.","directories","directories","directories","directories","download_smb.sh","downloads","downloads","downloads","downloads","Downloads","Downloads","Downloads","Downloadsฃ","Downloadsฃ","either","enclose","executable:","folder","folder","folder","folder","folder","folder","folder","folder","folder","folder","folder","folder","folder","from","If","IMPORTANT:","in","In","it","local","local","local","local","Mac","Mac","Mac","MacOs","MacOs","MacOs","MacOs:","Make","misinterpreting","mounts","mounts","mounts","mounts","MUST","or","or","path","path","path","path","paths","paths","paths","paths.","prevent","QUOTES","QUOTES","QUOTES","remote","remote","remote","remote","rsync","rsync","rsync","rsync","Run","script","script","script:","section","server","server","server","share","share","share","share","share","share","share","share","share","share","share","SINGLE","SINGLE","SINGLE","SMB","SMB","SMB","SMB","SMB","SMB","SMB","smb://","smb://","smb://","smb://","spaces","spaces","spaces,","the","the","the","the","them.","to","Update","using","using","using","using","windows","windows","windows","windows","windows","windows","windows","windows","windows","windows","Windows","with","you","you","your","กันในทีเดียว","ข้าม","ข้าม","จะข้ามไปให้เอง","จาก","จาก","ซับโพลเดอร์","ซับโพลเดอร์","ดาน์โหลดม","ดาน์โหลดม","โดยจะข้ามไฟล์ที่ดาน์โหลดมาแล้ว","ที่ช่วยในการ","ปกติ","เป็น","โพลเดอร์","โพลเดอร์","ไฟล์","ไฟล์","ไฟล์ในโพลเดอร์และซับโพลเดอร์พร้อม","และรองรับทั้ง","หรือ","หลาย","ีupdate","ีีupdate","update"]', -- เปลี่ยนชุดคำศัพท์ใหม่ของพี่ตรงนี้ได้เลย

'$[*]' COLUMNS(tag VARCHAR(200) PATH '$')
) AS j
WHERE NOT EXISTS (

SELECT 1 FROM wp_terms t

WHERE TRIM(t.name) COLLATE utf8mb4_unicode_520_ci = TRIM(j.tag) COLLATE utf8mb4_unicode_520_ci
);

-- =====================================================================
-- 3. Procedure ถมรูรั่วแบบ Real-time (เขียนลงตารางทันทีในลูปเพื่อไม่ให้เลขกระโดด)
-- =====================================================================
DROP PROCEDURE IF EXISTS RealtimeFillGaps;
DELIMITER $$

CREATE PROCEDURE RealtimeFillGaps()
BEGIN

DECLARE done INT DEFAULT FALSE;

DECLARE current_tag_name VARCHAR(200);

DECLARE current_gap_id INT;


-- ดึงรายชื่อคำศัพท์ใหม่มารันทีละคำ

DECLARE cur CURSOR FOR SELECT tag_name FROM temp_next_tags;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;


OPEN cur;

read_loop: LOOP


FETCH cur INTO current_tag_name;


IF done THEN



LEAVE read_loop;


END IF;



-- 1. ค้นหา ID รูรั่วที่ต่ำที่สุดและว่างอยู่จริง ๆ ณ วินาทีนั้น


SELECT MIN(gap.available_id) INTO current_gap_id


FROM (



SELECT (t1.term_id + 1) AS available_id



FROM wp_terms t1



LEFT JOIN wp_terms t2 ON t1.term_id + 1 = t2.term_id



WHERE t2.term_id IS NULL




UNION




SELECT 1 AS available_id



WHERE NOT EXISTS (SELECT 1 FROM wp_terms WHERE term_id = 1)


) AS gap;



-- 2. บังคับ INSERT ลงตารางหลักทันที! (ทำให้ลูปถัดไปรู้ว่าไอดีนี้ไม่ว่างแล้ว)


INSERT INTO wp_terms (term_id, name, slug, term_group)


VALUES (



current_gap_id,



current_tag_name,



LOWER(REGEXP_REPLACE(REPLACE(current_tag_name, ' ', '-'), '[^a-zA-Z0-9\\x{0E00}-\\x{0E7F}-]', '')),



0


);



-- 3. ผูกข้อมูลเข้าตาราง Taxonomy ทันทีคู่กัน


INSERT INTO wp_term_taxonomy (term_id, taxonomy, description, parent, count)


VALUES (current_gap_id, 'post_tag', '', 0, 0);


END LOOP;

CLOSE cur;
END$$
DELIMITER ;

-- เรียกใช้งานเพื่อเริ่มการถมรูรั่วที่ถูกต้อง
CALL RealtimeFillGaps();
DROP PROCEDURE IF EXISTS RealtimeFillGaps;

-- =====================================================================
-- 4. รีเซ็ต AUTO_INCREMENT ของระบบให้ไปรอที่จุดสูงสุดหลังจบงาน
-- =====================================================================
SET @max_id := (SELECT MAX(term_id) FROM wp_terms);
SET @sql_cmd := CONCAT('ALTER TABLE wp_terms AUTO_INCREMENT = ', @max_id + 1);
PREPARE stmt FROM @sql_cmd;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ลบตารางชั่วคราว
DROP TEMPORARY TABLE temp_next_tags;