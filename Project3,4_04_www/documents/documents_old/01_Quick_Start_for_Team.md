# 🚀 팀원용 빠른 시작 가이드

> **이 문서를 꼭 먼저 읽으세요!** Terraform outputs가 처음이거나 Bastion Host 접속이 처음이라면 이 가이드를 따라하세요.

---

## 📋 사전 준비

### 1. 필수 도구 설치 확인
```powershell
# Azure CLI 설치 확인
az --version

# Terraform 설치 확인
terraform --version
```

### 2. Azure 로그인
```powershell
az login
```

### 3. Outputs 확인
```powershell
# 프로젝트 폴더로 이동
cd g:\project3\Project3,4_04_www

# 전체 output 보기
terraform output

# 특정 output만 보기 (추천)
terraform output quick_start_guide
```

---

## 🎯 역할별 가이드

### 👷 **아키텍처 검증 담당자**

**목표**: 인프라가 설계대로 배포되었는지 확인

**1단계: 리소스 그룹 확인**
```powershell
terraform output resource_group
# 출력 예시: 04-t1-www-rg
```

**2단계: Azure Portal에서 확인**
- Portal: https://portal.azure.com
- 검색창에 `04-t1-www-rg` 입력
- **확인 항목**:
  - ✅ VMSS 2개 (web-vmss, was-vmss)
  - ✅ Load Balancer
  - ✅ Application Gateway
  - ✅ MySQL Server
  - ✅ Front Door

**3단계: 네트워크 토폴로지 확인**
- Azure Portal → 리소스 그룹 → `04-t1-www-rg`
- 왼쪽 메뉴 → **설정** → **다이어그램**
- Hub-Spoke 구조 확인

**4단계: VMSS 인스턴스 상태 확인**
```powershell
# Web VMSS 확인
az vmss list-instances --name web-vmss --resource-group 04-t1-www-rg --output table

# WAS VMSS 확인
az vmss list-instances --name was-vmss --resource-group 04-t1-www-rg --output table
```

---

### 🔒 **데이터 보안 담당자**

**목표**: MySQL, Redis, Key Vault 등 데이터 보안 검증

**1단계: Private Endpoint 확인**
- Azure Portal → MySQL Server → **네트워킹**
- **공용 액세스**: `사용 안 함` 확인 ✅
- **Private Endpoint**: 존재 여부 확인

**2단계: Key Vault 접근 정책 확인**
```powershell
# Key Vault 이름 가져오기
terraform output key_vault_name

# Azure Portal에서 확인
```
- Azure Portal → Key Vault → **액세스 정책**
- **네트워킹** → Private Endpoint 확인

**3단계: MySQL 접속 테스트 (내부에서만 가능)**

**❗ 중요**: MySQL은 Private Endpoint로만 접속 가능하므로 **VMSS 내부에서** 테스트해야 합니다.

```powershell
# [먼저] Bastion으로 VMSS 접속 (아래 "Bastion 접속 방법" 참조)

# [VMSS 내부에서] MySQL 접속
mysql -h www-mysql-server-1zhm.mysql.database.azure.com -u www -p
# 비밀번호: terraform.tfvars 파일의 db_password 값
```

**4단계: 감사 로그 확인**
- Azure Portal → MySQL Server → **서버 매개 변수**
- `audit_log_enabled` = `ON` 확인

---

### 🛡️ **앱 보안 담당자**

**목표**: WAF, NSG, 보안 규칙 검증

**1단계: Application Gateway WAF 확인**
- Azure Portal → Application Gateway → **Web Application Firewall**
- **모드**: `Prevention` (차단 모드) 확인
- **규칙 집합**: `OWASP 3.2`

**2단계: Front Door WAF 확인**
- Azure Portal → Front Door → **WAF 정책**
- **상태**: `사용`
- **모드**: `Prevention`

**3단계: 보안 취약점 테스트**

웹 애플리케이션에 접속하여 각 취약점 페이지 테스트:

