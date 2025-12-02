#! /bin/bash
# VMSS 인스턴스 설정 스크립트
# 웹 서버(Apache, PHP), WordPress, Redis 플러그인 설치 및 설정
setenforce 0
grubby --update-kernel ALL --args selinux=0

dnf install -y wget httpd php php-gd php-opcache php-mysqlnd php-pecl-redis5 lynx mysql unzip
wget https://ko.wordpress.org/wordpress-6.8.3-ko_KR.tar.gz
tar xvfz wordpress-6.8.3-ko_KR.tar.gz
cp -ar wordpress/* /var/www/html
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php/g' /etc/httpd/conf/httpd.conf
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sed -i 's/database_name_here/${db_name}/g' /var/www/html/wp-config.php
sed -i 's/username_here/${db_user}/g' /var/www/html/wp-config.php
sed -i 's/password_here/${db_password}/g' /var/www/html/wp-config.php
sed -i 's/localhost/${db_host}/g' /var/www/html/wp-config.php
wget https://downloads.wordpress.org/plugin/redis-cache.latest-stable.zip
unzip -q redis-cache.latest-stable.zip -d /var/www/html/wp-content/plugins/
rm redis-cache.latest-stable.zip

cat <<'REDIS_CONFIG' >> /var/www/html/wp-config.php

// Redis Configuration
define('WP_REDIS_HOST', '${redis_host}');
define('WP_REDIS_PORT', ${redis_port});
define('WP_REDIS_PASSWORD', '${redis_key}');
define('WP_REDIS_DATABASE', 0);
define('WP_CACHE', true);
define('WP_REDIS_TIMEOUT', 1);
define('WP_REDIS_READ_TIMEOUT', 1);
REDIS_CONFIG

echo $HOSTNAME > /var/www/html/health.html
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-service=ssh
firewall-cmd --reload
systemctl enable --now httpd