#!/bin/bash

cd ~

# Define default values
default_domain="plusmagi.com"
default_email="phunsanit@gmail.com"
default_docroot="/Users/Shared/www"

# Get user input with default values
read -p "Enter domain name (e.g., $default_domain): " domain
read -p "Enter admin email address (default: $default_email): " email
read -p "Enter DocumentRoot (absolute path, default: $default_docroot): " docroot

# Use parameter expansion for default values
domain=${domain:-$default_domain}
email=${email:-$default_email}
docroot=${docroot:-$default_docroot}

# Validate user input (optional)
if [[ -z "$domain" || -z "$email" || -z "$docroot" ]]; then
  echo "Error: Please provide all required information."
  exit 1
fi

# Create virtual host configuration file
virtual_host_file="/home/linuxbrew/.linuxbrew/etc/httpd/sites-available/$domain.conf"
DocumentRoot="$docroot/$domain/published"

# Create virtual host directory (if it doesn't exist)
sudo mkdir -p "$docroot/$domain/published"

# Set permissions for the shared directory
cd "$docroot/$domain/published"
sudo chown -R www-data:www-data *;
sudo find . -type d -exec chmod 755 {} \;
sudo find . -type f -exec chmod 644 {} \;

sudo cat << EOF > "$virtual_host_file"
<VirtualHost *:443>
    <Directory "$DocumentRoot">
        #Access control in Apache 2.4:
        Require all granted

        AllowOverride All
        Options Indexes FollowSymLinks
    </Directory>
    DefaultLanguage th_TH
    DocumentRoot $DocumentRoot
    #log
    CustomLog ${APACHE_LOG_DIR}/$domain.access.log "combined"
    ErrorLog ${APACHE_LOG_DIR}/$domain.error.log
    #server
    ServerAdmin $email
    ServerAlias www.$domain
    ServerName $domain
</VirtualHost>
<VirtualHost *:80>
    <Directory "$DocumentRoot">
        #Access control in Apache 2.4:
        Require all granted

        AllowOverride All
        Options Indexes FollowSymLinks
    </Directory>
    DefaultLanguage th_TH
    DocumentRoot $DocumentRoot
    #log
    CustomLog ${APACHE_LOG_DIR}/$domain.access.log "combined"
    ErrorLog ${APACHE_LOG_DIR}/$domain.error.log
    #server
    ServerAdmin $email
    ServerAlias www.$domain
    ServerName $domain
</VirtualHost>
EOF

# Enable the virtual host (assuming Apache2 for Ubuntu/Debian)
#sudo a2ensite "$domain.conf"

# Restart Apache
brew services start httpd

echo "Virtual host created for $domain! Remember to point your DNS and create content in $docroot/published"