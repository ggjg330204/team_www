#! /bin/bash
setenforce 0
grubby --update-kernel ALL --args selinux=0
dnf install -y mysql-server
systemctl enable --now mysqld
mysql -uroot -e "create user 'www'@'%' identified by 'It12345!'; grant all privileges on *.* to 'www'@'%'; create database wordpress;"