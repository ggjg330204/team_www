#!/bin/bash
# Web VMSS 초기화 스크립트
# 작성일: 2025-11-28
# 로깅 설정
LOG_FILE="/var/log/web_init.log"
exec > >(tee -a "$LOG_FILE") 2>&1

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "=========================================="
log "Web VMSS 초기화 시작"
log "=========================================="

# SELinux 비활성화
log "SELinux 비활성화"
setenforce 0 || log "SELinux already permissive"
grubby --update-kernel ALL --args selinux=0 || log "grubby 설정 실패 (무시)"

# 방화벽 설정
log "방화벽 설정 - HTTP(80), HTTPS(443), SSH(22) 포트 허용"
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --zone=public --add-service=https --permanent
firewall-cmd --zone=public --add-port=22/tcp --permanent
firewall-cmd --reload
log "방화벽 설정 완료"

# Nginx 설치
log "Nginx 패키지 설치"
dnf install -y nginx
log "Nginx 설치 완료"

# Nginx 리버스 프록시 설정
log "Nginx 리버스 프록시 설정 생성"
cat <<EOF > /etc/nginx/conf.d/reverse_proxy.conf
server {
    listen 80 default_server;
    server_name _;

    location / {
        proxy_pass http://${was_lb_ip};
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    location /health.html {
        access_log off;
        return 200 'Web-OK';
        add_header Content-Type text/plain;
    }
}
EOF
log "Nginx 설정 파일 생성 완료"

# 기본 설정 제거
log "기본 Nginx 설정 제거"
rm -f /etc/nginx/conf.d/default.conf || log "기본 설정 파일 없음"

# Nginx 테스트 및 시작
log "Nginx 설정 테스트"
nginx -t && log "Nginx 설정 검증 성공" || log "Nginx 설정 검증 실패"

log "Nginx 서비스 시작"
systemctl enable nginx
systemctl start nginx
systemctl status nginx --no-pager || log "Nginx 상태 확인 실패"

# 로컬 테스트
log "로컬 테스트 수행"
sleep 2
curl -I http://localhost/health.html && log "로컬 헬스 체크 성공" || log "로컬 헬스 체크 실패"

# 완료 표시
log "=========================================="
log "Web VMSS 초기화 완료"
log "=========================================="
echo "INIT_COMPLETED" > /tmp/web_init_complete.txt
chmod 644 /tmp/web_init_complete.txt
log "완료 플래그 파일 생성: /tmp/web_init_complete.txt"
