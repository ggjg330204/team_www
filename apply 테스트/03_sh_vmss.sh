#! /bin/bash
set -e

LOG_FILE="/var/log/startup-script-vmss.log"
exec > >(tee -a "$LOG_FILE") 2>&1

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log "===== VMSS 인스턴스 초기화 스크립트 시작 ====="

log "index.html 파일 생성을 시작합니다."
SERVER_HOSTNAME=$(hostname)
sudo tee /var/www/html/index.html <<EOF > /dev/null
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TEAM_1 홈페이지</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 0; line-height: 1.6; color: #222; background-color: #ffffff; }
        header { background-color: #000; color: #fff; padding: 25px 20px; text-align: center; font-size: 2em; font-weight: bold; position: relative; }
        #hostname-display { position: absolute; top: 10px; right: 20px; font-size: 0.9em; color: #fff; background-color: rgba(0,0,0,0.3); padding: 4px 8px; border-radius: 5px; }
        section { padding: 60px 20px; max-width: 1000px; margin: auto; color: #222; background-color: #ffffff; }
        section h2 { border-bottom: 3px solid #555; padding-bottom: 10px; margin-bottom: 25px; font-size: 1.8em; }
        .links a { display: inline-block; margin-right: 15px; margin-bottom: 10px; padding: 8px 15px; background-color: #444; color: #fff; text-decoration: none; border-radius: 5px; font-weight: 500; transition: 0.3s; }
        .links a:hover { background-color: #222; }
        .resources ul { list-style-type: square; padding-left: 20px; }
        .resources ul li a { color: #000; text-decoration: none; transition: 0.3s; }
        .resources ul li a:hover { text-decoration: underline; color: #555; }
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
        const hostname = '${SERVER_HOSTNAME}';
        document.getElementById("hostname-display").textContent = hostname;
        const rainbowColors = ["#FF9999","#FFC999","#FFFF99","#99FF99","#9999FF","#A399C8","#C899FF","#FFB3DE","#B3E0FF","#FFD6A5"];
        let selectedColor = "#000000";
        let colorIndex = null;
        let webMatch = hostname.match(/web(\d+)vm$/);
        if (webMatch) {
            const num = parseInt(webMatch[1], 10);
            colorIndex = num;
        }
        let vmssMatch = hostname.match(/vmss(\d{6})$/);
        if (vmssMatch) {
            const num = parseInt(vmssMatch[1], 10);
            colorIndex = num + 2;
        }
        if (colorIndex !== null && colorIndex > 0) {
            const safeIndex = (colorIndex - 1) % rainbowColors.length;
            selectedColor = rainbowColors[safeIndex];
        }
        document.querySelector('header').style.backgroundColor = selectedColor;
    </script>
</body>
</html>
EOF
log "index.html 파일 생성 완료."

log "===== VMSS 스크립트 실행이 성공적으로 완료되었습니다. ====="