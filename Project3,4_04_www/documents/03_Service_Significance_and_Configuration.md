# [상세 보고서] Azure 클라우드 인프라 서비스 구성 및 기술적 의의

본 문서는 프로젝트에 구축된 Azure 클라우드 인프라의 모든 서비스와 리소스에 대해, 단순한 설정 나열을 넘어 **기술적 도입 배경, 아키텍처 설계의 근거, 보안 및 운영상의 이점, 그리고 상세 구성 값**을 심층적으로 기술합니다. 본 자료는 100페이지 분량의 기술 보고서 또는 아키텍처 명세서의 핵심 챕터로 활용될 수 있도록 작성되었습니다.

---

## 1. 서론: 인프라 설계 철학

본 프로젝트의 인프라 아키텍처는 다음 4가지 핵심 원칙을 기반으로 설계되었습니다.

1.  **보안 최우선 (Security First)**: 모든 데이터와 리소스는 기본적으로 격리되며, 명시적인 허용 규칙에 의해서만 접근이 가능합니다. (Zero Trust 모델 지향)
2.  **고가용성 및 탄력성 (HA & Elasticity)**: 단일 실패 지점(SPOF)을 제거하고, 트래픽 변동에 유연하게 대응할 수 있는 자동화된 확장성을 보장합니다.
3.  **관리 효율성 (Operational Excellence)**: 코드형 인프라(IaC)를 통해 모든 리소스를 관리하고, 중앙 집중화된 네트워크 및 보안 정책을 적용합니다.
4.  **비용 최적화 (Cost Optimization)**: 불필요한 리소스 낭비를 막고, 사용량에 따라 비용이 발생하는 클라우드 네이티브 모델을 채택합니다.

---

## 2. Infra as Code (IaC) 구조 및 규모

본 프로젝트는 **Terraform**을 사용하여 모든 인프라를 코드로 정의하고 관리합니다. 이를 통해 인프라의 버전 관리, 재사용성, 그리고 신속한 복구 능력을 확보했습니다.

### 2.1 Terraform Module Structure
전체 인프라는 기능별로 모듈화되어 있으며, 각 모듈은 독립적인 수명 주기를 가집니다.

```text
Project Root
├── 01_resource_group.tf       # 리소스 그룹 정의
├── 02_infrastructure_modules.tf # 모듈 호출 및 연결
├── modules/
│   ├── Hub/                   # [보안/네트워크] Firewall, Bastion, VPN
│   ├── Network/               # [서비스망] VNet, AppGateway, LB, NAT
│   ├── Compute/               # [컴퓨팅] VMSS, VM, ACI, Backup
│   ├── Database/              # [데이터] MySQL, Redis, CosmosDB
│   ├── Storage/               # [스토리지] Blob, File, CDN
│   ├── Security/              # [보안] NSG, KeyVault, Monitor
│   ├── Serverless/            # [이벤트] Function App, Service Bus
│   └── ContainerRegistry/     # [이미지] ACR
└── scripts/                   # 초기화 및 검증 스크립트
```


### 2.2 Resource Graph (상세 리소스 통계)
총 **78개 이상**의 고유한 Azure 리소스 타입이 유기적으로 연결되어 대규모 엔터프라이즈 서비스를 구성하고 있습니다. (Terraform State 기준 - 2025-12-01 검증)

> **참고**: 아래 표는 주요 리소스 유형을 정리한 것이며, 실제 배포된 리소스 인스턴스 수는 훨씬 더 많습니다. (예: NSG Rule, Monitor Alert, Private Endpoint 등 종속 리소스 포함 시 150개 이상)

