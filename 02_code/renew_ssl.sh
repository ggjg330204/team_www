#!/bin/bash

# Let's Encrypt SSL 인증서 자동 갱신 스크립트

set -e

DOMAIN="hamap.shop"
KEYVAULT_NAME=$(terraform output -raw out_10_keyvault_name 2>/dev/null)
CERT_NAME="www-ssl-cert"

echo "=== SSL 인증서 자동 갱신 ==="
echo "Domain: $DOMAIN"
echo "Key Vault: $KEYVAULT_NAME"

# 1. 인증서 갱신
sudo certbot renew --quiet

# 2. PFX 변환 및 업로드
CERT_PATH="/etc/letsencrypt/live/$DOMAIN"
if [ -f "${CERT_PATH}/fullchain.pem" ]; then
    PFX_PATH="/tmp/${DOMAIN}.pfx"
    PFX_PASSWORD=$(openssl rand -base64 32)
    
    sudo openssl pkcs12 -export \
      -out $PFX_PATH \
      -inkey ${CERT_PATH}/privkey.pem \
      -in ${CERT_PATH}/fullchain.pem \
      -password pass:$PFX_PASSWORD
    
    az keyvault certificate import \
      --vault-name $KEYVAULT_NAME \
      --name $CERT_NAME \
      --file $PFX_PATH \
      --password $PFX_PASSWORD
    
    sudo rm -f $PFX_PATH
    echo "인증서 갱신 완료: $(date)"
else
    echo "인증서 파일을 찾을 수 없습니다."
    exit 1
fi
