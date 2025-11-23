#! /bin/bash
setenforce 0
grubby --update-kernel ALL --args selinux=0
dnf install -y mysql-server openssh
systemctl enable --now sshd
sudo systemctl enable --now mysqld
sudo mysql -uroot -e "create user 'www'@'%' identified by 'It12345!'; grant all privileges on *.* to 'www'@'%'; create database wordpress;"