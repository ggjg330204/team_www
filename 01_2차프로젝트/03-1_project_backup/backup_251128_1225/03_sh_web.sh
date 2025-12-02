#! /bin/bash
setenforce 0
grubby --update-kernel ALL --args selinux=0
sudo dnf install -y wget httpd php php-gd php-opcache php-mysqlnd
wget https://ko.wordpress.org/wordpress-6.8.3-ko_KR.tar.gz
tar xvfz wordpress-6.8.3-ko_KR.tar.gz
cp -ar wordpress/* /var/www/html
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php/g' /etc/httpd/conf/httpd.conf
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sed -i 's/database_name_here/wordpress/g' /var/www/html/wp-config.php
sed -i 's/username_here/www/g' /var/www/html/wp-config.php
sed -i 's/password_here/It12345!/g' /var/www/html/wp-config.php
sed -i 's/localhost/10.0.4.4/g' /var/www/html/wp-config.php
echo $HOSTNAME > /var/www/html/health.html

# 방화벽 설정
sudo firewall-cmd --zone=public --add-port=22/tcp --permanent
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
sudo firewall-cmd --reload

# 권한 설정 (httpd 시작 전에 반드시 필요)
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# httpd 서비스 시작 (방화벽 및 권한 설정 후)
sudo systemctl enable --now httpd
## id_ed25519
echo -e "-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACD0DM+qV6ddSoU9IVr7Y4X51gsb1RGrkYcO3U4Lp6LuDAAAAJje8/633vP+
twAAAAtzc2gtZWQyNTUxOQAAACD0DM+qV6ddSoU9IVr7Y4X51gsb1RGrkYcO3U4Lp6LuDA
AAAEAY4HQXT63XaRsqFwkH3XQYpg7ZU/L4pl6Q09LMTQfa7fQMz6pXp11KhT0hWvtjhfnW
CxvVEauRhw7dTgunou4MAAAAEGdnamczM0BnbWFpbC5jb20BAgMEBQ==
-----END OPENSSH PRIVATE KEY-----" > /home/www/.ssh/id_ed25519
chown www:www /home/www/.ssh/id_ed25519
chmod 600 /home/www/.ssh/id_ed25519

# authorized_keys 설정 (공개키)
cat <<'EOF' > /home/www/.ssh/authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPQMz6pXp11KhT0hWvtjhfnWCxvVEauRhw7dTgunou4M 
EOF
chown www:www /home/www/.ssh/authorized_keys
chmod 600 /home/www/.ssh/authorized_keys


SERVER_HOSTNAME=$(hostname)

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TEAM_1 홈페이지</title>
    <style>
        /* 전체 기본 스타일 */
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            line-height: 1.6;
            color: #222;
            background-color: #ffffff; /* body 배경색 흰색 */
        }

        /* 상단 영역 */
        header {
            background-color: #000; /* 기본 검정 (JS에서 변경됨) */
            color: #fff;
            padding: 25px 20px;
            text-align: center;
            font-size: 2em;
            font-weight: bold;
            position: relative;
        }

        /* 오른쪽 위 호스트네임 표시 */
        #hostname-display {
            position: absolute;
            top: 10px;
            right: 20px;
            font-size: 0.9em;
            color: #fff;
            background-color: rgba(0,0,0,0.3);
            padding: 4px 8px;
            border-radius: 5px;
        }

        /* 섹션 공통 스타일 */
        section {
            padding: 60px 20px;
            max-width: 1000px;
            margin: auto;
            color: #222;
            background-color: #ffffff;
        }

        section h2 {
            border-bottom: 3px solid #555;
            padding-bottom: 10px;
            margin-bottom: 25px;
            font-size: 1.8em;
        }

        /* 사이트 연결 링크 스타일 */
        .links a {
            display: inline-block;
            margin-right: 15px;
            margin-bottom: 10px;
            padding: 8px 15px;
            background-color: #444;
            color: #fff;
            text-decoration: none;
            border-radius: 5px;
            font-weight: 500;
            transition: 0.3s;
        }

        .links a:hover {
            background-color: #222;
        }

        /* 자료 리스트 */
        .resources ul {
            list-style-type: square;
            padding-left: 20px;
        }

        .resources ul li a {
            color: #000;
            text-decoration: none;
            transition: 0.3s;
        }

        .resources ul li a:hover {
            text-decoration: underline;
            color: #555;
        }

        /* 반응형 */
        @media (max-width: 600px) {
            header { font-size: 1.5em; padding: 20px 10px; }
            section { padding: 40px 15px; }
            .links a { padding: 6px 10px; margin-right: 10px; }
            #hostname-display { font-size: 0.8em; top: 8px; right: 10px; }
        }
    </style>
