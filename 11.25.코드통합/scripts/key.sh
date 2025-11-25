#! /bin/bash
# SSH 키 설정 스크립트
# Bastion 호스트 등에서 내부 서버 접속을 위한 Private Key 설정

setenforce 0
grubby --update-kernel ALL -args selinux=0
echo -e "-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACD0DM+qV6ddSoU9IVr7Y4X51gsb1RGrkYcO3U4Lp6LuDAAAAJje8/633vP+
twAAAAtzc2gtZWQyNTUxOQAAACD0DM+qV6ddSoU9IVr7Y4X51gsb1RGrkYcO3U4Lp6LuDA
AAAEAY4HQXT63XaRsqFwkH3XQYpg7ZU/L4pl6Q09LMTQfa7fQMz6pXp11KhT0hWvtjhfnW
CxvVEauRhw7dTgunou4MAAAAEGdnamczM0BnbWFpbC5jb20BAgMEBQ==
-----END OPENSSH PRIVATE KEY-----" > /home/www/.ssh/id_ed25519
chown www.www /home/www/.ssh/id_ed25519
chmod 600 /home/www/.ssh/id_ed25519