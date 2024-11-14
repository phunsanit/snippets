#!/bin/bash

# Get the Homebrew prefix
brew_prefix=$(brew --prefix)

# Set the httpd.conf path
httpd_conf_path="${brew_prefix}/etc/httpd/httpd.conf"

mkdir -p "${brew_prefix}/etc/httpd/conf-enabled"

mkdir -p "${brew_prefix}/etc/httpd/sites-enabled"

# Check if httpd.conf exists
if [[ ! -f "$httpd_conf_path" ]]; then
    echo "httpd.conf not found at $httpd_conf_path"
    exit 1
fi

# Set the document root path
document_root="/Users/Shared/www"

# Create the document root
mkdir -p "$document_root"

# Create the group (if it doesn't exist)
sudo groupadd _www

# Check if _www user exists
if ! id -u _www &> /dev/null; then
    # Create the user and group
    sudo useradd -r -g _www _www
fi

sudo usermod -a -G _www $(whoami)

# Ensure the user has ownership of the document root
sudo chown -R _www:_www "$document_root"

# Set permissions for the document root
sudo chmod 775 "$document_root"

# Firewall
sudo ufw allow http
sudo ufw allow https

# Define configuration content as a variable
config_content=$(cat << EOF

# Include generic snippets of statements
IncludeOptional conf-enabled/*.conf

# Include the virtual host configurations
IncludeOptional sites-enabled/*.conf

#AH00558: Could not reliably determine the server's fully qualified domain name
ServerName 127.0.0.1

EOF
)

# Check if marker comment already exists
if ! grep -in "# add by Homebrew.Apache2.Install.sh" "$httpd_conf_path"; then
    # Marker comment not found, append the entire configuration block
    echo -e "\n# add by Homebrew.Apache2.Install.sh\n$config_content\n# end by Homebrew.Apache2.Install.sh" >> "$httpd_conf_path"
else
    # Marker comment found, update the existing block using a capture group
    sudo sed -i.bak "/# add by Homebrew.Apache2.Install.sh/,/# end by Homebrew.Apache2.Install.sh/{//!d;}" "$httpd_conf_path"
    sudo sed -i "/# add by Homebrew.Apache2.Install.sh/r /dev/stdin" "$httpd_conf_path" <<< "$config_content"
fi

# Set DocumentRoot in httpd.conf
sudo sed -i 's|/home/linuxbrew/.linuxbrew/var/www|/Users/Shared/www|g' httpd_conf_path

# restart Apache
brew services restart httpd