| 모듈 (Module) | 리소스 유형 (Resource Type) | 개수 | 상세 설명 |
|:---:|:---|:---:|:---|
| **Hub** | `azurerm_resource_group` | 1 | 전체 리소스를 담는 논리적 컨테이너 |
| | `azurerm_virtual_network` | 1 | Hub VNet (보안/관리 네트워크) |
| | `azurerm_subnet` | 3 | AzureFirewallSubnet, AzureBastionSubnet, GatewaySubnet |
| | `azurerm_firewall` | 1 | 중앙 집중식 네트워크 보안 방화벽 |
| | `azurerm_firewall_policy` | 1 | Firewall 정책 및 규칙 |
| | `azurerm_bastion_host` | 1 | PaaS 기반 보안 원격 접속 호스트 |
| | `azurerm_public_ip` | 2+ | Firewall, Bastion용 공인 IP |
| **Network** | `azurerm_virtual_network` | 1 | Spoke VNet (서비스 네트워크) |
| | `azurerm_subnet` | 4+ | Web, App, DB, PrivateLink 서브넷 |
| | `azurerm_virtual_network_peering` | 2 | Hub-Spoke 양방향 피어링 |
| | `azurerm_application_gateway` | 1 | WAF v2 웹 방화벽 및 L7 로드밸런서 |
| | `azurerm_lb` | 1 | L4 Load Balancer (VMSS 부하분산) |
| | `azurerm_lb_backend_address_pool` | 1+ | 백엔드 풀 |
| | `azurerm_lb_probe` | 1+ | Health Probe |
| | `azurerm_lb_rule` | 1+ | 로드밸런싱 규칙 |
| | `azurerm_lb_nat_pool` | 1 | SSH NAT Pool (VMSS 직접 접속용) |
| | `azurerm_nat_gateway` | 1 | 아웃바운드 전용 게이트웨이 |
| | `azurerm_public_ip` | 3+ | AppGW, LB, NAT용 공인 IP |
| | `azurerm_dns_zone` | 1 | Public DNS Zone (hamap.shop) |
| | `azurerm_private_dns_zone` | 3+ | Private DNS Zone (MySQL, Storage 등) |
| | `azurerm_traffic_manager_profile` | 1 | 글로벌 트래픽 관리 |
| **Compute** | `azurerm_linux_virtual_machine_scale_set` | 1 | 자동 확장 웹 서버 그룹 |
| | `azurerm_linux_virtual_machine` | 2 | 관리/테스트 VM, Bastion VM |
| | `azurerm_container_group` | 1 | ACI (Serverless 컨테이너 인스턴스) |
| | `azurerm_shared_image_gallery` | 1 | 커스텀 이미지 갤러리 |
| | `azurerm_shared_image` | 1 | 이미지 정의 |
| | `azurerm_shared_image_version` | 1 | 버전별 이미지 |
| | `azurerm_snapshot` | 1+ | VM 스냅샷 |
| | `azurerm_backup_policy_vm` | 1 | VM 백업 정책 |
| | `azurerm_backup_protected_vm` | 1+ | 백업 활성화된 VM |
| | `azurerm_recovery_services_vault` | 1 | 백업 저장소 |
| | `azurerm_monitor_autoscale_setting` | 1 | Auto-scaling 규칙 |
| **Database** | `azurerm_mysql_flexible_server` | 1 | 메인 데이터베이스 (Zone Redundant) |
| | `azurerm_mysql_flexible_database` | 1 | 애플리케이션용 스키마 |
| | `azurerm_mysql_flexible_server_configuration` | 5+ | MySQL 설정값 |
| | `azurerm_mysql_flexible_server_firewall_rule` | 1+ | MySQL 방화벽 규칙 |
| | `azurerm_redis_cache` | 1 | Premium 등급 캐시 서버 |
| | `azurerm_cosmosdb_account` | 1 | NoSQL 데이터베이스 계정 |
| | `azurerm_cosmosdb_sql_database` | 1 | CosmosDB SQL 데이터베이스 |
| | `azurerm_cosmosdb_sql_container` | 1 | CosmosDB 컨테이너 |
| | `azurerm_data_factory` | 1 | 데이터 통합 및 ETL 서비스 |
| | `azurerm_data_factory_pipeline` | 1+ | 백업 파이프라인 |
| | `azurerm_data_factory_dataset_mysql` | 1 | MySQL 데이터셋 |
| | `azurerm_data_factory_dataset_delimited_text` | 1 | CSV 데이터셋 |
| | `azurerm_data_factory_linked_service` | 2+ | MySQL, Blob Storage 연결 |
| | `azurerm_data_factory_trigger_schedule` | 1 | 스케줄 트리거 |
| **Storage** | `azurerm_storage_account` | 3 | 메인(Blob), 프리미엄(File), 함수앱용 |
| | `azurerm_storage_container` | 5+ | 이미지, 백업, 로그 저장소 등 |
| | `azurerm_storage_share` | 1 | 파일 공유 (SMB) |
| | `azurerm_storage_management_policy` | 1 | Lifecycle 정책 |
| | `azurerm_cdn_frontdoor_profile` | 1 | Front Door CDN 프로필 |
| | `azurerm_cdn_frontdoor_endpoint` | 1 | CDN 엔드포인트 |
| | `azurerm_cdn_frontdoor_origin_group` | 1 | Origin 그룹 |
| | `azurerm_cdn_frontdoor_origin` | 1 | Origin 서버 |
| | `azurerm_cdn_frontdoor_route` | 1 | 라우팅 규칙 |
| **Security** | `azurerm_network_security_group` | 4+ | Web, App, DB, Bastion용 NSG |
| | `azurerm_network_security_rule` | 20+ | 개별 보안 규칙 |
| | `azurerm_subnet_nsg_association` | 4+ | 서브넷-NSG 연결 |
| | `azurerm_key_vault` | 1 | 비밀 및 인증서 저장소 |
| | `azurerm_log_analytics_workspace` | 1 | 통합 로그 수집 저장소 |
| | `azurerm_log_analytics_solution` | 1+ | Container Insights 등 솔루션 |
| | `azurerm_application_insights` | 1 | 애플리케이션 성능 모니터링 (APM) |
| | `azurerm_monitor_metric_alert` | 5+ | CPU, 메모리, 가용성 알람 규칙 |
| | `azurerm_monitor_action_group` | 1+ | 알림 액션 그룹 |
| | `azurerm_monitor_diagnostic_setting` | 10+ | 진단 설정 (각 리소스별) |
| | `azurerm_private_endpoint` | 5+ | MySQL, Redis, Storage, KeyVault, ACR용 |
| | `azurerm_private_dns_zone_virtual_network_link` | 5+ | Private DNS VNet 링크 |
| | `azurerm_security_center_contact` | 1 | 보안 연락처 |
| | `azurerm_security_center_subscription_pricing` | 8 | Defender for Cloud 플랜 |
| | `azurerm_resource_group_policy_assignment` | 2+ | Azure Policy 할당 |
| | `azurerm_role_assignment` | 5+ | RBAC 역할 할당 |
| **Serverless** | `azurerm_service_plan` | 1 | Function App 호스팅 플랜 (Consumption) |
| | `azurerm_linux_function_app` | 1 | 이미지 처리용 함수 앱 |
| | `azurerm_servicebus_namespace` | 1 | 메시지 큐 네임스페이스 |
| | `azurerm_servicebus_queue` | 1 | Service Bus 큐 |
| | `azurerm_servicebus_topic` | 1 | Service Bus 토픽 |
| | `azurerm_servicebus_subscription` | 1 | 토픽 구독 |
| **Container** | `azurerm_container_registry` | 1 | Docker 이미지 저장소 (Premium) |
| **Identity** | `azuread_user` (data) | 5 | 팀원별 사용자 계정 |

