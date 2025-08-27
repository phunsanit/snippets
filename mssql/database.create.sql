DECLARE @database_name AS VARCHAR(128) = 'prototypes'
DECLARE @collate_name AS VARCHAR(128) = 'Thai_CI_AS'
DECLARE @sql NVARCHAR(MAX) = ''

SET @sql = 'CREATE DATABASE ' + @database_name + ' ON PRIMARY (
	NAME = '' + @database_name + ''
	,FILENAME = 'C:\UsersDatabases\mssql\' + @database_name + '.mdf'
	) LOG ON (
	NAME = '' + @database_name + '_log'
	,FILENAME = 'C:\UsersDatabases\mssql\' + @database_name + '.log'
	)

SET @sql = 'ALTER DATABASE ' + @database_name + ' COLLATE ' + @collate_name + ';'

-- change owner to sa
SET @sql = 'ALTER AUTHORIZATION ON DATABASE::[' + @database_name + '] TO [sa]; GO'


-- set recovery model to simple
SET @sql = 'ALTER DATABASE [' + @database_name + ']

SET RECOVERY SIMPLE; GO'


-- change compatibility level
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET COMPATIBILITY_LEVEL = 130; GO'
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET ANSI_NULL_DEFAULT OFF; GO'
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET ANSI_NULLS OFF; GO'
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET ANSI_PADDING OFF; GO'
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET ANSI_WARNINGS OFF; GO'
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET ARITHABORT OFF; GO'
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET AUTO_CLOSE OFF; GO'
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET AUTO_SHRINK OFF; GO'
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET AUTO_CREATE_STATISTICS ON (INCREMENTAL = OFF); GO'
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET AUTO_UPDATE_STATISTICS ON; GO'
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET CURSOR_CLOSE_ON_COMMIT OFF; GO'
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET CURSOR_DEFAULT GLOBAL; GO'
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET CONCAT_NULL_YIELDS_NULL OFF; GO'
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET NUMERIC_ROUNDABORT OFF; GO'
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET QUOTED_IDENTIFIER OFF; GO'
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET RECURSIVE_TRIGGERS OFF; GO'
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET DISABLE_BROKER; GO'
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET AUTO_UPDATE_STATISTICS_ASYNC OFF; GO'
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET DATE_CORRELATION_OPTIMIZATION OFF; GO'
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET PARAMETERIZATION SIMPLE; GO'
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET READ_COMMITTED_SNAPSHOT OFF; GO'
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET READ_WRITE; GO'
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET RECOVERY FULL; GO'
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET MULTI_USER; GO'
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET PAGE_VERIFY CHECKSUM; GO'
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET TARGET_RECOVERY_TIME = 60 SECONDS; GO'
SET @sql = 'ALTER DATABASE [' + @database_name + ']
SET @sql = 'SET DELAYED_DURABILITY = DISABLED; GO'


SET @sql = 'USE [' + @database_name + ']; GO'


SET @sql = 'ALTER DATABASE SCOPED CONFIGURATION

SET @sql = 'SET LEGACY_CARDINALITY_ESTIMATION = OFF; GO'


SET @sql = 'ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY
SET @sql = 'SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY; GO'
SET @sql = 'ALTER DATABASE SCOPED CONFIGURATION'
SET @sql = 'SET MAXDOP = 0; GO'
SET @sql = 'ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY'
SET @sql = 'SET MAXDOP = PRIMARY; GO'
SET @sql = 'ALTER DATABASE SCOPED CONFIGURATIONGO'
SET @sql = 'SET PARAMETER_SNIFFING = ON; GO''
SET @sql = 'ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY'
SET @sql = 'SET PARAMETER_SNIFFING = PRIMARY; GO'
SET @sql = 'ALTER DATABASE SCOPED CONFIGURATION'
SET @sql = 'SET QUERY_OPTIMIZER_HOTFIXES = OFF; GO'
SET @sql = 'ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY'
SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY; GO'

EXEC sp_executesql @sql;