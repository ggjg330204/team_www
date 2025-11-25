#!/bin/bash
mkdir -p /home/${admin_username}/.ssh
echo "${ssh_private_key}" > /home/${admin_username}/.ssh/id_rsa
chmod 600 /home/${admin_username}/.ssh/id_rsa
chown -R ${admin_username}:${admin_username} /home/${admin_username}/.ssh
dnf install -y mysql