**총계: 78개 이상의 고유 리소스 타입** 
- 실제 배포된 리소스 인스턴스: **150개 이상**
- Terraform 관리 리소스: **130개 이상** (data 소스 제외)
- 최종 검증 일시: 2025-12-01


---

## 3. Traffic Flow (사용자 시나리오)

단순한 정적 구성도가 아닌, 실제 사용자가 서비스를 이용할 때의 데이터 흐름을 시나리오별로 설명합니다.

### 3.1 시나리오: 사용자가 이미지 업로드 시
사용자가 웹 사이트에서 프로필 이미지를 업로드할 때, 트래픽은 다음과 같은 유기적인 흐름을 따릅니다.

1.  **진입 (Entry)**: 사용자가 `https://www.hamap.shop/upload`로 이미지 전송.
2.  **보안 검사 (WAF)**: **Application Gateway**가 요청을 수신하고, WAF가 악성 파일이나 SQL Injection 공격 여부를 검사합니다.
3.  **라우팅 (Routing)**: 검사를 통과한 요청은 **VMSS (Web Server)** 중 가장 부하가 적은 인스턴스로 전달됩니다.
4.  **처리 (Processing)**: 웹 서버는 이미지를 임시 처리하고, **Private Endpoint**를 통해 **Storage Account (Blob)**의 `raw-images` 컨테이너에 원본을 저장합니다. (인터넷 경유 X, 내부망 전송)
5.  **이벤트 트리거 (Event)**: Blob에 파일이 저장되는 즉시 **Event Grid**가 이를 감지하고 **Function App**을 트리거합니다.
6.  **백그라운드 작업 (Serverless)**: **Function App (Python)**이 실행되어 원본 이미지를 리사이징(Thumbnail)하고, 최적화된 이미지를 `processed-images` 컨테이너에 저장합니다.
7.  **배포 (Delivery)**: 생성된 썸네일은 **CDN (Front Door)**을 통해 전 세계 엣지 서버로 캐싱되어, 사용자가 조회할 때 초고속으로 로딩됩니다.

---

## 4. Module: Hub (보안 및 네트워크 거점)

Hub 모듈은 전체 클라우드 네트워크의 **중추 신경망**이자 **보안 관문** 역할을 수행합니다. 모든 외부 트래픽과 관리 트래픽은 이 Hub를 거쳐야만 실제 서비스가 위치한 Spoke 네트워크로 진입할 수 있습니다. 이를 통해 보안 정책을 일원화하고 감사를 용이하게 합니다.

### 4.1 Azure Firewall (관리형 클라우드 방화벽)
**[기술적 도입 배경 및 의의]**
- **중앙 집중식 트래픽 제어**: 개별 VM이나 서브넷 단위의 NSG(Network Security Group)만으로는 관리하기 어려운, VNet 전체의 아웃바운드/인바운드 트래픽 흐름을 중앙에서 통제합니다.
- **L7 애플리케이션 필터링**: 단순 IP/Port 기반 차단을 넘어, FQDN(도메인 이름) 기반의 필터링을 수행합니다. 이는 OS 업데이트나 Azure 관리 서비스와 같이 IP가 수시로 변경되는 대상에 대해 안정적인 접근을 허용하면서도 보안을 유지하는 데 필수적입니다.
- **위협 인텔리전스 (Threat Intelligence)**: Microsoft가 전 세계적으로 수집하는 보안 위협 정보를 실시간으로 반영하여, 알려진 악성 IP나 도메인(C&C 서버 등)으로의 접속을 자동으로 탐지하고 차단합니다.

