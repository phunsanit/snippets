
SET GLOBAL character_set_client = 'utf8';
SET GLOBAL character_set_connection = 'utf8';
SET GLOBAL character_set_database = 'utf8';
SET GLOBAL character_set_filesystem = 'utf8';
SET GLOBAL character_set_results = 'utf8';
SET GLOBAL character_set_server = 'utf8';

SET GLOBAL general_log_file = '/var/log/general-Dump.log'; 
SET GLOBAL log_output = 'file';
SET GLOBAL general_log = on;

ALTER DATABASE `lemp`
  DEFAULT CHARACTER SET utf8
  DEFAULT COLLATE utf8_general_ci;

USE `lemp`;

CREATE TABLE `agtAgentTypes` (
  `agentTypeID` int(11) NOT NULL,
  `agentType` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`agentTypeID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 DEFAULT COLLATE utf8_unicode_ci;