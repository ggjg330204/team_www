# 접속 및 관리 가이드 (Practical Connection Guide)

> **🚀 팀원이 처음 시작하신다면?** → **[00_Quick_Start_for_Team.md](./00_Quick_Start_for_Team.md)** 문서를 먼저 읽어주세요!
> 
> 이 문서는 이미 Terraform과 Bastion에 익숙한 분들을 위한 상세 레퍼런스입니다.

본 문서는 로컬 PC에서 Azure의 모든 리소스(VM, DB, Storage 등)에 접속하고 관리하는 **실전 명령어**를 정리합니다.

---

## 1. 서버 접속 (Compute)

### 1.0 IP 주소 확인 및 변수 설정 (PowerShell)
접속 전에 Terraform output에서 IP를 변수에 저장해두면 편리하고 멱등성이 보장됩니다.

```powershell
# Terraform Output으로 IP 주소 확인 및 변수 저장
$BASTION_IP = terraform output -raw out_02_bastion_public_ip
$LB_IP = terraform output -raw out_01_load_balancer_public_ip
$WEBVM_IP = terraform output -raw out_30_webvm_private_ip
$RG_NAME = terraform output -raw out_20_resource_group

Write-Host "Bastion IP : $BASTION_IP"
Write-Host "LB IP      : $LB_IP"
Write-Host "Web VM IP  : $WEBVM_IP"
Write-Host "RG Name    : $RG_NAME"
```

### 1.1 Bastion Host 접속
가장 기본적인 진입점입니다. SSH config가 설정되어 있으므로 `-i` 옵션 없이 접속 가능합니다.

```powershell
# 변수 사용 (권장)
ssh www@$BASTION_IP
```

### 1.2 Web VM 접속 (내부망)
Bastion을 경유하여 내부 Web VM에 접속합니다.

```powershell
# ProxyJump 옵션 사용
ssh -J www@$BASTION_IP www@$WEBVM_IP
```

### 1.3 VMSS 인스턴스 접속
VM Scale Set은 여러 대의 인스턴스로 구성되므로, 먼저 접속할 인스턴스의 사설 IP(Private IP)를 확인해야 합니다.

**[Step 1] 인스턴스 목록 및 IP 확인**
```powershell
# VMSS 인스턴스 목록 확인
az vmss list-instances --resource-group $RG_NAME --name my-vmss `
  --query "[].{Name:name, InstanceId:instanceId, ProvisioningState:provisioningState}" `
  --output table

# VMSS NIC IP 주소 확인
az vmss nic list --resource-group $RG_NAME --vmss-name my-vmss `
  --query "[].ipConfigurations[0].{Instance:id, PrivateIP:privateIpAddress}" `
  --output table
```

*출력 예시:*
```text
Instance                                                                                                           PrivateIP
--------------------------------------------------------------------------------------------------------------     -------------
.../my-vmss/virtualMachines/8/networkInterfaces/vmss-nic/ipConfigurations/internal                                192.168.1.4
.../my-vmss/virtualMachines/16/networkInterfaces/vmss-nic/ipConfigurations/internal                               192.168.1.5
```

> **참고**: IP가 표시되지 않는 경우, VMSS 인스턴스가 완전히 프로비저닝되지 않았거나 Health Probe 실패로 인해 Load Balancer 백엔드 풀에서 제외되었을 수 있습니다. 다음 명령으로 Health Probe 상태를 확인하세요:
> ```powershell
> az network lb show --resource-group $RG_NAME --name www-lb `
>   --query "probes[].{Name:name, Port:port, Protocol:protocol, Path:requestPath}" `
>   --output table
> ```

**[Step 2] 특정 인스턴스 접속**
확인한 IP(`192.168.1.x`)로 접속합니다. (Bastion 경유)
```powershell
# ProxyJump 옵션 사용 (권장)
ssh -J www@$BASTION_IP www@192.168.1.4
```

