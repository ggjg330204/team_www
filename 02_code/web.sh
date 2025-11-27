#! /bin/bash
setenforce 0
grubby --update-kernel ALL --args selinux=0

dnf install -y wget httpd php php-gd php-opcache php-mysqlnd php-pecl-redis5
wget https://ko.wordpress.org/wordpress-6.8.3-ko_KR.tar.gz
tar xvfz wordpress-6.8.3-ko_KR.tar.gz
cp -ar wordpress/* /var/www/html
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php/g' /etc/httpd/conf/httpd.conf
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sed -i 's/database_name_here/wordpress/g' /var/www/html/wp-config.php
sed -i 's/username_here/www/g' /var/www/html/wp-config.php
sed -i 's/password_here/It12345!/g' /var/www/html/wp-config.php
sed -i "s/localhost/${db_host}/g" /var/www/html/wp-config.php
wget https://downloads.wordpress.org/plugin/redis-cache.latest-stable.zip
unzip -q redis-cache.latest-stable.zip -d /var/www/html/wp-content/plugins/
rm redis-cache.latest-stable.zip

cat <<'REDIS_CONFIG' >> /var/www/html/wp-config.php

// Redis Configuration
define('WP_REDIS_HOST', getenv('REDIS_HOST'));
define('WP_REDIS_PORT', getenv('REDIS_PORT'));
define('WP_REDIS_PASSWORD', getenv('REDIS_PASSWORD'));
define('WP_REDIS_DATABASE', 0);
define('WP_CACHE', true);
define('WP_REDIS_TIMEOUT', 1);
define('WP_REDIS_READ_TIMEOUT', 1);
REDIS_CONFIG

echo $HOSTNAME > /var/www/html/health.html
systemctl enable --now httpd