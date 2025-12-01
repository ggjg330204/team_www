# 미배포 서비스 및 향후 계획

**작성일**: 2025-12-01  
**검증 기준**: Terraform State (terraform.tfstate.backup)

---

## 1. 문서 목적

본 문서는 **실제로 배포되지 않은 서비스**와 향후 인프라 고도화를 위해 **계획 중인 서비스 및 개선사항**만을 정리합니다.

> **참고**: 이미 배포 완료된 서비스(예: CosmosDB, Data Factory, Service Bus, Front Door, Bastion, ACI, ACR 등)는 본 문서에서 제외하고 `02_Service_Significance_and_Configuration.md`에서 확인하세요.

---

## 2. 현재 미배포된 서비스

### 2.1 VPN Gateway (가상 사설망 게이트웨이)

**실제 상태**: ❌ **미배포**

**미배포 사유**:
1. **비용 최적화**: VPN Gateway는 시간당 과금되는 리소스로, 상시 가동 시 월 $150-500의 고정 비용 발생
2. **On-Premise 연결 불필요**: 현재 Pure Cloud 환경으로 운영 중이며, 온프레미스 데이터센터와의 연동 요구사항이 없음
3. **대안 사용 중**: Azure Bastion (PaaS) 및 Bastion VM을 통한 안전한 원격 접속으로 관리 수요 충족

**향후 활성화 조건**:
- 온프레미스 레거시 시스템과의 안전한 연동 필요 시
- 하이브리드 클라우드 전략으로 전환 시
- Site-to-Site VPN 또는 ExpressRoute 연결 요구사항 발생 시

---

### 2.2 DDoS Protection Standard (분산 서비스 거부 공격 방어)

**실제 상태**: 
- ✅ **DDoS Protection Basic**: 자동 활성화 (무료)
- ❌ **DDoS Protection Standard**: 미활성화

**미배포 사유**:
1. **비용 구조**: DDoS Protection Standard는 월 $2,944의 고정 비용 + 데이터 처리 비용 발생
2. **기본 보호 충분**: DDoS Protection Basic이 네트워크 계층(L3/L4) 공격 대부분 차단
3. **다계층 방어 존재**: Application Gateway WAF, Azure Firewall이 이미 애플리케이션 계층(L7) 공격 방어

**향후 활성화 조건**:
- 대규모 DDoS 공격 피해 경험 또는 우려 발생 시
- 금융, 게임 등 고가용성이 극도로 중요한 서비스로 확장 시
- SLA 99.99% 이상 보장이 계약상 필수인 경우

---

## 3. 향후 계획 서비스 및 개선사항



### 3.2 멀티 리전 Geo-Routing

**개선 계획**:
- **Geo-Routing**: 사용자 접속 위치에 따라 가장 가까운 리전으로 자동 라우팅
  - 한국 사용자 → Korea Central Origin
  - 일본 사용자 → Japan East Origin (미배포 - 추가 필요)
  - 미국 사용자 → US West Origin (미배포 - 추가 필요)
- **Priority-based Failover**: 주 리전 장애 시 자동 전환

**기대 효과**:
- 글로벌 사용자 응답 속도 50% 이상 향상
- 재해 복구 자동화

---

### 3.3 컨테이너 오케스트레이션: AKS (Azure Kubernetes Service)

**현재 상태**: ❌ **미배포**

> **참고**: ACI와 ACR은 이미 배포되어 있으며, 본 계획은 Kubernetes 클러스터 도입입니다.

**도입 배경**:
- VMSS 기반 모놀리식 애플리케이션을 마이크로서비스로 분해
- Kubernetes의 자동 확장, 자가 치유, Rolling Update 활용
- GitOps (ArgoCD, Flux) 도입으로 배포 프로세스 완전 자동화

**구성 계획**:
```
AKS Cluster
├── Node Pools:
│   ├── System Node Pool: Standard_D4s_v5 x 2 노드
│   └── User Node Pool: Standard_D8s_v5 x 3-10 노드 (Auto-scaling)
├── Networking:
│   ├── Azure CNI (VNet 통합)
│   ├── NGINX Ingress + External DNS
│   └── Network Policies (Calico)
├── Security:
│   ├── Azure AD Integration (RBAC)
│   ├── Workload Identity
│   └── Pod Security Standards
└── Monitoring:
    ├── Container Insights
    ├── Prometheus + Grafana
    └── Azure Monitor Alerts
```

**마이그레이션 전략**:
1. **Phase 1**: Static Assets 서비스 → AKS
2. **Phase 2**: API 서버 → AKS
3. **Phase 3**: VMSS 단계적 축소

**기대 효과**:
- 배포 속도 향상 (Blue/Green, Canary 배포)
- 리소스 효율성 (VM 대비 30-40% 비용 절감)
- 멀티 클라우드 준비

---

### 3.4 Azure Container Apps (Serverless Container Platform)

**현재 상태**: ❌ **미배포**

**개선 계획**:
- ACI를 대체하는 더 강력한 서버리스 컨테이너 플랫폼
- Dapr 통합으로 마이크로서비스 간 통신 간소화
- KEDA 기반 이벤트 기반 Auto-scaling