**[Step 3] Load Balancer를 통한 SSH 접속 (NAT Pool 사용)**
Load Balancer의 NAT Pool을 사용하여 인스턴스에 직접 SSH 접속할 수도 있습니다.
```powershell
# 첫 번째 인스턴스 (포트 50001), 두 번째 인스턴스 (포트 50002)
ssh -p 50001 www@$LB_IP
```

---

## 2. 데이터베이스 접속 (Database)

DB와 Redis는 보안상 **Private Endpoint**만 허용되므로, **SSH 터널링(Port Forwarding)**을 통해 로컬 포트를 원격 서버로 연결해야 합니다.

### 2.1 MySQL 접속 (Local Port 3307 -> Remote 3306)
로컬의 3307 포트를 Bastion을 통해 MySQL 서버의 3306 포트로 연결합니다.

**[Step 1] 터널링 연결**
```bash
# 터미널 1 (연결 유지)
# 문법: ssh -L [로컬포트]:[원격주소]:[원격포트] [점프호스트]
ssh -L 3307:$(terraform output -raw out_21_mysql_fqdn):3306 bastion
```
*(참고: `terraform output` 명령어가 작동하지 않는 경로라면 FQDN을 직접 입력하세요)*

**[Step 2] 접속 (Workbench / DBeaver / CLI)**
- **Host**: `127.0.0.1`
- **Port**: `3307`
- **Username**: `www`
- **Password**: (설정한 DB 비밀번호)

### 2.2 Redis 접속 (Local Port 6380 -> Remote 6380)
Redis도 동일하게 터널링을 사용합니다.

**[Step 1] 터널링 연결**
```bash
# 터미널 1 (연결 유지)
ssh -L 6380:$(terraform output -raw out_22_redis_hostname):6380 bastion
```

**[Step 2] redis-cli 접속**
```bash
# 터미널 2
redis-cli -h 127.0.0.1 -p 6380 -a <Redis-Access-Key> --tls
```
*(주의: `--tls` 옵션 필수, 인증서 검증 문제 발생 시 `--insecure` 추가 가능)*

---

## 3. 스토리지 및 기타 리소스 관리

### 3.1 Storage Account 접속
스토리지는 보안 설정(`default_action = "Deny"`)으로 인해 공용 인터넷 접근이 차단되어 있습니다.

**방법 A: 특정 IP 허용 (일시적)**
로컬 PC의 공인 IP를 방화벽 예외에 추가합니다.
```bash
# 내 IP 확인
curl ifconfig.me

# Azure CLI로 IP 허용
az storage account network-rule add --resource-group 04-t1-www-rg --account-name <Storage-Name> --ip-address <My-Public-IP>
```
이후 **Azure Storage Explorer** 툴을 사용하여 접속합니다.

**방법 B: Bastion 내부에서 CLI 사용**
```bash
ssh bastion
az login --identity  # (Managed Identity가 할당된 경우)
az storage blob list --account-name <Storage-Name> --container-name wordpress-media
```

### 3.2 Key Vault 관리
Key Vault도 Private Endpoint 뒤에 있습니다.

**방법: Bastion 내부에서 관리**
```bash
ssh bastion
# Secret 목록 확인
az keyvault secret list --vault-name <KV-Name>
# Secret 값 읽기
az keyvault secret show --vault-name <KV-Name> --name db-password --query value
```

---

## 4. 문제 해결 (Troubleshooting)

### 4.1 Load Balancer 504 Gateway Timeout 오류

**증상**: Load Balancer IP로 접속 시 504 Gateway Timeout 에러 발생

**원인**: VMSS 인스턴스가 Load Balancer 백엔드 풀에 등록되지 않았거나, Health Probe 실패로 제외됨

**진단 명령어**:
```powershell
# 백엔드 풀 상태 확인
az network lb address-pool list --resource-group 04-t1-www-rg --lb-name www-lb `
  --query "[].{Name:name, BackendIPs:loadBalancerBackendAddresses[].ipAddress}" --output json

# VMSS 인스턴스 상태 확인
az vmss list-instances --resource-group 04-t1-www-rg --name my-vmss `
  --query "[].{Name:name, ProvisioningState:provisioningState, HealthState:healthProfile}" --output table
```

