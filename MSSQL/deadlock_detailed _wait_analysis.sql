SELECT
	w.session_id AS WaitingSessionID,
	w.blocking_session_id AS BlockingSessionID,
	w.wait_duration_ms / 1000 AS WaitDurationSeconds,
	w.wait_type AS WaitType,
	w.resource_description AS ResourceDescription,
	s.login_name AS BlockerLogin,
	s.host_name AS BlockerHost,
	s.program_name AS BlockerProgram
FROM sys.dm_os_waiting_tasks w
INNER JOIN sys.dm_exec_sessions s ON w.blocking_session_id = s.session_id
WHERE w.blocking_session_id IS NOT NULL;