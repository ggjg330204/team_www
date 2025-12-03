#!/bin/bash
# Bastion Host 초기화 스크립트
# 작성일: 2025-11-28
# 로깅 설정
LOG_FILE="/var/log/bastion_init.log"
exec > >(tee -a "$LOG_FILE") 2>&1

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "=========================================="
log "Bastion 초기화 시작"
log "=========================================="

# SELinux 비활성화
log "SELinux 비활성화"
setenforce 0 || log "SELinux already permissive"
grubby --update-kernel ALL --args selinux=0 || log "grubby 설정 실패 (무시)"

# 방화벽 설정 (비활성화 대신 포트 열기)
log "방화벽 설정 - SSH 포트 22 허용"
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --zone=public --add-port=22/tcp --permanent
firewall-cmd --reload
log "방화벽 설정 완료"

# SSH 서비스 확인
log "SSH 서비스 시작"
systemctl enable sshd
systemctl restart sshd
systemctl status sshd --no-pager || log "SSH 상태 확인 실패"

# 네트워크 확인
log "네트워크 정보:"
ip addr show eth0 || true
ip route show || true

# 기본 도구 설치 (선택사항)
log "기본 도구 설치 (zsh, git, vim, wget, curl)"
dnf install -y vim wget curl git zsh bash-completion 2>&1 || log "일부 패키지 설치 실패 (무시)"

# 사용자 쉘 설정 (zsh)
ADMIN_USER="${admin_username}"
if id "$ADMIN_USER" &>/dev/null; then
    log "사용자 $ADMIN_USER 쉘 설정 (zsh)"
    usermod -s /bin/zsh "$ADMIN_USER"
    
    # 간단한 .zshrc 생성
    cat <<EOF > /home/$ADMIN_USER/.zshrc
export PATH=$PATH:/usr/local/bin
export ZSH_THEME="robbyrussell"
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
PROMPT='%F{cyan}%n@%m%f %F{yellow}%~%f %# '
EOF
    chown $ADMIN_USER:$ADMIN_USER /home/$ADMIN_USER/.zshrc
else
    log "사용자 $ADMIN_USER 를 찾을 수 없음"
fi

# Azure CLI 설치 시도 (선택사항)
log "Azure CLI 설치 시도"
rpm --import https://packages.microsoft.com/keys/microsoft.asc 2>&1 || log "키 가져오기 실패"
dnf install -y https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm 2>&1 || log "레포지토리 추가 실패"
dnf install -y azure-cli 2>&1 || log "Azure CLI 설치 실패"

# 완료 표시
log "=========================================="
log "Bastion 초기화 완료"
log "=========================================="
echo "INIT_COMPLETED" > /tmp/bastion_init_complete.txt
chmod 644 /tmp/bastion_init_complete.txt
log "완료 플래그 파일 생성: /tmp/bastion_init_complete.txt"
