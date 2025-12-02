# 문서 업데이트 조치 안내

**작성일**: 2025-12-01  
**대상 문서**: `documents/*.md`

---

## 1. 안내 목적

본 문서는 아키텍처 분석 결과를 바탕으로, **단기 및 중기적으로 수행해야 할 문서 업데이트 작업**에 대한 실행 가이드를 제공합니다.

> ✅ **즉시 조치 항목**은 이미 완료되었습니다 (CosmosDB, Data Factory 섹션 추가, 리소스 통계 업데이트).

> **참고**: 이미 구현된 서비스(CosmosDB, Data Factory, Service Bus, Shared Image Gallery, Front Door, Bastion, ACI, ACR 등)에 대한 작업은 본 문서에서 제외되었습니다.

---

## 2. 완료된 작업 (즉시 조치)

### ✅ 2.1 리소스 통계 업데이트
- **파일**: `02_Service_Significance_and_Configuration.md`
- **변경 내용**:
  - Section 2.2 리소스 개수: 56개 → 78개 이상
  - 리소스 타입별 상세 목록 업데이트
  - 최종 검증 일시: 2025-12-01
- **완료일**: 2025-12-01

### ✅ 2.2 CosmosDB 섹션 추가
- **파일**: `02_Service_Significance_and_Configuration.md`
- **추가 위치**: Section 7.3
- **내용**: NoSQL 데이터베이스 기술 배경, SQL API, 일관성 수준, 사용 사례
- **완료일**: 2025-12-01

### ✅ 2.3 Data Factory 섹션 추가
- **파일**: `02_Service_Significance_and_Configuration.md`
- **추가 위치**: Section 7.4
- **내용**: ETL 파이프라인, MySQL 백업 자동화, 모니터링
- **완료일**: 2025-12-01

### ✅ 2.4 CDN Front Door 상세 구성 문서화
- **파일**: `02_Service_Significance_and_Configuration.md`
- **내용**: Front Door vs CDN 비교, WAF 통합 내용, 상세 라우팅 규칙 업데이트
- **완료일**: 2025-12-01

### ✅ 2.5 Connection Guide 확장
- **파일**: `03_Connection_Guide.md` (파일명 `01_Connection_Guide.md`로 확인됨)
- **내용**: Front Door 및 Traffic Manager 접속 테스트 명령 추가
- **완료일**: 2025-12-01

### ✅ 2.6 Traffic Manager 문서화
- **파일**: `02_Service_Significance_and_Configuration.md`
- **내용**: Traffic Manager 도입 배경, Priority 라우팅 설정, HTTPS 모니터링 근거 추가
- **완료일**: 2025-12-01

### ✅ 2.7 Security Center Defender 플랜 문서화
- **파일**: `02_Service_Significance_and_Configuration.md`
- **내용**: 8개 서비스에 대한 Standard Tier 적용 현황 및 탐지 범위 상세화
- **완료일**: 2025-12-01

---

## 3. 단기 조치 안내 (1주일 이내)







## 4. 중기 조치 안내 (향후 1-3개월)



### 📚 4.2 RBAC 권한 매트릭스 작성

**우선순위**: 🟢 **Low**  
**예상 소요 시간**: 4시간  
**파일**: 신규 - `Security_RBAC_Matrix.md`

**작업 내용**:
팀원별 할당된 역할 및 권한 범위 표로 정리

**예시 테이블**:
| 사용자 | 역할 | 범위 | 권한 |
|:---|:---|:---|:---|
| 배하영 (student411) | Virtual Machine Contributor | Resource Group | VM 시작/중지/재시작 |
| 이두경 (student421) | SQL DB Contributor | MySQL Server | DB 생성/삭제, 쿼리 |
| 이하연 (student424) | Network Contributor | VNet | NSG, Route 수정 |
| 정현지 (student426) | Security Admin | Subscription | Security Center 관리 |
| 이기훈 (student420) | Reader | Resource Group | 모든 리소스 조회 |

**확인 명령어**:
```bash
az role assignment list --resource-group 04-t1-www-rg --output table
```

---

### 📚 4.3 재해 복구 시나리오 문서 작성

**우선순위**: 🟢 **Low**  
**예상 소요 시간**: 6시간  
**파일**: 신규 - `Disaster_Recovery_Plan.md`

**작업 내용**:
1. **RTO/RPO 정의**
   - RTO: 서비스 복구 목표 시간 (예: 4시간)
   - RPO: 데이터 손실 허용 시간 (예: 1시간)

2. **시나리오별 복구 절차**:
   - MySQL 데이터 손실: Recovery Services Vault에서 Point-in-Time Restore
   - VMSS 장애: Shared Image Gallery에서 재배포
   - Korea Central 리전 장애: Traffic Manager Failover

3. **테스트 계획**: 분기별 DR 훈련

---

## 5. 작업 우선순위 요약

| 순위 | 작업 | 파일 | 예상 시간 | 마감 권장 |
|:---:|:---|:---|:---:|:---:|
| 1 | RBAC 매트릭스 | Security_RBAC_Matrix.md | 4h | D+30 |
| 2 | 재해 복구 계획 | Disaster_Recovery_Plan.md | 6h | D+60 |
| - | CDN Front Door 상세화 | 02_Service_Configuration.md | - | **완료** |
| - | Connection Guide 확장 | 03_Connection_Guide.md | - | **완료** |
| - | Traffic Manager 문서화 | 02_Service_Configuration.md | - | **완료** |
| - | Security Defender 전체 | 02_Service_Configuration.md | - | **완료** |

---

## 6. 참고 명령어 및 리소스

### 6.1 Terraform State 확인
```bash
# 특정 리소스 상세 조회
terraform state show module.database.azurerm_cosmosdb_account.cosmos

# Front Door 리소스 목록
terraform state list | grep frontdoor

# Traffic Manager 상세
terraform state show azurerm_traffic_manager_profile.www_tm
```

### 6.2 Azure CLI로 리소스 구성 확인
```bash
# Front Door Endpoint
az network front-door endpoint show \
  --resource-group 04-t1-www-rg \
  --profile-name <frontdoor-profile> \
  --endpoint-name <endpoint-name>

# Traffic Manager 확인
az network traffic-manager profile show \
  --resource-group 04-t1-www-rg \
  --name www-tm

# CosmosDB 상세
az cosmosdb show \
  --resource-group 04-t1-www-rg \
  --name <cosmosdb-account-name>
```

---

## 7. 문의 사항

문서 업데이트 중 불명확한 부분:
1. Terraform tfstate 재확인
2. Azure Portal에서 리소스 직접 확인
3. 팀 리드에게 문의

**중요**: 문서 정확성이 최우선입니다. 불확실한 내용은 "확인 필요" 표시 후 검증하세요.
