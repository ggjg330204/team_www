#! /bin/bash
setenforce 0
grubby --update-kernel ALL --args
selinux=0
dnf install -y mysql lynx