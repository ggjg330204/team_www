# Azure 클라우드 인프라 프로젝트 (04-t1-www)

> **Hub-Spoke 네트워크 토폴로지 기반 3-Tier 웹 서비스 인프라**

이 프로젝트는 Azure에 **150개 이상의 리소스**를 배포하여 엔터프라이즈급 보안, 고가용성, 확장성을 갖춘 웹 서비스 인프라를 구축합니다.

---

## 🚀 팀원용 빠른 시작

### 처음 시작하시는 분

1. **이 파일 (README.md) 읽기** ← 지금 여기
2. **[documents/00_Quick_Start_for_Team.md](./documents/00_Quick_Start_for_Team.md)** 읽기
3. 역할별 가이드 따라하기

### 경험자용

```powershell
# 프로젝트 폴더로 이동
cd g:\project3\Project3,4_04_www

# Terraform 초기화 (최초 1회)
terraform init

# 배포된 리소스 확인
terraform output

# 빠른 시작 가이드 보기
terraform output quick_start_guide
```

---

## 📂 프로젝트 구조

```
Project3,4_04_www/
├── README.md                        ← 📍 지금 여기
├── 01_resource_group.tf             # 리소스 그룹
├── 02_infrastructure_modules.tf     # 모듈 호출
├── 09_domain_name_system.tf         # DNS 설정
├── 99_outputs.tf                    # Output 정의
├── terraform.tfvars                 # 변수 값 (민감정보 포함)
│
├── modules/                         # Terraform 모듈
│   ├── Hub/                        # Firewall, Bastion
│   ├── Network/                    # VNet, AppGW, LB
│   ├── Compute/                    # VMSS, VM, ACI
│   ├── Database/                   # MySQL, Redis, Cosmos
│   ├── Storage/                    # Blob, CDN, Front Door
│   ├── Security/                   # NSG, Key Vault, Sentinel
│   ├── Serverless/                 # Function App, Service Bus
│   └── ContainerRegistry/          # ACR
│
├── scripts/                        # 초기화 스크립트
│   ├── vmss_was_init.sh           # WAS VMSS 초기화
│   ├── vmss_web_init.sh           # Web VMSS 초기화
│   └── bastion_init.sh            # Bastion 초기화
│
└── documents/                      # 📚 문서
    ├── 00_Quick_Start_for_Team.md ← ⭐ 팀원용 시작 가이드
    ├── 01_Connection_Guide.md      # 접속 레퍼런스
    ├── 02_Architecture_Summary.md  # 아키텍처 개요
    └── 03_Service_Significance...  # 리소스 상세 설명
```

---

## 🎯 팀 역할별 시작 가이드

### 👷 아키텍처 검증 담당자
**목표**: 인프라가 설계대로 배포되었는지 확인

