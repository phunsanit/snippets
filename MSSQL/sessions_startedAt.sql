SELECT 
    name AS SessionName,
    create_time AS StartedAt
FROM sys.dm_xe_sessions 
WHERE name = 'system_health';