#! /bin/bash
setenforce 0
grubby --update-kernel ALL --args selinux=0
dnf install -y mysql-server
systemctl enable --now mysqld
mysql -uroot -e "CREATE USER 'www'@'%' IDENTIFIED BY 'It12345!'; GRANT ALL PRIVILEGES ON *.* TO 'hyb'@'%'; CREATE DATABASE wordpress;"

