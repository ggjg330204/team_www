#! /bin/bash

# setenforce 0
# grubby --update-kernel ALL --args selinux=0
# echo -e "-----BEGIN OPENSSH PRIVATE KEY-----
# b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
# QyNTUxOQAAACD0DM+qV6ddSoU9IVr7Y4X51gsb1RGrkYcO3U4Lp6LuDAAAAJje8/633vP+
# twAAAAtzc2gtZWQyNTUxOQAAACD0DM+qV6ddSoU9IVr7Y4X51gsb1RGrkYcO3U4Lp6LuDA
# AAAEAY4HQXT63XaRsqFwkH3XQYpg7ZU/L4pl6Q09LMTQfa7fQMz6pXp11KhT0hWvtjhfnW
# CxvVEauRhw7dTgunou4MAAAAEGdnamczM0BnbWFpbC5jb20BAgMEBQ==
# -----END OPENSSH PRIVATE KEY-----" > /home/www/.ssh/id_ed25519
# chown www.www /home/www/.ssh/id_ed25519
# chmod 600 /home/www/.ssh/id_ed25519

setenforce 0
sudo firewall-cmd --zone=public --add-port=22/tcp --permanent
sudo firewall-cmd --reload

grubby --update-kernel ALL --args selinux=0
echo -e "-----BEGIN RSA PRIVATE KEY-----\n
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\n
-----END OPENSSH PRIVATE KEY-----" > /home/www/.ssh/id_ed25519
chown www.www /home/www/.ssh/id_ed25519
chmod 600 /home/www/.ssh/id_ed25519