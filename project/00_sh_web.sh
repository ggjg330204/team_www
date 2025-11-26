#! /bin/bash
setenforce 0
grubby --update-kernel ALL --args selinux=0
dnf install -y wget httpd php php-gd php-opcache php-mysqlnd
wget https://ko.wordpress.org/wordpress-6.8.3-ko_KR.tar.gz
tar xvfz wordpress-6.8.3-ko_KR.tar.gz
cp -ar wordpress/* /var/www/html
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php/g' /etc/httpd/conf/httpd.conf
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sed -i 's/database_name_here/wordpress/g' /var/www/html/wp-config.php
sed -i 's/username_here/hyb/g' /var/www/html/wp-config.php
sed -i 's/password_here/It12345!/g' /var/www/html/wp-config.php
sed -i 's/localhost/10.0.5.4/g' /var/www/html/wp-config.php
echo $HOSTNAME > /var/www/html/health.html
systemctl enable --now httpd


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
            /* **[변경됨]** body 배경색을 흰색으로 고정 (CSS에서 직접 설정) */
            background-color: #ffffff; 
        }

        /* 상단 영역 */
        header {
            /* **[변경됨]** 기본 배경색 설정 (JS에서 호스트네임에 따라 변경될 예정) */
            background-color: #000; 
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
            /* **[참고]** 섹션 자체는 흰색 배경을 유지 */
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
            <a href="https://docs.google.com/presentation/d/1POM2feOR6tb6ollBAfYMIvgkHAtwed9iAOqlzqIHcws/edit?usp=sharing" target="_blank" title="Google Slide 열기">Google Slide</a>
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
        // =============================================
        // 1. 테스트용 호스트네임 (PC 1대에서 테스트할 때)
        //const TEST_HOSTNAME = "www-web"; 
        //const TEST_HOSTNAME = "www-vmss000001"; 
        //const TEST_HOSTNAME = "www-vmss000003"; 
        // TEST_HOSTNAME 값을 바꿔가며 색상 확인 가능 (예: 'www-vmss000001' -> 빨강)
        // =============================================

        // 2. 실제 페이지에서는 서버에서 호스트네임을 주입
        const hostname = '${SERVER_HOSTNAME}'; // 실제 서버에서 주입 시 주석 해제
        // const hostname = TEST_HOSTNAME; // 테스트 시 주석 해제

        // 아래 라인 하나로 테스트/실제 쉽게 전환 가능
        //const hostname = TEST_HOSTNAME;

        // 오른쪽 위 호스트네임 표시
        document.getElementById("hostname-display").textContent = hostname;

        // 무지개 색상 배열
 const rainbowColors = [
        "#FF9999", // 0: 연한 빨강
            "#FFC999", // 1: 연한 주황
            "#FFFF99", // 2: 연한 노랑
            "#99FF99", // 3: 연한 초록
            "#9999FF", // 4: 연한 파랑
            "#A399C8", // 5: 연한 남색
            "#C899FF"  // 6: 연한 보라
        ];

        let selectedColor = "#000000"; // 기본 검정색
        let instanceNumber = null; // 인스턴스 번호를 저장할 변수

        // 1. www- 접두사에 관계없이 [접두사]-vmss[6자리 숫자] 패턴 처리
        if (/-vmss\d{6}$/.test(hostname)) {
            // 호스트네임 끝 6자리 숫자를 추출
            const match = hostname.match(/\d{6}$/);
            if (match) {
                // 6자리 숫자를 정수로 변환 (예: 000001 -> 1)
                instanceNumber = parseInt(match[0], 10);
            }
        } 
        
        // 2. www- 접두사에 관계없이 [접두사]-web[숫자]vm 패턴 처리
        else if (/-web\d+vm$/.test(hostname)) {
            // web과 vm 사이에 있는 숫자를 추출
            const match = hostname.match(/web(\d+)vm$/);
            if (match && match[1]) {
                // 숫자를 정수로 변환 (예: web1vm -> 1)
                instanceNumber = parseInt(match[1], 10);
            }
        }
        
        // 인스턴스 번호가 유효할 경우 색상 할당
        if (instanceNumber !== null && instanceNumber > 0) {
            // 숫자를 배열 길이로 나눈 나머지로 인덱스 결정 (순환)
            // 인덱스는 0부터 시작하므로, 1번 인스턴스는 0번 인덱스에 매핑되도록 -1을 사용
            const colorIndex = (instanceNumber - 1) % rainbowColors.length;
            selectedColor = rainbowColors[colorIndex];
        }

        // **[변경됨]** body가 아닌 header 배경색 적용
        document.querySelector('header').style.backgroundColor = selectedColor;    </script>

</body>
</html>
EOF