**[상세 구성 및 설정 근거]**
- **SKU**: `Standard (AZFW_VNet)`
    - *근거*: Premium SKU의 고급 기능(TLS Inspection 등)까지는 불필요하나, 엔터프라이즈급의 안정성과 위협 인텔리전스 기능이 필요함.
- **Availability Zones**: `1`, `2`
    - *근거*: 특정 데이터센터(Zone) 장애 시에도 방화벽 서비스가 중단되지 않도록 이중화 구성.
- **Firewall Policy (정책)**:
    - **Application Rules (L7)**:
        - `Allow-Windows-Update`: `*.windowsupdate.com`, `*.update.microsoft.com` (서버 보안 패치를 위한 필수 허용)
        - `Allow-Azure-Management`: `management.azure.com`, `login.microsoftonline.com` (Azure API 호출 및 인증)
    - **Network Rules (L4)**:
        - `Allow-DNS`: UDP/53 (도메인 이름 해석)
        - `Allow-NTP`: UDP/123 (서버 시간 동기화 - 로그 정확성 및 인증 토큰 유효성 보장)

### 4.2 Azure Bastion (보안 원격 접속)
**[기술적 도입 배경 및 의의]**
- **공격 표면(Attack Surface) 제거**: 관리용 포트(SSH 22, RDP 3389)를 공용 인터넷에 노출시키는 것은 해킹의 주된 표적이 됩니다. Bastion은 이러한 포트를 외부에 노출하지 않고, Azure Portal을 통한 HTTPS(443) 터널링으로 안전한 접속을 제공합니다.
- **JIT(Just-In-Time) 접근 가능성**: 필요할 때만 접속을 허용하고 모든 접속 이력을 감사 로그로 남길 수 있어 컴플라이언스 준수에 유리합니다.

**[상세 구성 및 설정 근거]**
- **SKU**: `Standard`
    - *근거*: Basic SKU와 달리 **네이티브 클라이언트(Native Client)** 접속을 지원하여, 개발자가 익숙한 로컬 터미널(PowerShell, Bash)에서 `ssh` 명령어로 직접 접속할 수 있는 편의성을 제공합니다. 또한 **파일 복사/붙여넣기** 기능을 지원하여 운영 효율성을 높입니다.
- **Subnet**: `AzureBastionSubnet` (필수 지정 이름)
    - *근거*: Bastion 서비스가 배포되기 위한 전용 서브넷으로, 최소 `/26` 이상의 CIDR이 권장됩니다.

---

## 5. Module: Network (서비스 네트워크 인프라)

Spoke VNet 내에서 실제 애플리케이션 트래픽을 처리하고 분산하는 핵심 네트워크 계층입니다. **3-Tier Architecture**의 첫 번째 관문인 Presentation Layer를 담당합니다.

### 5.1 Application Gateway (WAF - Web Application Firewall)
**[기술적 도입 배경 및 의의]**
- **L7 지능형 로드밸런싱**: 단순한 패킷 분배가 아니라, HTTP 헤더, URI 경로 등을 분석하여 트래픽을 라우팅합니다. SSL/TLS 종료(Termination)를 수행하여 백엔드 서버의 암호화 복호화 부하를 경감시킵니다.
- **웹 애플리케이션 보안**: WAF(Web Application Firewall)를 통합하여 SQL Injection, XSS(Cross-Site Scripting), RFI/LFI 등 웹 애플리케이션을 노리는 일반적인 공격을 네트워크 앞단에서 차단합니다.

**[상세 구성 및 설정 근거]**
- **Tier**: `WAF_v2`
    - *근거*: v1 대비 향상된 성능, 자동 확장(Autoscaling), Zone Redundancy 지원, 그리고 더 빠른 배포 속도를 제공합니다.
- **WAF Configuration**:
    - **Mode**: `Prevention` (차단 모드)
        - *근거*: 공격 탐지 시 로그만 남기는 Detection 모드보다, 즉시 차단하여 시스템을 보호하는 것이 중요함.
    - **Rule Set**: `OWASP 3.2`
        - *근거*: 국제 웹 보안 표준 기구인 OWASP의 최신 Core Rule Set을 적용하여 알려진 취약점 공격을 방어.
- **Listener & Routing**:
    - **HTTP (80)**: HTTPS 리다이렉트 전용. 모든 트래픽을 암호화된 채널로 강제 전환.
    - **HTTPS (443)**: Key Vault에 저장된 인증서를 연동하여 보안 통신 보장.
- **Health Probe**:
    - **Path**: `/health.html`
    - *근거*: 단순 포트 연결 확인이 아닌, 실제 웹 서버가 콘텐츠를 응답할 수 있는 상태인지 확인하기 위해 전용 헬스 체크 페이지를 호출.