```
기본 URL: https://www.04www.cloud/

보안 랩 페이지:
- SQL Injection: /login.php
- XSS: /guestbook.php
- File Upload: /upload.php
- SSRF: /ssrf.php
- Command Injection: /cmd.php
```

**WAF 탐지 여부**: 메인 페이지 상단에서 확인 가능

**4단계: NSG 규칙 확인**
```powershell
# NSG 목록 조회
az network nsg list --resource-group 04-t1-www-rg --query "[].{Name:name, Location:location}" --output table

# 특정 NSG 규칙 확인
az network nsg rule list --resource-group 04-t1-www-rg --nsg-name www-web-nsg --output table
```

---

### 🚨 **외부 침입 탐지 담당자**

**목표**: Microsoft Sentinel, Firewall 로그 분석

**1단계: Log Analytics Workspace 접속**
```powershell
# Workspace ID 가져오기
terraform output log_analytics_workspace_id
```

- Azure Portal → Log Analytics Workspace
- 왼쪽 메뉴 → **로그**

**2단계: 주요 쿼리**

**Azure Firewall 로그 조회**:
```kql
AzureDiagnostics
| where ResourceType contains "FIREWALL"
| where TimeGenerated > ago(1h)
| project TimeGenerated, msg_s, Protocol, SourceIP, DestinationIP
| take 100
```

**SSH 로그인 시도 조회**:
```kql
Syslog
| where Facility == "auth"
| where SyslogMessage contains "Failed password"
| summarize FailedAttempts = count() by Computer, SourceIP = extract(@"from ([\d\.]+)", 1, SyslogMessage)
| where FailedAttempts > 5
```

**3단계: Microsoft Sentinel 접속**
- Azure Portal → 검색창에 `Sentinel` 입력
- **Workspace 선택**
- **위협 탐지** → **인시던트**

**4단계: 실시간 모니터링**
- Sentinel → **대시보드** → **Overview**
- **경고** 및 **이벤트** 확인

---

## 🔑 Bastion Host 접속 방법 (중요!)

> **❗ Jumpbox VM과 다른 점**: Bastion은 VM이 아니라 **PaaS 서비스**입니다. SSH 키나 Public IP가 필요 없습니다!

### 방법 1: Azure Portal (가장 쉬움, 추천!)

**단계별 가이드**:

1. **Azure Portal 접속**: https://portal.azure.com
2. **리소스 그룹** → `04-t1-www-rg` 선택
3. **VMSS 선택**: `web-vmss` 또는 `was-vmss`
4. **인스턴스** 탭 클릭
5. 접속하려는 **인스턴스** 선택 (예: `web-vmss_0`)
6. 상단 메뉴에서 **연결** 클릭 → **Bastion** 선택
7. 사용자 이름/비밀번호또는 SSH 키 입력:
   - **사용자 이름**: `www`
   - **인증 방법**: SSH 개인 키 파일 업로드
8. **연결** 버튼 클릭
9. 브라우저에서 **새 탭**으로 SSH 세션 열림 🎉

**장점**:
- ✅ SSH 클라이언트 불필요
- ✅ 방화벽 설정 불필요
- ✅ 브라우저에서 바로 접속

---

### 방법 2: Azure CLI (터미널에서 접속)

**준비물**: Azure CLI 설치 필요

**1단계: VMSS 인스턴스 ID 확인**
```powershell
az vmss list-instances --name was-vmss --resource-group 04-t1-www-rg --query "[].{Name:name, ID:id}" --output table
```

**출력 예시**:
```
Name         ID
-----------  ---------------------------------------------------------------------------------
was-vmss_0   /subscriptions/.../virtualMachines/0
```

**2단계: Bastion 터널 생성**

**PowerShell 터미널 1**에서 실행 (이 터미널은 계속 열어두기):
```powershell
# 인스턴스 ID 복사
$vmId = "/subscriptions/99b79efe-ebd6-468c-b39f-5669acb259e1/resourceGroups/04-t1-www-rg/providers/Microsoft.Compute/virtualMachineScaleSets/was-vmss/virtualMachines/0"

# Bastion 터널 생성
az network bastion tunnel --name www-bastion --resource-group 04-t1-www-rg --target-resource-id $vmId --resource-port 22 --port 50022
```

