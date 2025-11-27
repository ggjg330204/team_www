#! /bin/bash
setenforce 0
grubby --update-kernel ALL --args selinux=0

# SSH 설치 및 서비스 시작
sudo dnf install -y openssh-server
sudo systemctl enable sshd
sudo systemctl start sshd

# 방화벽 허용
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload

# DB 설치
sudo dnf install -y mysql-server
sudo systemctl enable --now mysqld
mysql -uroot -e "CREATE USER 'www'@'%' IDENTIFIED BY 'It12345!'; GRANT ALL PRIVILEGES ON *.* TO 'www'@'%'; CREATE DATABASE wordpress;"



# Firewall
sudo firewall-cmd --zone=public --add-port=22/tcp --permanent
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
sudo firewall-cmd --reload
