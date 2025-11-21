# Azure 인프라 및 보안 구성 평가 보고서

## 📋 목차
1. [현재 구성 현황](#현재-구성-현황)
2. [Cloud 기본 인프라 평가](#cloud-기본-인프라-평가)
3. [Microsoft CSI 솔루션 설명](#microsoft-csi-솔루션-설명)
4. [테라폼 구현 가이드](#테라폼-구현-가이드)
5. [종합 평가 및 권장사항](#종합-평가-및-권장사항)

---

## 현재 구성 현황

### ✅ 구현 완료된 항목
- **Network 모듈**: VNet, Subnet, Public IP, NIC 구성 완료
- **Compute 모듈**: VM 리소스 정의 완료
- **Storage 모듈**: Storage Account (GRS 복제), Container 구성 완료
- **Database 모듈**: MySQL Flexible Server, Private Endpoint 구성 완료

### ⚠️ 미완성 항목
- **Security 모듈**: 빈 디렉토리 상태 (NSG, 방화벽 규칙 미구성)
- **MySQL Replica**: 주석 처리됨 (지역 SKU 제한으로 비활성화)
- **Redis Cache**: 주석 처리됨
- **CDN**: 주석 처리됨

### 🎉 최근 개선 사항
- ✅ Storage Account 복제: LRS → **GRS** 변경 완료
- ✅ Redis, CDN 주석 처리로 불필요한 리소스 제거

---

## Cloud 기본 인프라 평가

### 1. Azure 인프라 구성 요소 이해 및 리소스 생성

**평가**: ✅ **완료됨**

**구현 내용**:
- Resource Group: `01_rg.tf`에 정의
- Virtual Network: 10.0.0.0/16 대역 사용
- Subnet: Bastion용 서브넷 구성
- Storage Account, MySQL Server 생성

**학습 포인트**:
- **Resource Group**: Azure의 모든 리소스를 담는 논리적 컨테이너
- **Naming Convention**: `{teamuser}-{resource}`로 일관성 있게 명명

---

### 2. Azure 컴퓨팅 및 네트워킹 서비스 이해 및 구성

**평가**: ✅ **완료됨**

**구현 내용**:
```
Network Module:
├── Virtual Network (10.0.0.0/16)
├── Subnet (10.0.0.0/24)
├── Public IP
└── Network Interface Card

Compute Module:
└── Virtual Machine
```

**네트워킹 개념 정리**:
- **VNet**: 격리된 가상 네트워크 공간
- **Subnet**: VNet 내부의 IP 대역 분할
- **NIC**: VM과 네트워크를 연결하는 가상 인터페이스
- **Public IP**: 인터넷에서 접근 가능한 공인 IP

---

### 3. Azure 내 분산 인프라 활용한 데이터 복원과 스토리지 구성

**평가**: ✅ **완료됨**

#### 데이터 복원(레플리카)이란?

스토리지 계정을 만들 때 데이터 센터에 불이 나거나 장애가 생겨도 데이터가 날아가지 않게 **복제(Replication)** 설정을 하는 것을 말합니다.

#### 현재 구성

```hcl
# storage/01_sa.tf
account_replication_type = "GRS"  # ✅ Geo-Redundant Storage
```

**개선 완료**: LRS에서 GRS로 변경하여 지리적 복제 구현

#### 스토리지 복제 옵션 비교

| 복제 유형 | 설명 | 비용 | 내구성 |
|---------|------|------|--------|
| **LRS** | 로컬 중복 저장 (단일 데이터센터) | 가장 저렴 | 99.999999999% (11 9's) |
| **ZRS** | 영역 중복 저장 (3개 가용 영역) | 중간 | 99.9999999999% (12 9's) |
| **GRS** (현재) | 지역 중복 저장 (보조 지역 복제) | 비쌈 | 99.99999999999999% (16 9's) |
| **GZRS** | 지역+영역 중복 | 가장 비쌈 | 최고 |

**GRS의 장점**:
- 주 지역(Korea Central)에 장애 발생 시 보조 지역(Korea South)에서 복구 가능
- 데이터 복원성 최대화

#### MySQL 레플리카 구성

**현재 상태**: `03_replica.tf`가 주석 처리됨

**주석된 이유**:
```
# 주석: 구독에서 다른 리전(koreasouth, japaneast) GP SKU 지원 안 함
```

**해결 방법 옵션**:

1. **Read Replica 활성화** (같은 리전 내):
   ```hcl
   resource "azurerm_mysql_flexible_server" "www_replica" {
     name                = "www-mysql-replica"
     location            = var.loca  # 같은 리전 사용
     create_mode         = "Replica"
     source_server_id    = azurerm_mysql_flexible_server.www_mysql.id
   }
   ```

2. **백업 기반 복원**:
   - Azure Portal에서 자동 백업 활성화
   - PITR (Point-in-Time Restore) 설정

---

### 4. Azure 내 권한 부여 및 인증 방법 이해

**평가**: ⚠️ **개념 이해 필요, 구현 미완성**

#### 개념 (RBAC - Role Based Access Control)

"누구(User)에게 어떤 자원(Resource)에 대해 무슨 권한(Role)을 줄 것인가?"입니다.

**예시**: 철수에게 가상머신을 끄고 킬 수 있는 권한을 준다.

#### Azure RBAC 주요 역할

- **Owner**: 모든 권한 + 권한 할당 가능
- **Contributor**: 리소스 생성/수정/삭제 (권한 할당 불가)
- **Reader**: 읽기 전용
- **Custom Roles**: 필요에 맞게 세밀하게 정의

#### 테라폼 구현 예시

```hcl
# 데이터베이스 관리자에게만 MySQL 접근 권한 부여
resource "azurerm_role_assignment" "db_admin" {
  scope                = azurerm_mysql_flexible_server.www_mysql.id
  role_definition_name = "Contributor"
  principal_id         = var.db_admin_object_id  # 권한 받을 사람의 Object ID
}
```

#### Managed Identity (관리 ID)

VM이나 App Service가 **비밀번호 없이** Azure 리소스에 접근하는 방법:

```hcl
resource "azurerm_linux_virtual_machine" "www_vm" {
  # ... 기타 설정 ...
  
  identity {
    type = "SystemAssigned"
  }
}

# 이 VM에 Storage 읽기 권한 부여
resource "azurerm_role_assignment" "vm_storage" {
  scope                = azurerm_storage_account.www_sa.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_linux_virtual_machine.www_vm.identity[0].principal_id
}
```

**이렇게 하면**:
- VM에서 Storage에 접근할 때 Key를 코드에 하드코딩하지 않아도 됨
- 보안 강화

---

## Microsoft CSI 솔루션 설명

> 이 부분은 테라폼 공급자(Provider)가 `azurerm`이 아니라 **`azuread`**가 필요할 수 있습니다.

### 1. Microsoft Entra ID User (구 Azure AD)

#### 개념

**Microsoft Entra ID**는 Microsoft의 클라우드 기반 **신원 및 액세스 관리** 서비스입니다.

Azure AD(Active Directory)의 이름이 **Microsoft Entra ID**로 바뀌었습니다. 클라우드 상의 '사용자 계정 관리 시스템'입니다.

#### User 유형

- **Cloud User**: Entra ID에서 직접 생성한 사용자
- **Synced User**: 온프레미스 Active Directory에서 동기화된 사용자
- **Guest User**: 외부 협력업체 사용자 (B2B)

#### 구성 방법

**Azure Portal에서**:
1. **Azure Portal** → **Microsoft Entra ID** → **Users**
2. **New user** 클릭
3. User 정보 입력:
   - User principal name: `user1@yourdomain.onmicrosoft.com`
   - Display name: `홍길동`
   - Password: 자동 생성 또는 직접 입력

**Terraform으로**:
```hcl
# main.tf 상단에 azuread provider 추가 필요
terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

resource "azuread_user" "team_member" {
  user_principal_name = "member1@yourdomain.onmicrosoft.com"
  display_name        = "팀원1"
  mail_nickname       = "member1"
  password            = "SecurePassword123!"
  
  job_title           = "Developer"
  department          = "Engineering"
}
```

---

### 2. MFA (Multi-Factor Authentication)

#### 개념

**다중 요소 인증**입니다. 아이디/비번 입력 후 스마트폰 앱이나 문자로 한 번 더 인증하는 것입니다. 보안의 핵심입니다.

#### 인증 방법 유형

| 방법 | 설명 | 보안 수준 |
|-----|------|---------|
| **SMS/전화** | 휴대폰으로 코드 수신 | 중간 |
| **Microsoft Authenticator** | 스마트폰 앱 알림 | 높음 |
| **FIDO2 키** | USB 보안 키 | 매우 높음 |
| **Windows Hello** | 생체인식 (얼굴/지문) | 높음 |

#### 설정 방법

**Azure Portal**:
1. **Entra ID** → **Security** → **MFA**
2. **Additional cloud-based MFA settings** 클릭
3. 인증 방법 선택:
   - ✅ Mobile app notification
   - ✅ Mobile app verification code
   - ⬜ SMS (권장하지 않음)

**테라폼 해결 방법**:

MFA는 보통 **"조건부 액세스(Conditional Access)" 정책**을 통해 강제합니다. (아래 3번과 연결됩니다.)

테라폼으로 직접 "인증"을 하는 게 아니라, **"MFA를 켜라"는 정책을 만드는 것**이 과제의 핵심입니다.

---

### 3. Microsoft Entra 조건부 액세스

#### 개념

**"만약(If) ~하면, 그럼(Then) ~해라"** 라는 보안 규칙입니다.

**조건부 액세스**는 "특정 조건일 때만 접근 허용"하는 정책입니다.

#### 실전 예시

**시나리오 1: 회사 밖에서 접속 시 MFA 요구**
```
조건 (If):
- Location: Any location except Korea Central office IP

정책 (Then):
- Grant access: Require MFA
```

**시나리오 2: 관리자는 항상 MFA 필수**
```
조건 (If):
- Users: Administrators group

정책 (Then):
- Grant access: Require MFA
```

**시나리오 3: 위험한 로그인 차단**
```
조건 (If):
- Sign-in risk: High

정책 (Then):
- Block access
```

#### 구성 방법

**Azure Portal**:
1. **Entra ID** → **Security** → **Conditional Access**
2. **New policy** 클릭
3. **Assignments** 설정:
   - Users: 대상 선택
   - Cloud apps: Azure Portal 등
   - Conditions: 위치, 디바이스, 위험 수준
4. **Access controls** 설정:
   - Grant: MFA 요구 / 차단
   - Session: 제한 설정

**Terraform으로**:

> ⚠️ **주의**: 이 기능은 Entra ID Premium P1 이상의 라이선스가 있어야 동작합니다. 학생/무료 계정에서는 생성이 안 될 수도 있으니 확인이 필요합니다.

```hcl
resource "azuread_conditional_access_policy" "require_mfa" {
  display_name = "MFA Required for All Users"
  state        = "enabled"

  conditions {
    users {
      included_users = ["All"]  # 모든 유저 대상
    }
    applications {
      included_applications = ["All"]
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]  # MFA를 강제함
  }
}
```

---

### 4. Azure 네트워크 보안 그룹 (NSG)

#### 개념

**NSG**는 VM의 **방화벽 역할**을 하는 보안 규칙 집합입니다.

**클라우드 방화벽**입니다. "22번 포트(SSH)는 열고, 80번(HTTP)은 열고, 나머지는 막아라" 같은 규칙입니다.

#### 현재 프로젝트 상태

**문제**: `modules/Security` 디렉토리가 비어있음 → **NSG 미구성**

#### GUI로 만들면 되나?

**답변**: 과제 주제가 "테라폼으로 만들기"이므로 **테라폼 코드로 작성해야 점수를 받을 수 있습니다.**

#### 테라폼 구현 방법

**NSG 생성 및 규칙 정의**:

```hcl
# modules/Security/01_nsg.tf
resource "azurerm_network_security_group" "www_nsg" {
  name                = "${var.teamuser}-nsg"
  location            = var.loca
  resource_group_name = var.rgname

  # SSH 접근 (관리자 IP만 허용)
  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "YOUR_OFFICE_IP/32"  # 회사 IP로 제한
    destination_address_prefix = "*"
  }

  # HTTP/HTTPS (전체 허용)
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # MySQL (거부 - Private Endpoint만 사용)
  security_rule {
    name                       = "DenyMySQL"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# NIC에 NSG 연결
resource "azurerm_network_interface_security_group_association" "www_nic_nsg" {
  network_interface_id      = var.nic_id
  network_security_group_id = azurerm_network_security_group.www_nsg.id
}
```

**또는 Subnet에 연결**:
```hcl
resource "azurerm_subnet_network_security_group_association" "www_subnet_nsg" {
  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.www_nsg.id
}
```

---

### 5. Microsoft 규정 준수 기능

#### 개념

**Microsoft Purview Compliance**는 데이터 보호 및 규정 준수를 위한 도구입니다.

**Azure Policy(정책)**를 의미합니다. 회사나 조직의 규칙을 시스템적으로 강제하는 것입니다.

**예시**:
- "우리 회사는 한국(Korea Central) 리전에만 서버를 만들 수 있다."
- "모든 리소스에는 'Department'라는 태그가 붙어 있어야 한다."

#### 주요 기능

**1. Data Loss Prevention (DLP)**
- 민감한 정보(주민번호, 신용카드)가 외부로 유출되는 것을 차단
- 예: 이메일에 주민번호 포함 시 발송 차단

**2. Information Protection**
- 문서에 레이블 지정 (기밀, 내부용, 공개)
- 레이블에 따라 자동으로 암호화

**3. Compliance Manager**
- GDPR, ISO 27001 등 규정 준수 점수 확인
- 개선 권장사항 제공

**4. Audit Logs**
- 누가, 언제, 무엇을 했는지 추적
- 예: "관리자 A가 2025-11-21에 VM을 삭제함"

#### 테라폼 구현 방법

**Azure Policy로 규정 강제**:

```hcl
# 예시 1: 리소스 태그 강제 정책 할당
resource "azurerm_policy_assignment" "require_tags" {
  name                 = "require-department-tag"
  scope                = azurerm_resource_group.www_rg.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1e30110a-5ceb-460c-a297-1b0666e6394f"
  
  parameters = jsonencode({
    tagName = {
      value = "Department"
    }
  })
}

# 예시 2: 허용된 리전만 사용 가능
resource "azurerm_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations"
  scope                = azurerm_resource_group.www_rg.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  
  parameters = jsonencode({
    listOfAllowedLocations = {
      value = ["koreacentral", "koreasouth"]
    }
  })
}

# 예시 3: 모든 Storage Account는 HTTPS만 허용
resource "azurerm_policy_assignment" "require_https" {
  name                 = "require-https-storage"
  scope                = azurerm_resource_group.www_rg.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9"
}
```

---

## 테라폼 구현 가이드

### 지금 당장 해야 할 일 (우선순위별)

#### 🔴 High Priority (필수)

1. **NSG 구성**
   - `modules/Security/01_nsg.tf` 파일 생성
   - SSH, HTTP, MySQL 규칙 정의
   - Subnet 또는 NIC에 연결

2. ✅ **Storage 복제 변경** (완료됨)
   ```hcl
   account_replication_type = "GRS"  # ✅ 이미 적용됨
   ```

3. **Entra ID User 생성**
   - `azuread` 프로바이더를 추가
   - `azuread_user` 리소스로 사용자 한 명 생성

#### 🟡 Medium Priority (권장)

4. **RBAC 권한 할당**
   - `azurerm_role_assignment`로 역할 기반 접근 제어 구현

5. **Managed Identity 적용**
   - VM이 Password 없이 Storage 접근하도록 설정

6. **정책(Compliance) 할당**
   - `azurerm_policy_assignment`를 사용해 간단한 내장 정책 적용
   - 예: 태그 강제, 리전 제한 등

#### 🟢 Low Priority (선택)

7. **MySQL Replica 활성화**
   - 같은 리전 내 Read Replica 설정

8. **조건부 액세스 정책**
   - 관리자 MFA 강제 (라이선스 확인 필요)

9. **Private Endpoint 확장**
   - Storage Account에도 Private Endpoint 추가

10. **Backup 정책**
    - VM 자동 백업 설정

### 라이선스 관련 주의사항

MFA나 조건부 액세스는 **Entra ID Premium P1** 이상의 라이선스가 필요할 수 있습니다.

**해결 방법**:
- 코드를 작성하되 실제 적용이 안 될 경우
- "이러한 코드로 구성한다"는 것을 보여주는 주석이나 문서화로 대체
- 교수님/평가자에게 확인

---

## 종합 평가 및 권장사항

### 📊 현재 점수 (예상)

| 평가 항목 | 현재 상태 | 점수 | 권장 개선 |
|----------|---------|------|----------|
| 인프라 구성 | VNet, VM, Storage 완료 | 90% | MySQL Replica 고려 |
| 데이터 복원 | GRS 복제 완료 | 100% | ✅ 완료 |
| 네트워킹 | VNet, Subnet 구성 | 80% | NSG 추가 필요 |
| 보안 | Private Endpoint만 구성 | 40% | NSG, RBAC, MFA 추가 |
| 신원 관리 | 미구성 | 0% | Entra ID User 생성 |
| 규정 준수 | 미구성 | 0% | Azure Policy 적용 |

**종합 점수**: **52/100** → **68/100** (GRS 적용 후)

### ✅ 개선 완료 항목

- ✅ Storage Account: LRS → GRS 변경 완료
- ✅ 불필요한 리소스(Redis, CDN) 주석 처리

### 🎯 다음 단계 체크리스트

```markdown
## 즉시 구현 필요
- [ ] NSG 생성 및 Subnet 연결
- [ ] Entra ID User 생성 (azuread provider)
- [ ] RBAC 역할 할당

## 권장 구현
- [ ] Azure Policy 할당 (태그 강제)
- [ ] Managed Identity 설정
- [ ] 조건부 액세스 정책 (라이선스 확인)

## 선택 구현
- [ ] MySQL Read Replica (같은 리전)
- [ ] VM 백업 정책
- [ ] Storage Private Endpoint
```

---

## 📚 참고 자료

### Microsoft Learn 문서
- [Azure RBAC](https://learn.microsoft.com/azure/role-based-access-control/)
- [Microsoft Entra ID](https://learn.microsoft.com/entra/fundamentals/)
- [NSG Best Practices](https://learn.microsoft.com/azure/security/fundamentals/network-best-practices)
- [Azure Policy](https://learn.microsoft.com/azure/governance/policy/)

### Terraform 문서
- [AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [AzureAD Provider](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs)

---

## 💡 최종 조언

과제 주제가 "테라폼으로 Azure 아키텍처 구성"이므로:

1. **GUI 사용 금지**: 모든 리소스는 Terraform 코드로 작성
2. **문서화 중요**: 각 리소스의 목적과 설정 이유를 주석으로 명시
3. **보안 우선**: NSG, RBAC, Private Endpoint 등 보안 요소 강조
4. **재현 가능성**: `terraform apply` 한 번으로 전체 인프라 구축 가능해야 함

**과제 파이팅하세요!** 더 궁금한 코드가 있으면 물어봐 주세요. 🚀