### 5.2 Load Balancer (L4 Load Balancer)
**[기술적 도입 배경 및 의의]**
- **고속 트래픽 처리**: L7 게이트웨이보다 훨씬 가볍고 빠른 속도로 TCP/UDP 트래픽을 분산합니다. 내부 통신이나 비-HTTP 트래픽 처리에 적합합니다.
- **HA 구성의 핵심**: VMSS 인스턴스들이 수시로 생성되고 삭제될 때, Load Balancer의 Backend Pool이 이를 자동으로 감지하여 트래픽을 유효한 인스턴스로만 보냅니다.

**[상세 구성 및 설정 근거]**
- **SKU**: `Standard`
    - *근거*: Basic SKU는 가용 영역(Zone)을 지원하지 않으며, HTTPS Health Probe 등 고급 기능을 제공하지 않음. 프로덕션 환경에서는 Standard가 필수.
- **Availability Zones**: `1`, `2`, `3`
    - *근거*: Public IP가 3개 Zone에 분산 배치되어 최대 가용성 확보. 단일 Zone 장애 시에도 서비스 지속 가능.
- **Outbound Rule**: **없음 (NAT Gateway 위임)**
    - *근거*: Load Balancer를 통한 아웃바운드 통신(SNAT)은 포트 고갈(Port Exhaustion) 문제를 일으킬 수 있으므로, 아웃바운드 전용 리소스인 NAT Gateway를 사용하는 것이 모범 사례입니다.

### 5.3 NAT Gateway
**[기술적 도입 배경 및 의의]**
- **일관된 아웃바운드 IP**: VMSS와 같이 동적으로 IP가 변하는 리소스들이 외부(예: 결제 모듈, 외부 API)와 통신할 때, 항상 고정된 하나의 Public IP를 사용하게 합니다. 이는 외부 파트너사의 방화벽 화이트리스트 등록을 가능하게 합니다.
- **SNAT 포트 고갈 방지**: 대량의 아웃바운드 연결이 발생할 때 포트 부족으로 인한 연결 실패를 방지하는 온디맨드 포트 할당 기능을 제공합니다.

**[상세 구성 및 설정 근거]**
- **Availability Zones**: `1` (단일 Zone)
    - *근거*: 아웃바운드 전용 리소스로, Zone Redundancy보다 안정적인 단일 Zone 배치 선택. 비용 효율성과 안정성 균형.

### 5.4 Traffic Manager (글로벌 트래픽 관리)
**[기술적 도입 배경 및 의의]**
- **DNS 기반 로드밸런싱**: 사용자 위치에 따라 가장 가까운 엔드포인트로 라우팅하거나, 우선순위에 따라 트래픽을 분산합니다.
- **고가용성 보장**: 주 엔드포인트(App Gateway) 장애 시, 트래픽을 자동으로 다른 엔드포인트로 우회시킬 수 있는 구조를 마련합니다.

**[상세 구성 및 설정 근거]**
- **Routing Method**: `Priority`
    - *근거*: 현재는 단일 리전(Korea Central)이므로, 모든 트래픽을 Primary 엔드포인트로 보내고, 장애 시에만 Failover하는 구조가 적합합니다. 향후 멀티 리전 확장 시 `Performance` 모드로 변경 예정입니다.
- **Monitor Config**:
    - **Protocol**: `HTTPS` (Port 443)
    - **Path**: `/`
    - *근거*: 실제 서비스 포트인 443을 모니터링하여, 서비스가 응답하지 않을 경우 즉시 트래픽을 차단합니다.
- **Endpoint**:
    - **Type**: `Azure Endpoint`
    - **Target**: `App Gateway Public IP`


---

## 6. Module: Compute (애플리케이션 실행 환경)

비즈니스 로직을 처리하는 **Application Layer**입니다. 유연성과 안정성을 동시에 확보하는 것이 목표입니다.

### 6.1 Virtual Machine Scale Set (VMSS)
**[기술적 도입 배경 및 의의]**
- **탄력성 (Elasticity)**: 클라우드의 가장 큰 장점인 '사용한 만큼 지불'을 실현합니다. 트래픽이 몰리는 피크 타임에는 서버를 늘리고, 새벽 시간에는 줄여 비용을 최적화합니다.
- **자동 복구 (Self-Healing)**: 특정 인스턴스에 장애가 발생하여 Health Probe에 응답하지 않으면, 시스템이 이를 감지하고 자동으로 해당 인스턴스를 삭제 후 재생성합니다. 운영자의 개입 없이 서비스 건전성을 유지합니다.

**[상세 구성 및 설정 근거]**
- **SKU**: `Standard_D2s_v3`
    - *근거*: 2 vCPU, 8GB RAM은 일반적인 웹 애플리케이션(WordPress, API 서버)을 구동하기에 가장 가성비가 뛰어난 범용 스펙입니다. Premium Storage를 지원하여 디스크 I/O 병목을 방지합니다.
- **OS Image**: `Rocky Linux 9`
**[기술적 도입 배경 및 의의]**
- **글로벌 엣지 가속**: 전 세계 100개 이상의 엣지 POP(Point of Presence)를 통해 정적 콘텐츠를 캐싱하여, 사용자에게 가장 가까운 위치에서 콘텐츠를 전송합니다.
- **지능형 보안**: DDoS 방어 및 WAF 기능을 엣지 레벨에서 수행하여, 악성 트래픽이 Azure 백본 네트워크에 진입하기 전에 차단합니다.

