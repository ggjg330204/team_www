#! /bin/bash
# DB 서버 설정 스크립트 (VM용)
# MySQL 서버 설치 및 초기 데이터베이스/사용자 생성
setenforce 0
grubby --update-kernel ALL --args selinux=0
dnf install -y mysql-server
systemctl enable --now mysqld
mysql -uroot -e "CREATE USER 'www'@'%' IDENTIFIED BY 'It12345!'; GRANT ALL PRIVILEGES ON *.* TO 'www'@'%'; CREATE DATABASE wordpress;"

