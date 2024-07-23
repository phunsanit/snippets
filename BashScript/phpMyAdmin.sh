ถ้าจะใช้ nginx ก็ทำใน nginx ง่ายกว่า

https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-with-nginx-on-an-ubuntu-20-04-server


apt-get purge phpmyadmin

------------------------

https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-on-ubuntu-20-04

sudo apt update

sudo apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl

options

sudo apt-get -y install php-bacon-qr-code
sudo apt-get -y install php-code-lts-u2f-php-server
sudo apt-get -y install php-gd
sudo apt-get -y install php-recode

sudo apt install phpmyadmin php8.2-{cgi,cli,common,curl,fpm,gd,imagick,intl,mbstring,mysql,opcache,soap,xml,xmlrpc,zip}

sudo phpenmod mbstring

root
;t9)G]5b\GEj1rlU<c}|h6@h3L20MaH43I*Kv?2X\;v0\V(7Yt/U-+_&;U$NIt_wxso,9'|@8X,0PG}rR5<&JDp"ry{YQ*!vjjwas





sudo systemctl restart apache2

sudo nano /etc/apache2/conf-available/phpmyadmin.conf

<Directory /usr/share/phpmyadmin>
    Options SymLinksIfOwnerMatch
    DirectoryIndex index.php
    AllowOverride All

sudo systemctl restart apache2

sudo systemctl restart apache2


sudo ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf
sudo a2enconf phpmyadmin.conf

ถ้าไม่มี ใช้




sudo ln -s /etc/phpmyadmin/apache.conf /etc/apache2/sites-available/phpmyadmin.conf
sudo a2enconf phpmyadmin.conf

sudo a2enconf phpmyadmin.conf