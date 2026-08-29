-- =============================================================================
-- MariaDB/MySQL Setup Script (Simplified for GUI Clients)
-- =============================================================================

-- 1. CONFIGURATION
SET @MODE = 'BOTH';
SET @DB_NAME = 'prototypes-laravel-Spatie';
SET @DB_USER = 'QQbPM5nzBuXQ';
SET @DB_PASS = 'ggzhUNbNTkcX';

-- -----------------------------------------------------------------------------
-- 2. Create Database
-- -----------------------------------------------------------------------------
SELECT CONCAT('CREATE DATABASE IF NOT EXISTS `', @DB_NAME, '` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci') INTO @sql;
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- -----------------------------------------------------------------------------
-- 3. Create Users & Grants
-- -----------------------------------------------------------------------------

-- Create for LOCALHOST (Socket)
SET @sql_u = IF(@MODE IN ('BOTH', 'SOCKET'), 
    CONCAT('CREATE USER IF NOT EXISTS \'', @DB_USER, '\'@\'localhost\' IDENTIFIED BY \'', @DB_PASS, '\''), 
    'DO 0');
PREPARE stmt FROM @sql_u; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql_g = IF(@MODE IN ('BOTH', 'SOCKET'), 
    CONCAT('GRANT ALL PRIVILEGES ON `', @DB_NAME, '`.* TO \'', @DB_USER, '\'@\'localhost\''), 
    'DO 0');
PREPARE stmt FROM @sql_g; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Create for REMOTE/NETWORK (%)
SET @sql_u = IF(@MODE IN ('BOTH', 'TCP'), 
    CONCAT('CREATE USER IF NOT EXISTS \'', @DB_USER, '\'@\'%\' IDENTIFIED BY \'', @DB_PASS, '\''), 
    'DO 0');
PREPARE stmt FROM @sql_u; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql_g = IF(@MODE IN ('BOTH', 'TCP'), 
    CONCAT('GRANT ALL PRIVILEGES ON `', @DB_NAME, '`.* TO \'', @DB_USER, '\'@\'%\''), 
    'DO 0');
PREPARE stmt FROM @sql_g; EXECUTE stmt; DEALLOCATE PREPARE stmt;

FLUSH PRIVILEGES;

-- -----------------------------------------------------------------------------
-- 4. Verification
-- -----------------------------------------------------------------------------
SELECT @MODE AS 'Mode', @DB_NAME AS 'DB', @DB_USER AS 'User';
SELECT User, Host FROM mysql.user WHERE User = @DB_USER;
