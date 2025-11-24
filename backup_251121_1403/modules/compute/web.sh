#! /bin/bash
setenforce 0
grubby --update-kernel ALL --args selinux=0
dnf install -y wget httpd php php-gd php-opcache php-mysqlnd
wget https://ko.wordpress.org/wordpress-6.8.3-ko_KR.tar.gz
tar xvfz wordpress-6.8.3-ko_KR.tar.gz
cp -ar wordpress/* /var/www/html
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php/g' /etc/httpd/conf/httpd.conf
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sed -i 's/database_name_here/wordpress/g' /var/www/html/wp-config.php
sed -i 's/username_here/hyb/g' /var/www/html/wp-config.php
sed -i 's/password_here/It12345!/g' /var/www/html/wp-config.php
sed -i 's/localhost/10.0.5.4/g' /var/www/html/wp-config.php
echo $HOSTNAME > /var/www/html/health.html
systemctl enable --now httpd