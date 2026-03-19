SELECT 
    CAST(event_data AS XML).value('(/event/@timestamp)[1]', 'datetime2') AS EventTimeUTC,
    CAST(event_data AS XML) AS DeadlockGraph
FROM sys.fn_xe_file_target_read_file(
    'D:\bin\SQLServer2022\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Log\system_health*.xel', 
    NULL, NULL, NULL)
WHERE object_name = 'xml_deadlock'
ORDER BY EventTimeUTC DESC;