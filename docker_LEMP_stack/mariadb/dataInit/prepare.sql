/*
SET GLOBAL character_set_client = 'utf8';
SET GLOBAL character_set_connection = 'utf8';
SET GLOBAL character_set_database = 'utf8';
SET GLOBAL character_set_filesystem = 'utf8';
SET GLOBAL character_set_results = 'utf8';
SET GLOBAL character_set_server = 'utf8';

USE mysql;
CREATE TABLE general_log(
event_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
user_host mediumtext NOT NULL,
thread_id int(11) NOT NULL,
server_id int(10) unsigned NOT NULL,
command_type varchar(64) NOT NULL,
argument mediumtext NOT NULL
) ENGINE=CSV DEFAULT CHARSET=utf8 COMMENT='General log';

# Set Error Log

# Set General Query Log
SET GLOBAL general_log_file = 'general.log';
SET GLOBAL log_output = 'FILE';
SET GLOBAL general_log = on;

# Set Slow Query Log
SET GLOBAL long_query_time = 1
SET GLOBAL slow_query_log = 1
SET GLOBAL slow_query_log_file = /usr/log/slowquery.log
SET GLOBAL log_queries_not_using_indexes = 1
*/

CREATE DATABASE `lemp`
  DEFAULT CHARACTER SET utf8
  DEFAULT COLLATE utf8_general_ci;

USE `lemp`;

CREATE TABLE `agtAgentTypes` (
  `agentTypeID` int(11) NOT NULL,
  `agentType` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`agentTypeID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 DEFAULT COLLATE utf8_unicode_ci;