**[상세 구성 및 설정 근거]**
- **SKU**: `Standard_AzureFrontDoor`
    - *근거*: 콘텐츠 전송 및 기본 보안 기능(WAF, DDoS Basic)을 제공하며, Premium 대비 비용 효율적입니다.
- **Origin Group**:
    - **Health Probe**: `HTTPS / HEAD`
    - *근거*: 백엔드(Storage/AppGateway)의 상태를 주기적으로 확인하여, 장애 발생 시 자동으로 트래픽을 차단합니다.
- **Origin**:
    - **Host**: Storage Account Primary Blob Host
    - **Priority**: `1`, **Weight**: `1000`
- **Route**:
    - **Patterns**: `/*` (모든 경로 매칭)
    - **Forwarding Protocol**: `MatchRequest` (HTTP는 HTTP로, HTTPS는 HTTPS로 전달)
    - **HTTPS Redirect**: `Enabled` (보안 통신 강제)

### 8.3 Web Application Firewall (WAF) on Front Door
**[기술적 도입 배경 및 의의]**
- **엣지 보안**: 트래픽이 Azure 데이터센터에 도달하기 전, 전 세계 엣지 로케이션에서 악성 트래픽을 사전 차단합니다.
- **관리형 규칙 집합**: Microsoft가 관리하는 최신 위협 인텔리전스 기반의 규칙(Default Rule Set 2.1)을 적용하여 제로 데이 공격에 대응합니다.

**[상세 구성 및 설정 근거]**
- **Mode**: `Prevention` (차단)
    - *근거*: 탐지(Detection) 모드는 로그만 남기므로, 실질적인 방어를 위해 차단 모드로 설정했습니다.
- **Rule Set**: `Microsoft_DefaultRuleSet 2.1`
    - *근거*: SQL Injection, XSS, RFI 등 OWASP Top 10 취약점을 포함한 포괄적인 방어 규칙을 제공합니다.
- **Custom Response**: `403 Forbidden` ("Access Denied by WAF")



### 8.2 Lifecycle Management Policy (스토리지 비용 최적화)
**[기술적 도입 배경 및 의의]**
- **자동 계층 전환**: 오래된 데이터를 자동으로 저렴한 스토리지 계층으로 이동시켜 비용을 절감합니다. Hot → Cool → Archive 순으로 비용이 저렴해지며, 접근 빈도가 낮은 데이터는 Archive에 보관하여 최대 90% 비용 절감이 가능합니다.
- **자동 삭제**: 일정 기간이 지난 불필요한 데이터를 자동으로 삭제하여 스토리지 공간 및 비용을 관리합니다.
- **규정 준수**: 데이터 보관 정책(예: 로그는 1년 보관 후 삭제)을 코드로 정의하여 자동 실행함으로써 컴플라이언스를 보장합니다.

**[배포된 정책 규칙]**

#### Rule 1: media-lifecycle (미디어 파일 관리)
**적용 대상**: `media/` prefix를 가진 Block Blob (이미지, 동영상 등)

| 경과 일수 | 동작 | 근거 |
|:---:|:---|:---|
| 30일 | **Cool Tier 이동** | 한 달이 지난 미디어는 접근 빈도가 급격히 감소. Cool 계층으로 이동하여 스토리지 비용 50% 절감 |
| 90일 | **Archive Tier 이동** | 3개월이 지난 콘텐츠는 거의 접근되지 않음. Archive로 이동하여 추가 40% 절감 (Hot 대비 총 90% 절감) |
| 730일 (2년) | **자동 삭제** | 법적 보관 의무가 없는 미디어 파일은 2년 후 자동 삭제하여 스토리지 공간 확보 |
| **스냅샷**: 90일 | **자동 삭제** | Blob 스냅샷은 3개월만 보관 후 삭제 |
| **이전 버전**: 90일 | **자동 삭제** | Blob Versioning이 활성화된 경우, 이전 버전은 3개월 후 삭제 |

#### Rule 2: logs-lifecycle (로그 파일 관리)
**적용 대상**: Block Blob (애플리케이션 로그, 진단 로그 등)

| 경과 일수 | 동작 | 근거 |
|:---:|:---|:---|
| 7일 | **Cool Tier 이동** | 일주일이 지난 로그는 실시간 분석 필요성이 낮아짐. Cool로 이동하여 비용 절감 |
| 30일 | **Archive Tier 이동** | 한 달이 지난 로그는 감사 목적으로만 보관. Archive로 이동하여 장기 보관 비용 최소화 |
| 365일 (1년) | **자동 삭제** | 대부분의 규정은 로그를 1년간 보관하도록 요구. 1년 후 자동 삭제 |
| **스냅샷**: 90일 | **자동 삭제** | 로그 스냅샷은 3개월 보관 |