</head>
<body>

    <header>
        TEAM_1 HOMEPAGE
        <div id="hostname-display"></div>
    </header>

    <section id="home">
        <h2>홈</h2>
        <p>환영합니다! TEAM_1 홈페이지에 오신 것을 환영합니다.</p>
    </section>

    <section id="links">
        <h2>사이트 연결</h2>
        <div class="links">
            <a href="https://github.com/ggjg330204/team_www" target="_blank" title="GitHub 저장소 열기">GitHub</a>
            <a href="https://docs.google.com/document/d/1yTNmIULeCsDkz-_H1BI9BW3sZb_jHD2bhuKGa77sQXE/edit?usp=sharing" target="_blank" title="Google Docs 열기">Google Docs</a>
            <a href="https://docs.google.com/presentation/d/1023rV6HVXmOczvLDnT7QpIm6KHIS0QxUEWnrc9dNAa8/edit?slide=id.p1#slide=id.p1" target="_blank" title="Google Slide 열기">Google Slide</a>
        </div>
    </section>

    <section id="resources">
        <h2>포트폴리오</h2>
        <div class="resources">
            <ul>
                <li><a href="#" title="이기훈 자료 다운로드">이기훈</a></li>
                <li><a href="#" title="자료 2 다운로드">자료 2</a></li>
                <li><a href="#" title="자료 3 다운로드">자료 3</a></li>
            </ul>
        </div>
    </section>

    <script>
        /* ============================================================
           1) 실제 페이지에서는 서버에서 hostname 주입
        ============================================================ */
        const hostname = '${SERVER_HOSTNAME}';  
        // const hostname = "ghl-vmss000003";    // 테스트 시 사용
        // const hostname = "www-vnet1-web1vm"; // 테스트 시 사용

        document.getElementById("hostname-display").textContent = hostname;

        /* ============================================================
           2) 색상 배열 (index 1~10)
        ============================================================ */
        const rainbowColors = [
            "#FF9999", // 1
            "#FFC999", // 2
            "#FFFF99", // 3
            "#99FF99", // 4
            "#9999FF", // 5
            "#A399C8", // 6
            "#C899FF", // 7
            "#FFB3DE", // 8
            "#B3E0FF", // 9
            "#FFD6A5"  // 10
        ];

        let selectedColor = "#000000";
        let colorIndex = null;

        /* ============================================================
           3) webXvm → index = X 그대로 (1,2,3 ...)
        ============================================================ */
        let webMatch = hostname.match(/web(\d+)vm$/);
        if (webMatch) {
            const num = parseInt(webMatch[1], 10); // web3vm → 3
            colorIndex = num;
        }

        /* ============================================================
           4) vmss00000X → index = X + 2 (규칙: 1→3, 2→4, ..., 8→10)
        ============================================================ */
        let vmssMatch = hostname.match(/vmss(\d{6})$/);
        if (vmssMatch) {
            const num = parseInt(vmssMatch[0], 10); // 000001 → 1
            colorIndex = num + 2;
        }

        /* ============================================================
           5) 색상 최종 적용 (배열 순환)
        ============================================================ */
        if (colorIndex !== null && colorIndex > 0) {
            const safeIndex = (colorIndex - 1) % rainbowColors.length; 
            selectedColor = rainbowColors[safeIndex];
        }

        document.querySelector('header').style.backgroundColor = selectedColor;
    </script>

</body>
</html>
EOF