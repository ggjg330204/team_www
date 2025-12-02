#!/bin/bash
# WAS VMSS 초기화 스크립트 (멱등성 보장)
# 작성일: 2025-11-30
# 로깅 설정
LOG_FILE="/var/log/was_init.log"
exec >> "$$LOG_FILE" 2>&1

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $$1"
}

log "=========================================="
log "WAS VMSS 초기화 시작"
log "=========================================="

# 완료 플래그 파일 확인 (멱등성)
COMPLETE_FLAG="/tmp/was_init_complete.txt"
if [ -f "$$COMPLETE_FLAG" ]; then
    if rpm -q httpd >/dev/null 2>&1; then
        log "초기화가 이미 완료되었으며 httpd가 설치되어 있습니다. 스킵합니다."
        log "기존 완료 시간: $$(cat $$COMPLETE_FLAG)"
        exit 0
    else
        log "완료 플래그가 존재하지만 httpd가 설치되지 않았습니다. 재시도합니다."
    fi
fi

# SELinux 비활성화
log "SELinux 비활성화"
setenforce 0 2>/dev/null || log "SELinux already permissive"
grubby --update-kernel ALL --args selinux=0 2>/dev/null || log "grubby 설정 스킵"

# 방화벽 설정
log "방화벽 설정 - HTTP(80), HTTPS(443), SSH(22) 포트 허용"
systemctl enable firewalld 2>/dev/null
systemctl start firewalld 2>/dev/null
firewall-cmd --zone=public --add-service=http --permanent 2>/dev/null
firewall-cmd --zone=public --add-service=https --permanent 2>/dev/null
firewall-cmd --zone=public --add-port=22/tcp --permanent 2>/dev/null
firewall-cmd --reload 2>/dev/null
log "방화벽 설정 완료"

# DNF 최적화
log "DNF 설정 최적화"
cat >> /etc/dnf/dnf.conf <<EOF
timeout=30
retries=5
minrate=1000
fastestmirror=True
max_parallel_downloads=10
EOF

# DNF 캐시 정리
log "DNF 캐시 정리 및 메타데이터 갱신"
dnf clean all 2>/dev/null
dnf makecache --refresh 2>/dev/null || log "메타데이터 갱신 실패 (무시)"

# httpd가 이미 설치되어 있는지 확인 (멱등성)
if rpm -q httpd >/dev/null 2>&1; then
    log "httpd가 이미 설치되어 있습니다. 설치 스킵"
    HTTPD_INSTALLED=true
else
    HTTPD_INSTALLED=false
    log "httpd 및 PHP 패키지 설치 시작"
    
    # 재시도 로직 강화 (5회 시도, 지수 백오프)
    MAX_RETRIES=5
    RETRY_COUNT=0
    BACKOFF=5
    
    for i in 1 2 3 4 5; do
        log "패키지 설치 시도 ($$i/5)"
        
        if timeout 300 dnf install -y httpd php php-mysqlnd; then
            log "패키지 설치 성공!"
            HTTPD_INSTALLED=true
            break
        fi
        
        if [ $$i -lt 5 ]; then
            WAIT_TIME=10
            log "패키지 설치 실패. $$WAIT_TIME초 후 재시도..."
            sleep $$WAIT_TIME
            dnf clean all 2>/dev/null
        fi
    done
    
    if [ "$$HTTPD_INSTALLED" = false ]; then
        log "패키지 설치 최종 실패. 시스템 패키지 정보 확인..."
        dnf repolist 2>&1 | head -20
        log "대체 방법 시도: 최소 패키지만 설치"
        dnf install -y httpd || log "httpd 단독 설치도 실패"
    fi
fi

# 웹 디렉터리 생성
log "웹 디렉터리 설정"
mkdir -p /var/www/html
chmod 755 /var/www/html

# 테스트 페이지 생성 (멱등성)
log "테스트 페이지 생성"
SERVER_HOSTNAME=`hostname`

# index.php
if [ ! -f /var/www/html/index.php ]; then
    cat > /var/www/html/index.php <<EOF
<?php
echo "<h1>WAS Server: $$SERVER_HOSTNAME</h1>";
echo "<p>Time: " . date('Y-m-d H:i:s') . "</p>";
echo "<p>PHP Version: " . phpversion() . "</p>";
echo "<hr>";
echo "<h2>Server Info</h2>";
echo "<pre>";
echo "Hostname: " . gethostname() . "\\n";
echo "Server IP: " . \$_SERVER['SERVER_ADDR'] . "\\n";
echo "Client IP: " . \$_SERVER['REMOTE_ADDR'] . "\\n";
echo "</pre>";
?>
EOF
    log "index.php 생성 완료"
else
    log "index.php 이미 존재 (스킵)"
fi

# index.html (Fallback)
if [ ! -f /var/www/html/index.html ]; then
    cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head><title>WAS Server</title></head>
<body>
    <h1>WAS Server (Static): $$SERVER_HOSTNAME</h1>
    <p>Time: $$(date '+%Y-%m-%d %H:%M:%S')</p>
    <p>Status: Active</p>
</body>
</html>
EOF
    log "index.html 생성 완료"
else
    log "index.html 이미 존재 (스킵)"
fi

# Health check 파일 생성
log "Health check 파일 생성"
echo "$$SERVER_HOSTNAME - $$(date)" > /var/www/html/health.html
log "health.html 생성 완료: $$(cat /var/www/html/health.html)"

# 웹 디렉터리 권한 설정
log "웹 디렉터리 권한 설정"
chown -R apache:apache /var/www/html 2>/dev/null || chown -R root:root /var/www/html
chmod -R 755 /var/www/html
log "권한 설정 완료"

# httpd가 설치되어 있을 때만 서비스 시작
if [ "$$HTTPD_INSTALLED" = true ] || rpm -q httpd >/dev/null 2>&1; then
    log "httpd 서비스 설정 및 시작"
    
    # Apache 설정 - DirectoryIndex 변경
    if [ -f /etc/httpd/conf/httpd.conf ]; then
        sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php index.html/g' /etc/httpd/conf/httpd.conf 2>/dev/null
        log "DirectoryIndex 설정 완료"
    fi
    
    # httpd 시작
    systemctl enable httpd 2>/dev/null
    systemctl restart httpd 2>/dev/null
    sleep 3
    
    if systemctl is-active httpd >/dev/null 2>&1; then
        log "httpd 서비스 정상 실행 중"
        systemctl status httpd --no-pager | head -10
    else
        log "httpd 서비스 시작 실패. 상태 확인:"
        systemctl status httpd --no-pager 2>&1 | head -20
    fi
    
    # 로컬 테스트
    log "로컬 헬스 체크 수행"
    sleep 2
    if curl -I http://localhost/health.html 2>&1 | grep -q "200 OK"; then
        log "✅ 로컬 헬스 체크 성공"
    else
        log "⚠️  로컬 헬스 체크 실패. curl 출력:"
        curl -I http://localhost/health.html 2>&1 | head -10
    fi
else
    log "⚠️  httpd 미설치 상태. 서비스 시작 스킵"
fi

# 완료 표시
log "=========================================="
log "WAS VMSS 초기화 완료"
log "=========================================="
date > "$$COMPLETE_FLAG"
chmod 644 "$$COMPLETE_FLAG"
log "완료 플래그 파일 생성: $$COMPLETE_FLAG"
