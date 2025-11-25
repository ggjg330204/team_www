#! /bin/bash
# Bastion 호스트 설정 스크립트
# SELinux 비활성화 및 MySQL 클라이언트, Lynx 설치
setenforce 0
grubby --update-kernel ALL --args
selinux=0
dnf install -y mysql lynx