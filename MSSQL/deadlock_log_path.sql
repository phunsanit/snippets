SELECT
	t.target_name AS TargetName,
	CAST(t.target_data AS XML).value('(/EventFileTarget/File/@name)[1]', 'varchar(max)') AS FilePath
FROM sys.dm_xe_sessions s
JOIN sys.dm_xe_session_targets t ON s.address = t.event_session_address
WHERE s.name = 'system_health'
  AND t.target_name = 'event_file';