**[비용 절감 효과 (예시)]**
- **시나리오**: 월 1TB의 미디어 파일 업로드
- **Lifecycle 적용 전**: 1TB × $0.0184/GB = $18.84/월 (Hot Tier)
- **Lifecycle 적용 후**:
  - 최근 30일 데이터 (1TB): $18.84 (Hot)
  - 31-90일 데이터 (2TB): $20.48 (Cool, $0.01/GB)
  - 91일 이상 데이터 (9TB): $18.00 (Archive, $0.002/GB)
  - **총 비용**: $57.32/월 (12TB 저장)
  - **Lifecycle 미적용 시**: $220.08/월 (12TB 전부 Hot) → **73% 비용 절감**

**[관리 및 모니터링]**
- **정책 실행**: 매일 자동으로 실행되어 규칙에 맞는 Blob을 탐지하고 계층 이동/삭제 수행
- **실행 로그**: Storage Account의 `$logs` 컨테이너에 기록
- **정책 수정**: Terraform 코드 수정 후 `terraform apply`로 즉시 반영 가능

---

## 9. Module: Security (보안 거버넌스)

### 9.1 Network Security Group (NSG)
**[기술적 도입 배경 및 의의]**
- **Micro-segmentation (초세분화)**: 방화벽이 뚫리더라도 피해가 확산되지 않도록, 각 서브넷 단위로 트래픽을 다시 한번 검증합니다. "필요한 것만 열고 다 막는다(Deny All by Default)"는 원칙을 적용합니다.

**[상세 구성 및 설정 근거]**
- **Web Subnet**: 80/443(서비스), 22(Bastion에서만) 허용.
- **DB Subnet**: 3306(Web Subnet에서만) 허용. 인터넷 직접 접근 절대 불가.

### 9.2 Key Vault
**[기술적 도입 배경 및 의의]**
- **Secrets Management**: DB 비밀번호, API 키, 인증서 파일 등을 소스 코드나 설정 파일에 평문으로 저장하는 것은 보안상 치명적입니다. Key Vault는 이러한 비밀 정보를 하드웨어 보안 모듈(HSM) 기반으로 안전하게 저장하고, 애플리케이션이 실행 시점에 안전하게 가져다 쓸 수 있게 합니다.

**[상세 구성 및 설정 근거]**
- **Soft Delete**: `90일`
    - *근거*: 실수로 키를 삭제하거나 악의적인 삭제 시도가 있어도, 90일 이내에는 즉시 복구할 수 있는 안전장치입니다.
- **Purge Protection**: `Enabled`
    - *근거*: Soft Delete된 키를 영구적으로 삭제(Purge)하는 것을 방지하여, 데이터 유실 사고를 완벽하게 예방합니다.

### 9.3 Azure Security Center (Microsoft Defender)
**[기술적 도입 배경 및 의의]**
- **통합 보안 관리**: Subscription 레벨에서 모든 리소스의 보안 상태를 모니터링하고, 보안 권장사항을 제공합니다.
- **위협 탐지**: 이상 행위 및 공격 시도를 실시간으로 탐지하여 알림합니다.

**[상세 구성 및 설정 근거]**
- **Virtual Machines**: `Standard Tier`
    - *근거*: VM에 대한 고급 위협 탐지 및 취약점 평가 제공.
- **SQL Servers**: `Standard Tier`
    - *근거*: 데이터베이스 보안 위협 탐지 및 권장사항 제공.
- **Storage Accounts**: `Standard Tier` + `DefenderForStorageV2` subplan
    - *근거*: 최신 Defender for Storage V2를 사용하여 Blob, File, Queue에 대한 향상된 위협 탐지 제공. Classic 플랜 대비 성능 및 기능 개선.
- **Key Vaults**: `Standard Tier`
    - *근거*: 비밀 정보 접근 이상 행위 탐지.

### 9.4 Diagnostic Settings (진단 설정)
**[기술적 도입 배경 및 의의]**
- **통합 로깅**: 각 리소스(MySQL, Key Vault 등)의 로그와 메트릭을 개별적으로 관리하지 않고, **Log Analytics Workspace**로 중앙 수집하여 통합 모니터링 및 분석을 수행합니다.
- **감사 추적**: 누가 언제 무엇을 했는지에 대한 감사 로그(Audit Log)를 영구 보존하여 보안 사고 시 원인 분석을 가능하게 합니다.

**[상세 구성 및 설정 근거]**
- **Destination**: `Log Analytics Workspace`
- **MySQL Flexible Server**:
    - **Logs**: `MySqlAuditLogs`, `MySqlSlowLogs` (보안 감사 및 성능 튜닝 목적)
    - **Metrics**: `AllMetrics` (CPU, 메모리, IOPS 등 성능 지표)
- **Key Vault**:
    - **Logs**: `AuditEvent`, `AzurePolicyEvaluationDetails` (비밀 조회/변경 이력 추적)
    - **Metrics**: `AllMetrics`

