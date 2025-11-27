#! /bin/bash
setenforce 0
grubby --update-kernel ALL --args selinux=0

# 패키지 설치
dnf install -y wget httpd php php-gd php-opcache php-mysqlnd php-pecl-redis5 lynx mysql unzip

# 워드프레스 설치 및 설정
wget https://ko.wordpress.org/wordpress-6.8.3-ko_KR.tar.gz
tar xvfz wordpress-6.8.3-ko_KR.tar.gz
cp -ar wordpress/* /var/www/html
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php/g' /etc/httpd/conf/httpd.conf
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
# ... (DB 설정 및 Redis 설정 코드 생략) ...

# ----------------------------------------------------
# 🔑 [수정 1] 필수: 웹 서비스 시작 전에 권한 설정 (주석 해제 및 순서 변경)
# ----------------------------------------------------
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# health.html 파일 생성 및 권한 설정
echo $HOSTNAME > /var/www/html/health.html
# health.html 파일이 Apache가 접근 가능하도록 명확히 권한 설정
chown apache:apache /var/www/html/health.html 

# ----------------------------------------------------
# 🔑 [수정 2] 서비스 시작 (권한 설정 이후)
# ----------------------------------------------------
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-service=ssh

# [수정 전]
firewall-cmd --permanent --zone=trusted --add-source=10.0.0.0/24

# [수정 후] Application Gateway가 있는 192.168.0.0/24 대역 허용
firewall-cmd --permanent --zone=trusted --add-source=192.168.0.0/24
systemctl enable --now httpd

# ----------------------------------------------------
# ❌ [삭제] 치명적인 문제: index.html 생성 블록 전체 삭제
# ----------------------------------------------------
# 기존 스크립트의 마지막 부분에 있던
# cat <<EOF > /var/www/html/index.html ... EOF 블록은
# 워드프레스 작동을 방해하므로 완전히 제거해야 합니다.