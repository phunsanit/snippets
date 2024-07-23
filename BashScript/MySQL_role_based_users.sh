#!/bin/bash



# Define the roles
ADMINISTRATORS_ROLE="administrators"
USERS_ROLE="users"
GUESTS_ROLE="guests"

# Function to generate a random password
generate_user_password() {
    # Generate random administrator user and password
    USER=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 8 | head -n 1)
    PASSWORD=$(tr -dc 'a-zA-Z0-9!@#$%^&*()_+\-=[]{}|;:,.<>?' < /dev/urandom | fold -w 20 | head -n 1)
}



# Specific database name
DATABASE_NAME="your_database_name_here"


# Create the administrator user and grant the admin role
#mysql -u $MYSQL_ROOT_USER -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER '$ADMIN_USER'@'%' IDENTIFIED BY '$ADMIN_PASSWORD'; GRANT $ADMINISTRATORS_ROLE TO '$ADMIN_USER'@'%'; GRANT ALL #PRIVILEGES ON *.* TO '$ADMIN_USER'@'%' WITH GRANT OPTION;"

# Create the user and grant the user role
#mysql -u $MYSQL_ROOT_USER -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER '$USER_USER'@'%' IDENTIFIED BY '$USER_PASSWORD'; GRANT $USERS_ROLE TO '$USER_USER'@'%'; GRANT ALL PRIVILEGES ON #$DATABASE_NAME.* TO '$USER_USER'@'%';"

# Create the guest user and grant the guest role
#mysql -u $MYSQL_ROOT_USER -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER '$GUEST_USER'@'%' IDENTIFIED BY '$GUEST_PASSWORD'; GRANT $GUESTS_ROLE TO '$GUEST_USER'@'%'; GRANT SELECT ON #$DATABASE_NAME.* TO '$GUEST_USER'@'%';"

# Create the guest user and grant the guest role
mysql -u $MYSQL_ROOT_USER -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER '$GUEST_USER'@'%' IDENTIFIED BY '$PASSWORD'; GRANT $GUESTS_ROLE TO '$USER'@'%'; GRANT SELECT ON $DATABASE_NAME.* TO '$GUEST_USER'@'%';"

echo "User: $USER_USER"
echo "User password: $USER_PASSWORD"