**시작 문서**: [00_Quick_Start → 아키텍처 검증 섹션](./documents/00_Quick_Start_for_Team.md#-아키텍처-검증-담당자)

**주요 작업**:
- Azure Portal에서 리소스 그룹 확인
- VMSS 인스턴스 상태 확인
- 네트워크 토폴로지 검증

---

### 🔒 데이터 보안 담당자
**목표**: MySQL, Redis, Key Vault 등 데이터 보안 검증

**시작 문서**: [00_Quick_Start → 데이터 보안 섹션](./documents/00_Quick_Start_for_Team.md#-데이터-보안-담당자)

**주요 작업**:
- Private Endpoint 확인
- Key Vault 액세스 정책 검증
- MySQL 내부 접속 테스트

---

### 🛡️ 앱 보안 담당자
**목표**: WAF, NSG, 보안 규칙 검증

**시작 문서**: [00_Quick_Start → 앱 보안 섹션](./documents/00_Quick_Start_for_Team.md#-앱-보안-담당자)

**주요 작업**:
- Application Gateway WAF 확인
- Front Door WAF 상태 확인
- 보안 취약점 테스트 (SQL Injection, XSS 등)

---

### 🚨 외부 침입 탐지 담당자
**목표**: Microsoft Sentinel, Firewall 로그 분석

**시작 문서**: [00_Quick_Start → 침입 탐지 섹션](./documents/00_Quick_Start_for_Team.md#-외부-침입-탐지-담당자)

**주요 작업**:
- Log Analytics 쿼리 실행
- Sentinel 인시던트 확인
- 실시간 위협 모니터링

---

## 🔐 주요 접속 정보

### 웹 서비스
- **메인 (Front Door + WAF)**: https://www.04www.cloud/
- **직접 (Load Balancer)**: http://04www.cloud/
- **Traffic Manager**: http://www-tm.trafficmanager.net/

### Azure Portal
- **Portal**: https://portal.azure.com
- **리소스 그룹**: `04-t1-www-rg`
- **구독 ID**: `99b79efe-ebd6-468c-b39f-5669acb259e1`

### SSH 접속 (Bastion 사용)

**❗ 중요: Jumpbox VM이 아니라 Bastion Host를 사용합니다!**

**방법 1 (추천)**: Azure Portal
1. Azure Portal → VMSS → 인스턴스 선택
2. "연결" → "Bastion" 클릭
3. 브라우저에서 바로 접속

**방법 2**: Azure CLI
```powershell
# Bastion 터널 생성
terraform output ssh_connection_guide
```

상세 가이드: [00_Quick_Start → Bastion 접속 방법](./documents/00_Quick_Start_for_Team.md#-bastion-host-접속-방법-중요)

---

## 📊 주요 리소스 통계

- **리소스 타입**: 78개 이상
- **리소스 인스턴스**: 150개 이상
- **Terraform 관리 리소스**: 130개 이상

### 핵심 리소스
- **Compute**: VMSS 2개 (web, was), VM 1개
- **Network**: Hub-Spoke VNet, App Gateway, Load Balancer, Front Door
- **Database**: MySQL, Redis, CosmosDB
- **Security**: WAF, Azure Firewall, NSG, Key Vault, Sentinel
- **Storage**: Blob Storage, ACR, File Share

---

## 🛠️ 필수 도구

### 로컬 PC에 설치 필요
- **Azure CLI**: https://docs.microsoft.com/cli/azure/install-azure-cli
- **Terraform**: https://www.terraform.io/downloads
- **SSH Client**: Windows Terminal 또는 PuTTY

### 확인 방법
```powershell
az --version
terraform --version
```

---

## 📚 문서 가이드

| 문서 | 대상 | 목적 |
|:---|:---|:---|
| [00_Quick_Start_for_Team.md](./documents/00_Quick_Start_for_Team.md) | ⭐ **모든 팀원** | 역할별 시작 가이드 |
| [01_Connection_Guide.md](./documents/01_Connection_Guide.md) | 경험자 | 상세 접속 레퍼런스 |
| [02_Architecture_Summary.md](./documents/02_Architecture_Summary.md) | 아키텍처 담당자 | 전체 구조 및 다이어그램 |
| [03_Service_Significance...](./documents/03_Service_Significance_and_Configuration.md) | 기술 담당자 | 리소스별 기술 상세 |

---

## ⚠️ 주의사항

### 보안
- **terraform.tfvars**: DB 비밀번호 등 민감정보 포함 → Git에 절대 커밋 금지
- **Private Endpoint**: MySQL, Redis는 내부망에서만 접속 가능
- **SSH 키**: `~/.ssh/` 폴더 안전하게 관리

### Bastion vs Jumpbox
- ✅ **현재 사용**: Bastion Host (PaaS, 더 안전)
- ❌ **사용 안 함**: Jumpbox VM

Bastion은 VM이 아니므로 **Public IP나 SSH 포트가 노출되지 않습니다.**

---

## 🆘 문제 해결

### "terraform output이 안 나와요"
```powershell
terraform init
terraform refresh
```

### "Bastion 접속이 안 돼요"
- Azure Portal 방법 사용 (더 쉬움)
- IAM 권한 확인 필요
- 상세: [00_Quick_Start FAQ](./documents/00_Quick_Start_for_Team.md#-문제-해결-faq)

### "MySQL 접속이 안 돼요"
- Private Endpoint만 허용 → **Bastion으로 VMSS에 먼저 접속** 후 내부에서 MySQL 접속

---

## 📞 문의

**프로젝트 리더**에게 문의하시거나, 관련 문서를 먼저 확인해 주세요.

**빠른 도움말**: [00_Quick_Start_for_Team.md](./documents/00_Quick_Start_for_Team.md)

---

**최초 작성**: 2025-12-01  
**최종 업데이트**: 2025-12-03  
**관리자**: 프로젝트 팀
