#!/bin/bash

# --- Set Variables ---
# (ลบ DB_USER ออกแล้ว เพราะจะใช้จาก ~/.my.cnf อัตโนมัติ)

# DateTime for the directory name
DateTime=$(date +"%Y-%m-%d_%H-%M-%S")

# Directory to store backup files
BACKUP_DIR="/backups/mysql/$DateTime"

# --- Check and Create Backup Directory ---
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    echo "Creating directory: $BACKUP_DIR"
fi

# --- Start Database Backup Process ---
echo "--- Starting Database Backup ---"

# Get a list of all non-system databases
# (ลบ -u$DB_USER ออก)
DATABASES=$(mysql -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql|sys)")

# Loop through each database and back it up
for DB in $DATABASES; do
    echo "  > Backing up database: $DB"
    # (ลบ --user=$DB_USER ออก)
    mysqldump \
        --single-transaction \
        --events \
        --routines \
        --triggers \
        --add-drop-database "$DB" | gzip > "$BACKUP_DIR/$DB.sql.gz"

    if [ $? -eq 0 ]; then
        echo "    - Success: $BACKUP_DIR/$DB.sql.gz"
    else
        echo "    - Error backing up database: $DB"
    fi
done

echo "--- Database Backup Complete ---"

# --- Backup Users and Permissions ---

echo "--- Starting User and Permissions Backup ---"

# Backup user accounts and their associated permissions from the `mysql` system database
echo "  > Backing up user accounts, tables, and permissions..."
# (ลบ -u$DB_USER ออก)
mysqldump --single-transaction --skip-triggers --compact mysql user db tables_priv columns_priv procs_priv > "$BACKUP_DIR/users_and_grants.sql"
if [ $? -eq 0 ]; then
    echo "    - Success: $BACKUP_DIR/users_and_grants.sql"
else
    echo "    - Error backing up user accounts and grants"
fi

# Backup the "SHOW GRANTS" statements
echo "  > Backing up SHOW GRANTS statements..."
# (ลบ -u$DB_USER ออกทั้งสองจุด)
mysql -NBe "SELECT DISTINCT CONCAT('SHOW GRANTS FOR ''', user, '''@''', host, ''';') FROM mysql.user" | mysql -N | sed 's/$/;/' > "$BACKUP_DIR/grants.sql"
if [ $? -eq 0 ]; then
    echo "    - Success: $BACKUP_DIR/grants.sql"
else
    echo "    - Error backing up grants"
fi

echo "--- User and Permissions Backup Complete ---"

# --- Delete Old Backup Files ---

echo "--- Deleting backup directories older than 90 days ---"
# (คำสั่งนี้อันตราย ให้เช็ค path ดีๆ ก่อนรัน แต่ syntax ถูกต้องครับ)
find /backups/mysql/ -maxdepth 1 -type d -name "????????*" -mtime +90 -exec rm -rf {} \;

echo "--- All backup processes finished successfully ---"