### 9.5 Azure Policy (거버넌스 및 규정 준수)
**[기술적 도입 배경 및 의의]**
- **Policy as Code**: 조직의 보안 표준과 규정 준수 요구사항을 코드로 정의하고 강제합니다.
- **실수 방지**: 개발자가 실수로 보안이 취약한 리소스(예: HTTP 스토리지)를 생성하는 것을 원천적으로 차단합니다.

**[적용된 정책 목록]**
1.  **Secure Transfer Required**:
    - **대상**: Storage Accounts
    - **효과**: `Deny`
    - **내용**: `supportsHttpsTrafficOnly` 속성이 `true`가 아니면 리소스 생성을 차단합니다.
2.  **Allowed Locations**:
    - **대상**: 모든 리소스
    - **효과**: `Deny`
    - **내용**: `Korea Central` 및 `Global` 리전 외의 리소스 생성을 차단하여 데이터 주권 및 규정을 준수합니다.

### 9.6 Microsoft Sentinel (지능형 보안 관제)
**[기술적 도입 배경 및 의의]**
- **Cloud-Native SIEM/SOAR**: 별도의 하드웨어 구축 없이 클라우드에서 즉시 사용 가능한 보안 정보 이벤트 관리(SIEM) 및 보안 오케스트레이션 자동화 대응(SOAR) 솔루션입니다.
- **AI 기반 위협 탐지**: 머신러닝을 활용하여 단순한 규칙 기반 탐지로는 놓칠 수 있는 정교한 공격 패턴을 식별합니다.

**[구현된 탐지 규칙 (Analytics Rules)]**
1.  **SSH Brute Force Detection**:
    - **로직**: 5분 이내에 5회 이상 SSH 로그인 실패 시 경고 발생.
    - **대응**: 공격자 IP 차단 및 관리자 알림.
2.  **Malicious IP Communication**:
    - **로직**: Azure Firewall 로그를 분석하여, 위협 인텔리전스(Threat Intelligence)에 등록된 악성 IP와의 통신 시도 탐지.
    - **대응**: 즉시 차단 및 침해 사고 조사(Forensic) 개시.
3.  **Sensitive File Access**:
    - **로직**: `/etc/passwd`, `/etc/shadow` 등 시스템 중요 파일에 대한 접근 시도 탐지.
    - **대응**: 내부자 위협 또는 권한 상승 시도로 간주하여 정밀 감사 수행.





## 10. Module: Serverless (이벤트 기반 처리)

### 10.1 Function App
**[기술적 도입 배경 및 의의]**
- **Event-Driven Architecture**: 사용자가 이미지를 업로드하는 '이벤트'가 발생했을 때만 코드가 실행되어 썸네일을 생성합니다. 24시간 서버를 띄워놓을 필요가 없어 비용이 거의 0에 수렴하며, 트래픽 폭주 시에는 무한대로 자동 확장되어 처리가 지연되지 않습니다.

**[상세 구성 및 설정 근거]**
- **Plan**: `Consumption (Y1)`
    - *근거*: 서버리스 과금 모델로, 유휴 시간에는 비용이 0원입니다. 간헐적인 백그라운드 작업에 최적화되어 있습니다.
- **Runtime**: `Python 3.9`
    - *근거*: 이미지 처리 라이브러리(Pillow, OpenCV 등) 생태계가 가장 풍부한 언어입니다.

---

## 11. Module: ContainerRegistry (이미지 자산 관리)

### 11.1 Azure Container Registry (ACR)
**[기술적 도입 배경 및 의의]**
- **Private Docker Registry**: 기업의 지적 재산인 애플리케이션 소스 코드가 담긴 도커 이미지를 Public Docker Hub가 아닌, 기업 전용의 비공개 저장소에 안전하게 보관합니다.
- **고속 배포**: Azure 서비스(ACI, AKS, Web App)와 동일한 데이터센터 네트워크 내에 위치하여, 이미지 풀(Pull) 속도가 매우 빠릅니다.

**[상세 구성 및 설정 근거]**
- **SKU**: `Premium`
    - *근거*: Private Endpoint 연결을 지원하는 유일한 SKU입니다. 이미지를 인터넷을 통해 전송하지 않고, 내부 네트워크로만 전송하여 보안을 극대화하기 위해 선택되었습니다.
- **Geo-Replication**: 필요 시 활성화 가능
    - *근거*: 글로벌 서비스 확장 시, 각 리전의 ACR로 이미지를 자동 복제하여 전 세계 어디서든 빠른 배포를 가능하게 합니다.

---

## 12. 결론

본 인프라는 단순한 기능 구현을 넘어, 엔터프라이즈 환경에서 요구되는 **보안, 안정성, 확장성**을 모두 충족하도록 설계되었습니다. 모든 리소스는 **Terraform** 코드로 정의되어 있어 언제든 동일한 환경을 재구축할 수 있으며(Disaster Recovery), 모듈화된 구조 덕분에 향후 서비스 확장에 유연하게 대응할 수 있습니다.
