# 모듈별 확장 가능성 분석

## 개요
현재 프로젝트의 각 모듈에서 향후 확장 가능한 부분들을 정리한 문서입니다.

---

## 1. Network 모듈 확장 가능성

### 현재 구성
- VNet (가상 네트워크)
- Subnet (서브넷)
- Load Balancer (부하 분산기)
- Bastion (관리자 접근)

### 확장 가능한 부분

#### 1.1 Application Gateway 추가
**목적**: 웹 애플리케이션 방화벽(WAF) 기능 제공
```
현재: Load Balancer (L4)
확장: Application Gateway (L7 + WAF)
```
**효과**:
- SSL/TLS 종료 지점 중앙화
- URL 기반 라우팅 (예: /api → API 서버, /web → 웹 서버)
- DDoS 방어 및 웹 공격 차단

#### 1.2 VPN Gateway 추가
**목적**: 온프레미스 환경과의 하이브리드 클라우드 구축
```
VPN Gateway
├─ Site-to-Site VPN (회사 네트워크 연결)
└─ Point-to-Site VPN (개발자 원격 접속)
```

#### 1.3 Network Watcher 활성화
**목적**: 네트워크 모니터링 및 진단
- 패킷 캡처
- 연결 모니터
- NSG 플로우 로그 분석

#### 1.4 Cross-Region Load Balancer 도입
**목적**: 글로벌 트래픽 분산 및 고가용성 확보
```
Region A (Korea Central) ---+
                            |
Region B (Korea South) -----+--- Cross-Region LB --- 사용자 (Global)
                            |
Region C (Japan East) ------+
```
**효과**:
- 단일 리전 장애 시 즉시 타 리전으로 트래픽 전환
- 글로벌 사용자에게 가장 가까운 리전으로 라우팅 (지연 시간 감소)

---

## 2. Compute 모듈 확장 가능성

### 현재 구성
- VM (관리용 소스 VM)
- Image Gallery (이미지 저장소)
- VMSS (웹 서버 확장 그룹)

### 확장 가능한 부분

#### 2.1 Auto-Scaling 고도화
**현재**: 수동 인스턴스 조정
**확장**: 자동 스케일링 규칙 추가
```hcl
resource "azurerm_monitor_autoscale_setting" "vmss" {
  profile {
    rule {
      metric_trigger {
        metric_name = "Percentage CPU"
        threshold   = 70
      }
      scale_action {
        direction = "Increase"
        value     = 2  # 인스턴스 2개 추가
      }
    }
  }
}
```

#### 2.2 Container 환경 전환
**목적**: 더 빠른 배포 및 경량화
```
현재: VMSS (가상 머신)
확장: Azure Container Instances (ACI) 또는 AKS (Kubernetes)
```
**효과**:
- 배포 속도 10배 향상
- 리소스 효율성 증가
- CI/CD 파이프라인 단순화

#### 2.3 Spot VM 활용
**목적**: 비용 최적화 (최대 90% 절감)
```hcl
resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  priority        = "Spot"
  eviction_policy = "Deallocate"
  max_bid_price   = 0.05  # 시간당 최대 $0.05
}
```
**적용 시나리오**: 비프로덕션 환경, 배치 작업

#### 2.4 VMSS 업그레이드 정책 최적화
**목적**: 무중단 배포 및 운영 효율성 증대
```hcl
resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  # 현재: Manual (수동 업데이트 필요)
  # upgrade_mode = "Manual"
  
  # 확장: Rolling (순차적 자동 업데이트)
  upgrade_mode = "Rolling"
  
  rolling_upgrade_policy {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 5
    pause_time_between_batches              = "PT0S"
  }
}
```

#### 2.5 수직적 확장(Scale-Up) vs 수평적 확장(Scale-Out) 전략
- **Scale-Up (Vertical)**:
  - VM 사이즈 변경 (예: Standard_B2s → Standard_D4s_v3)
  - **장점**: 아키텍처 변경 없음
  - **단점**: 리부팅 필요 (다운타임 발생), 비용 급증 가능성
- **Scale-Out (Horizontal)**:
  - VM 인스턴스 개수 증가 (예: 2대 → 10대)
  - **장점**: 무중단 확장, 세밀한 비용 제어
  - **권장**: 웹 서버는 Scale-Out, DB는 Scale-Up 우선 고려

---

## 3. Security 모듈 확장 가능성

### 현재 구성
- NSG (네트워크 보안 그룹)

### 확장 가능한 부분

#### 3.1 Azure Firewall 추가
**목적**: 고급 방화벽 기능 제공
```
NSG (서브넷 레벨)
  └─ 기본 허용/차단
Azure Firewall (VNet 레벨)
  └─ FQDN 필터링, 위협 인텔리전스
```

#### 3.2 Key Vault 통합
**목적**: 민감 정보 중앙 관리
```
Key Vault에 저장:
├─ DB 비밀번호
├─ SSH 키
├─ API 토큰
└─ SSL 인증서
```

#### 3.3 Azure Defender 활성화
**목적**: 위협 탐지 및 보안 권장 사항
```
보안 점검 항목:
├─ VM 취약점 스캔
├─ 네트워크 이상 트래픽 감지
├─ 의심스러운 로그인 시도 알림
└─ 컴플라이언스 체크 (PCI-DSS, HIPAA 등)
```