**메시지**: `Tunnel is ready, connect on port 50022` 나오면 성공!

**3단계: SSH 접속**

**새로운 PowerShell 터미널 2**를 열어서:
```powershell
ssh -p 50022 www@localhost
```

**비밀번호 또는 SSH 키 입력**

---

### 🆚 Jumpbox VM vs Bastion Host 비교

| 구분 | Jumpbox VM | Bastion Host (현재) |
|:---:|:---|:---|
| **타입** | IaaS (VM) | PaaS (관리형 서비스) |
| **Public IP** | 필요 ✅ | 불필요 ❌ |
| **SSH 포트 노출** | 22번 포트 노출 (보안 위험) | 포트 노출 없음 (안전) |
| **패치/업데이트** | 직접 관리 필요 | Azure가 자동 관리 |
| **접속 방법** | `ssh user@public-ip` | Azure Portal 또는 `az network bastion tunnel` |
| **비용** | VM 비용 (24시간) | 사용 시간만큼만 과금 |
| **보안** | NSG로 IP 제한 필요 | Azure AD 인증 (더 안전) |

---

## 📂 Azure Portal 주요 관리 포인트

### 1. **리소스 그룹 대시보드**
- URL: https://portal.azure.com/#@/resource/subscriptions/.../resourceGroups/04-t1-www-rg
- **용도**: 전체 리소스 한눈에 보기

### 2. **Key Vault (비밀 관리)**
- Azure Portal → Key Vault → `www-kv-xxxxxxxx`
- **용도**: DB 비밀번호, 인증서 확인

### 3. **Log Analytics (로그 분석)**
- Azure Portal → Log Analytics Workspace → `www-law`
- **용도**: 모든 리소스의 로그 통합 조회

### 4. **Microsoft Sentinel (보안 관제)**
- Azure Portal → Microsoft Sentinel
- **용도**: 위협 탐지, 인시던트 대응

### 5. **Application Insights (APM)**
- Azure Portal → Application Insights
- **용도**: 애플리케이션 성능 모니터링

### 6. **Cost Management (비용 관리)**
- Azure Portal → Cost Management → 비용 분석
- **용도**: 리소스별 비용 확인

---

## 🆘 문제 해결 (FAQ)

### Q1: `terraform output` 실행 시 "No outputs found" 오류
**해결**: 
```powershell
terraform init
terraform refresh
```

### Q2: Bastion 접속 시 "권한이 없습니다" 오류
**해결**: Azure Portal에서 역할 확인
- 리소스 그룹 → **액세스 제어 (IAM)**
- 본인 계정에 `Virtual Machine Contributor` 역할 있는지 확인

### Q3: MySQL 접속 안 됨
**원인**: MySQL은 Private Endpoint만 허용
**해결**: Bastion으로 VMSS에 먼저 접속 후 내부에서 MySQL 접속

### Q4: WAF가 "미탐지"로 표시됨
**원인**: `04www.cloud` (Root)로 접속하면 Load Balancer로 직접 연결
**해결**: **`www.04www.cloud`**로 접속 (Front Door 경유)

---

## 📚 추가 참고 문서

- **상세 접속 가이드**: `./documents/01_Connection_Guide.md`
- **아키텍처 전체 구조**: `./documents/02_Architecture_Summary.md`
- **리소스별 기술 상세**: `./documents/03_Service_Significance_and_Configuration.md`

---

## ✅ 체크리스트

**첫 접속 시 확인사항**:
- [ ] `terraform output` 실행 성공
- [ ] Azure Portal 로그인 성공
- [ ] Bastion으로 VMSS 접속 성공
- [ ] 웹 서비스 접속 확인 (`https://www.04www.cloud`)
- [ ] 역할별 가이드 확인 완료

**문제 발생 시**: 팀 리더에게 이 문서와 함께 에러 메시지 전달

---

**작성일**: 2025-12-03  
**버전**: 1.0  
**문의**: 프로젝트 리더
