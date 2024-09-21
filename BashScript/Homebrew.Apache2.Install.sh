#!/bin/bash

cd ~

# Install httpd using Homebrew
brew install httpd

# dispaly apache info
brew info httpd

# Create the shared directory
sudo mkdir -p /home/linuxbrew/.linuxbrew/etc/httpd/sites-available

# Create the document root
sudo mkdir -p /Users/Shared/www

# Set permissions for the document root
sudo chmod 775 /Users/Shared/www

# Set DocumentRoot in httpd.conf
#sudo sed -i '' 's/^DocumentRoot.*$/DocumentRoot "/Users/Shared/www/"'/' /usr/local/etc/httpd/httpd.conf

# Set new config in end of httpd.conf
sudo sed -i '$a\
\
#add by Homebrew.Apache2.Install.sh\
\
# Include generic snippets of statements\
IncludeOptional conf-enabled/*.conf\
\
# Include the virtual host configurations:\
IncludeOptional sites-enabled/*.conf\
\
ServerName 127.0.0.1\
\
#end add by Homebrew.Apache2.Install.sh' /home/linuxbrew/.linuxbrew/etc/httpd/httpd.conf

# Start Apache
brew services start httpd