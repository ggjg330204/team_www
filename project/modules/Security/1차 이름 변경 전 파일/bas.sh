#! /bin/bash
setenforce 0
grubby --update-kernel ALL --args selinux=0
dnf install -y mysql lynx
echo -e "-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACD0DM+qV6ddSoU9IVr7Y4X51gsb1RGrkYcO3U4Lp6LuDAAAAJje8/633vP+
twAAAAtzc2gtZWQyNTUxOQAAACD0DM+qV6ddSoU9IVr7Y4X51gsb1RGrkYcO3U4Lp6LuDA
AAAEAY4HQXT63XaRsqFwkH3XQYpg7ZU/L4pl6Q09LMTQfa7fQMz6pXp11KhT0hWvtjhfnW
CxvVEauRhw7dTgunou4MAAAAEGdnamczM0BnbWFpbC5jb20BAgMEBQ==
-----END OPENSSH PRIVATE KEY-----" > /home/www/.ssh/id_ed25519
sudo chmod 600 /home/www/.ssh/id_ed25519
sudo chown www.www /home/www/.ssh/id_ed25519