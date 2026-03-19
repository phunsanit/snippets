SELECT
	r.session_id AS SessionID,
	r.blocking_session_id AS BlockingSessionID,
	r.start_time AS StartTime,
	r.total_elapsed_time / 1000 AS WaitTimeSeconds,
	r.wait_type AS WaitType,
	r.wait_resource AS WaitResource,
	st.text AS SQLText,
	s.login_name AS LoginName,
	s.host_name AS HostName,
	s.program_name AS ProgramName
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) st
WHERE r.blocking_session_id <> 0;