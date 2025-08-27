/*
kill all process
by SSChasing Mays
https://www.sqlservercentral.com/forums/topic/kill-all-processes-associated-with-a-hostname#post-1770570
*/

DECLARE @SqlCmd VARCHAR(1000)

	,@HostName VARCHAR(100)-- Set the hostname name from which to kill the connections

	--SET @HostName = 'Pitt_P'

SET @HostName = HOST_NAME()

SET @SqlCmd = ''  SELECT @Sqlcmd = @SqlCmd + CHAR(13) + CHAR(10) + 'KILL ' + convert(CHAR(10), spid) + ' '

FROM master.dbo.sysprocesses

WHERE hostname = @HostName

	AND DBID <> 0

	AND spid <> @@spid PRINT @sqlcmd EXEC(@Sqlcmd)

GO