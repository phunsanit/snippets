SELECT
	tl.request_session_id AS SPID,
	tl.resource_type AS LockLevel,
	CASE
		WHEN tl.resource_type = 'OBJECT' THEN 'TABLE/VIEW'
		WHEN tl.resource_type IN ('PAGE', 'KEY', 'RID', 'HOBT') THEN 'DATA/INDEX'
		ELSE tl.resource_type
	END AS ResourceCategory,
	CASE
		WHEN tl.resource_type = 'OBJECT'
			THEN OBJECT_NAME(tl.resource_associated_entity_id, tl.resource_database_id)
		ELSE OBJECT_NAME(p.object_id, tl.resource_database_id)
	END AS ObjectName,
	i.name AS IndexName,
	tl.request_mode AS LockMode,
	-- ส่วนที่เพิ่ม: ชื่อเต็มของ Lock Mode --
	CASE tl.request_mode
		WHEN 'IS'  THEN 'Intent Shared (จองอ่านระดับล่าง)'
		WHEN 'IU'  THEN 'Intent Update'
		WHEN 'IX'  THEN 'Intent Exclusive (จองแก้ระดับล่าง)'
		WHEN 'S'   THEN 'Shared (อ่าน)'
		WHEN 'Sch-M' THEN 'Schema Modification (แก้ไขโครงสร้าง)'
		WHEN 'Sch-S' THEN 'Schema Stability (คงโครงสร้าง)'
		WHEN 'SIU' THEN 'Shared Intent Update'
		WHEN 'SIX' THEN 'Shared Intent Exclusive'
		WHEN 'U'   THEN 'Update (เตรียมแก้ไข)'
		WHEN 'X'   THEN 'Exclusive (เขียน/แก้ไข)'
		ELSE tl.request_mode
	END AS LockModeFullName,
	tl.request_status AS Status,
	st.text AS LastSQLQuery
FROM sys.dm_tran_locks tl
LEFT JOIN sys.partitions p ON tl.resource_associated_entity_id = p.hobt_id
LEFT JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
LEFT JOIN sys.dm_exec_sessions es ON tl.request_session_id = es.session_id
LEFT JOIN sys.dm_exec_connections ec ON tl.request_session_id = ec.session_id
OUTER APPLY sys.dm_exec_sql_text(ec.most_recent_sql_handle) st
WHERE tl.resource_database_id = DB_ID()
	AND tl.resource_type <> 'DATABASE'
ORDER BY tl.request_session_id;