#!/bin/bash

# Let's Encrypt SSL 인증서 자동 발급 및 갱신 스크립트
# Azure Key Vault에 자동 업로드

set -e

# 설정
DOMAIN="hamap.shop"
EMAIL="admin@hamap.shop"
KEYVAULT_NAME="www-kv-xxxxx"  # terraform output으로 교체
CERT_NAME="www-ssl-cert"

# 색상 코드
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Let's Encrypt SSL 인증서 자동 발급 스크립트 ===${NC}"

# 1. Certbot 설치 확인
if ! command -v certbot &> /dev/null; then
    echo -e "${YELLOW}Certbot이 설치되지 않았습니다. 설치 중...${NC}"
    sudo apt-get update
    sudo apt-get install -y certbot
fi

# 2. 인증서 발급 (DNS-01 챌린지)
echo -e "${GREEN}Step 1: DNS-01 챌린지로 인증서 발급${NC}"
echo -e "${YELLOW}주의: DNS TXT 레코드를 수동으로 추가해야 합니다.${NC}"

sudo certbot certonly --manual \
  --preferred-challenges=dns \
  --email $EMAIL \
  --agree-tos \
  --no-eff-email \
  -d $DOMAIN \
  -d www.$DOMAIN

# 3. PFX 파일로 변환
echo -e "${GREEN}Step 2: PFX 파일로 변환${NC}"
CERT_PATH="/etc/letsencrypt/live/$DOMAIN"
PFX_PATH="/tmp/${DOMAIN}.pfx"
PFX_PASSWORD=$(openssl rand -base64 32)

sudo openssl pkcs12 -export \
  -out $PFX_PATH \
  -inkey ${CERT_PATH}/privkey.pem \
  -in ${CERT_PATH}/fullchain.pem \
  -password pass:$PFX_PASSWORD

# 4. Azure Key Vault에 업로드
echo -e "${GREEN}Step 3: Azure Key Vault에 업로드${NC}"

# Key Vault 이름 가져오기 (terraform output 사용)
if [ "$KEYVAULT_NAME" = "www-kv-xxxxx" ]; then
    KEYVAULT_NAME=$(terraform output -raw out_10_keyvault_name 2>/dev/null || echo "")
    if [ -z "$KEYVAULT_NAME" ]; then
        echo -e "${RED}Error: Key Vault 이름을 찾을 수 없습니다.${NC}"
        echo "terraform output -raw out_10_keyvault_name 명령을 확인하세요."
        exit 1
    fi
fi

# 인증서 업로드
az keyvault certificate import \
  --vault-name $KEYVAULT_NAME \
  --name $CERT_NAME \
  --file $PFX_PATH \
  --password $PFX_PASSWORD

# 5. 정리
sudo rm -f $PFX_PATH

# 6. 인증서 정보 출력
echo -e "${GREEN}=== 인증서 발급 완료 ===${NC}"
echo "Domain: $DOMAIN, www.$DOMAIN"
echo "Key Vault: $KEYVAULT_NAME"
echo "Certificate Name: $CERT_NAME"
echo ""
echo -e "${YELLOW}다음 명령어로 인증서 정보를 확인할 수 있습니다:${NC}"
echo "az keyvault certificate show --vault-name $KEYVAULT_NAME --name $CERT_NAME"

# 7. 만료일 확인
EXPIRY_DATE=$(sudo openssl x509 -in ${CERT_PATH}/fullchain.pem -noout -enddate | cut -d= -f2)
echo -e "${GREEN}만료일: $EXPIRY_DATE${NC}"

# 8. 갱신 Cron Job 설정 (선택사항)
echo ""
echo -e "${YELLOW}자동 갱신을 위해 다음 Cron Job을 추가하세요:${NC}"
echo "0 0 1 */2 * /bin/bash $(pwd)/renew_ssl.sh >> /var/log/ssl_renewal.log 2>&1"