**해결 방법 1: VMSS 인스턴스 Reimage** (추천)
```powershell
# 모든 인스턴스 재이미징 (초기화 스크립트 재실행)
az vmss reimage --resource-group 04-t1-www-rg --name my-vmss --instance-ids "*"

# 재이미징 진행 상태 확인 (3-5분 소요)
az vmss list-instances --resource-group 04-t1-www-rg --name my-vmss `
  --query "[].{Name:name, State:provisioningState}" --output table

# 완료 후 백엔드 풀 재확인
az network lb address-pool list --resource-group 04-t1-www-rg --lb-name www-lb `
  --query "[].loadBalancerBackendAddresses[].ipAddress" --output tsv
```

**해결 방법 2: Terraform으로 재배포**
```powershell
# VMSS 인스턴스를 taint하여 재생성
terraform taint module.compute.azurerm_linux_virtual_machine_scale_set.vmss
terraform apply -auto-approve
```

### 4.2 터널링이 안 될 때
- 이미 해당 포트(3307 등)가 사용 중인지 확인하세요.
- `netstat -an | grep 3307` (Mac/Linux) 또는 `netstat -an | findstr 3307` (Windows)

### 4.3 Permission Denied (publickey)
- `ssh-add -l` 명령어로 키가 에이전트에 등록되어 있는지 확인하세요.
- 등록되지 않았다면: `ssh-add ~/.ssh/id_rsa_school`

### 4.4 Terraform Output 확인
모든 접속 정보는 아래 명령어로 다시 확인할 수 있습니다.
```bash
terraform output
```

---

## 5. 글로벌 서비스 확인 (Global Services)

### 5.1 Traffic Manager 동작 확인
Traffic Manager가 정상적으로 App Gateway IP를 반환하는지 확인합니다.
```bash
# Traffic Manager FQDN 조회
nslookup $(terraform output -raw traffic_manager_fqdn)

# 예상 결과: App Gateway의 Public IP가 반환되어야 함
```

### 5.2 Front Door 접속 확인
Front Door를 통해 웹 서비스에 정상적으로 접속되는지 확인합니다.
```bash
# Front Door Endpoint 확인
FRONTDOOR_HOST=$(terraform state show module.storage.azurerm_cdn_frontdoor_endpoint.www_fd_endpoint | grep host_name | awk '{print $3}' | tr -d '"')

# 접속 테스트 (HTTP 200 OK 또는 301 Redirect)
curl -I https://$FRONTDOOR_HOST
```

### 5.3 Custom Domain HTTPS 접속
Front Door Managed Certificate를 통해 `www.04www.cloud`에 HTTPS로 접속 가능합니다.

```bash
# DNS 검증 상태 확인
az afd custom-domain show --profile-name www-cdn-profile --resource-group 04-t1-www-rg --custom-domain-name www-custom-domain --query "{hostName:hostName, domainValidationState:domainValidationState}" --output table

# HTTPS 접속 테스트
curl -I https://www.04www.cloud/

# 인증서 확인
openssl s_client -connect www.04www.cloud:443 -servername www.04www.cloud
```

**참고**: 도메인 검증이 완료되지 않은 경우 (`domainValidationState: Pending`), DNS TXT 레코드가 전파되는 동안 5-15분 정도 기다린 후 재시도하세요.

---

## 6. 웹 애플리케이션 기능 테스트

### 6.1 보안 취약점 랩 접속
WAS 서버에 배포된 보안 테스트 페이지:

- **메인 대시보드**: https://www.04www.cloud/
- **SQL Injection**: https://www.04www.cloud/login.php
- **XSS (방명록)**: https://www.04www.cloud/guestbook.php
- **File Upload**: https://www.04www.cloud/upload.php
- **SSRF (IMDS)**: https://www.04www.cloud/ssrf.php
- **Command Injection**: https://www.04www.cloud/cmd.php

### 6.2 데이터 복제 모니터링
실시간 데이터 복제 상태: https://www.04www.cloud/ 하단 테이블에서 확인 가능