**ACI vs Container Apps 비교**:
| 항목 | ACI | Container Apps |
|:---|:---|:---|
| 사용 사례 | 단일 컨테이너 실행 | 마이크로서비스 앱 |
| Auto-scaling | 수동 | 자동 (KEDA) |
| Ingress | 제한적 | 완벽 지원 |
| Dapr | X | O |

---

### 3.5 Synapse Analytics (빅데이터 분석)

**현재 상태**: ❌ **미배포**

> **참고**: Data Factory는 이미 배포되어 ETL 파이프라인이 운영 중입니다.

**도입 배경**:
- MySQL, CosmosDB에 축적된 데이터를 분석하여 비즈니스 인사이트 도출
- OLTP(MySQL)와 분리된 OLAP 시스템으로 성능 최적화

**구성 계획**:
```
Synapse Analytics
├── Dedicated SQL Pool: 분석용 데이터 웨어하우스
│   └── Star Schema: Fact_Orders, Dim_Users, Dim_Products
├── Serverless SQL Pool: 데이터 레이크 쿼리 (비용 효율)
├── Spark Pool: 대규모 데이터 처리 및 ML
└── Data Integration:
    └── Data Factory → Synapse 데이터 적재 (야간)
```

**활용 사례**:
- 사용자 행동 분석 (구매 패턴, 이탈률, Cohort 분석)
- Azure Machine Learning 연동 (수요 예측, 추천 시스템)
- Power BI 대시보드 구축

---

### 3.6 AI 서비스 연동

**현재 상태**: ❌ **미배포**

**계획 서비스**:
- **Cognitive Services**:
  - Computer Vision: 이미지 자동 태깅, 부적절 콘텐츠 필터링
  - Language Service: 리뷰 감정 분석
  - Translator: 다국어 자동 번역
- **Azure OpenAI Service**:
  - ChatGPT: 고객 지원 챗봇
  - Text Embedding: 상품 추천 시스템

---

### 3.7 CI/CD 파이프라인 구축

**현재 상태**: ❌ **미배포**

> **참고**: Terraform으로 인프라 배포는 자동화되어 있으나, 애플리케이션 코드 배포는 수동입니다.

**구축 계획**:
```
GitHub Actions / Azure DevOps
├── CI (빌드):
│   ├── Unit Tests (pytest, jest)
│   ├── Security Scan (Trivy, Snyk)
│   └── Docker Image → ACR 푸시
├── CD (배포):
│   ├── Staging 환경 배포
│   ├── Smoke Test
│   ├── Production Rolling Update
│   └── Rollback (실패 시)
└── Monitoring:
    └── Application Insights 추적
```

**기대 효과**:
- 코드 → 프로덕션: 2-3일 → 30분
- 배포 오류 90% 감소

---

### 3.8 고급 보안 자동화 (SOAR 고도화)

**현재 상태**: 
- ✅ **Azure Policy**: 기본 정책(HTTPS, Region) 적용 완료
- ✅ **Sentinel**: 기본 탐지 규칙(SSH Brute Force 등) 적용 완료
- ❌ **Advanced SOAR**: 자동 대응(Playbook) 및 포괄적 규정 준수 검사는 미구축

**도입 기술**:
- **Sentinel Playbook (Logic Apps)**: 보안 위협 탐지 시 자동 대응 시나리오 구현
  - 예: 이상 로그인 감지 → AD 계정 임시 차단 → Slack 알림 전송
- **Infrastructure Scanning**: tfsec, Checkov로 Terraform Plan 검증

---

### 3.9 Infrastructure Testing

**현재 상태**: ❌ **미배포**

**도입 기술**:
- **Terratest**: Terraform 모듈 자동 테스트 (Go)
- **Azure Resource Graph Queries**: 배포 후 리소스 검증
- **InSpec**: 규정 준수 자동 검증

---

## 4. 일정 및 우선순위

### 4.1 단기 (1-3개월)
- [x] Front Door WAF 정책 통합 (완료)
- [ ] CI/CD 파이프라인 구축
- [ ] Container Apps 평가 및 ACI 대체 검토

### 4.2 중기 (3-6개월)
- [ ] AKS 클러스터 구축 및 Phase 1 마이그레이션
- [ ] Synapse Analytics 도입
- [x] Azure Policy 및 Sentinel 구축 (기본 완료)

### 4.3 장기 (6-12개월)
- [ ] 완전한 마이크로서비스 전환 (AKS 100%)
- [ ] 멀티 리전 확장 (Japan East, US West)
- [ ] AI 서비스 통합
- [ ] DDoS Protection Standard 검토 (필요 시)
- [ ] VPN Gateway 검토 (하이브리드 클라우드 시)

---

## 5. 결론

현재 아키텍처는 **CosmosDB, Data Factory, Service Bus, Front Door, Bastion 등 핵심 서비스가 이미 배포**되어 견고한 기반을 갖추고 있습니다.

향후 계획은 **WAF 보안 강화, Kubernetes 도입, 데이터 분석, AI/ML**을 통해 **클라우드 네이티브 엔터프라이즈급 플랫폼**으로 진화하는 것을 목표로 합니다.

**핵심 미구현 항목**: Front Door WAF, AKS, Synapse Analytics, CI/CD Pipeline, AI Services