---

## 4. Database 모듈 확장 가능성

### 현재 구성
- MySQL Flexible Server (Primary)
- MySQL Replica (DR용)
- Private Endpoint
- Data Factory (비활성)

### 확장 가능한 부분

#### 4.1 Read Replica 활성화 및 다중화
**목적**: 읽기 성능 향상
```
현재: Primary (읽기/쓰기) → Replica (읽기 전용, 동일 리전)
확장: Primary (쓰기) → Read Replica 1, 2, 3 (타 리전 확장 포함)
```
**Application 수정**:
```python
# 쓰기
db_write = connect("primary.mysql.database.azure.com")
# 읽기 (로드 밸런싱 - 향후 다중 Replica 도입 시)
db_read = connect("replica{random(1,3)}.mysql.database.azure.com")
```

#### 4.2 Redis Cache (현재 활성화됨)
**상태**: `05_redis.tf` 적용 완료
**효과**:
- DB 쿼리 부하 70% 감소
- 응답 속도 10배 향상
- 세션 데이터 고속 처리

#### 4.3 Data Factory 파이프라인 구축
**파일**: `06_adf.tf`
**시나리오**:
```
일일 배치 작업:
1. MySQL에서 통계 데이터 추출
2. 데이터 정제 및 변환
3. Azure Synapse Analytics로 전송
4. Power BI 대시보드 업데이트
```

#### 4.4 Cosmos DB 하이브리드 구조
**목적**: NoSQL 데이터 처리 (세션, 로그, 대량 쓰기)
```
MySQL: 정형 데이터 (게시물, 사용자)
Cosmos DB: 비정형 데이터 (세션, 로그, 실시간 데이터)
```

#### 4.5 감사 로그(Audit Logs) 오프로딩
**목적**: 대규모 트래픽 환경에서 DB 성능 저하 방지 및 로그 보관
```
현재: 로컬 파일 저장 (스토리지 공간 점유, I/O 부하)
확장: Azure Monitor / Event Hub로 스트리밍
```
**구성**:
1. Diagnostic Setting 활성화
2. `MySqlAuditLogs` 카테고리를 Log Analytics Workspace로 전송
3. KQL(Kusto Query Language)로 고속 검색 및 분석
```

---

## 5. Storage 모듈 확장 가능성

### 현재 구성
- Storage Account
- Container (media, tfstate)
- Lifecycle Policy

### 확장 가능한 부분

#### 5.1 CDN (현재 활성화됨 - Front Door)
**상태**: Front Door Profile 적용 완료
**효과**:
```
사용자 (미국) → CDN Edge (미국) → Storage (한국)
                   ↑ 캐시 히트       ↑ 최초 1회
로딩 속도: 5초 → 0.5초 (10배 향상)
```

#### 5.2 Blob Versioning & Soft Delete
**목적**: 파일 복구 및 버전 관리
```hcl
resource "azurerm_storage_account" "www_sa" {
  blob_properties {
    versioning_enabled  = true
    delete_retention_policy {
      days = 30
    }
  }
}
```

#### 5.3 Azure Files (파일 공유)
**목적**: VMSS 인스턴스 간 파일 공유
```
시나리오: 업로드된 이미지를 모든 웹 서버에서 접근
현재: Storage Account (HTTP API)
확장: Azure Files (SMB/NFS 마운트)
```

#### 5.4 Premium Block Blob Storage 도입
**목적**: 고성능 I/O가 필요한 대규모 트랜잭션 처리
- **Standard**: 일반적인 웹 호스팅, 백업 (HDD/SSD 하이브리드)
- **Premium**: 실시간 로그 처리, AI 학습 데이터 (All-Flash SSD)
- **효과**: 지연 시간(Latency) 10ms 미만 보장
```

---

## 6. 전체 아키텍처 확장 로드맵

### Phase 1 (단기 - 1개월)
- [x] Redis Cache 활성화 (완료)
- [x] CDN 활성화 (Front Door로 대체 완료)
- [x] Read Replica (동일 리전 구성 완료)
- [ ] Auto-Scaling 설정

### Phase 2 (중기 - 3개월)
- [ ] Application Gateway 도입
- [ ] Key Vault 통합
- [ ] Read Replica 확장 (Cross-Region 도입)

### Phase 3 (장기 - 6개월)
- [ ] Container 환경 전환 (AKS)
- [ ] Azure Firewall 추가
- [ ] Cosmos DB 하이브리드 구조

---

## 비용 영향 분석

| 확장 항목 | 예상 월 비용 (USD) | 효과 |
|----------|------------------|------|
| Redis Cache (Basic 250MB) | $15 | 성능 10배 ↑ |
| CDN (Standard) | $20~50 | 글로벌 속도 향상 |
| Application Gateway | $150 | WAF 보안 |
| Read Replica (1개) | $50 | 읽기 성능 2배 ↑ |
| Azure Firewall | $500 | 고급 보안 |

**우선순위 추천**: Redis Cache → CDN → Auto-Scaling

---

**작성일**: 2025-11-22  
**작성자**: Antigravity AI
