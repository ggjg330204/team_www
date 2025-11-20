# 🛡️ 백업 및 복구 정책서 (Backup & Recovery Policy)

이 문서는 시스템 장애, 데이터 손실, 재해 발생 시 데이터의 안전한 보호와 신속한 복구를 보장하기 위한 정책을 정의합니다.

## 1. 개요
*   **대상 시스템**: Azure Database for MySQL Flexible Server, Azure Storage Account
*   **책임자**: 데이터 엔지니어 (Data Engineer)
*   **목적**: 비즈니스 연속성 보장 및 데이터 손실 최소화

## 2. 복구 목표 (SLA)

| 항목 | 목표치 | 설명 |
| :--- | :--- | :--- |
| **RPO (Recovery Point Objective)** | **1시간 이내** | 사고 발생 시 최대 1시간 전 데이터까지만 유실 허용 |
| **RTO (Recovery Time Objective)** | **4시간 이내** | 사고 발생 후 4시간 이내에 서비스 정상화 |

## 3. 백업 정책 (Backup Policy)

### 3.1 데이터베이스 (MySQL)
*   **백업 방식**: 자동화된 스냅샷 백업 (Automated Backup)
*   **백업 주기**: 매일 (Daily)
*   **보관 기간 (Retention)**: **35일** (최대 설정)
*   **이중화**: **Geo-Redundant** (한국 중부 -> 한국 남부 복제)
*   **복구 시점**: 특정 시점 복구 (PITR, Point-In-Time Restore) 가능

### 3.2 스토리지 (Storage Account)
*   **대상**: `media` 컨테이너 (이미지, 영상 등)
*   **백업 방식**:
    1.  **Soft Delete (일시 삭제)**: 실수로 삭제한 파일을 7일간 보관 후 영구 삭제.
    2.  **Versioning (버전 관리)**: 파일 덮어쓰기 시 이전 버전을 자동 저장.
*   **복제**: **LRS** (로컬 이중화) - *필요 시 GRS로 승격 검토*

## 4. 재해 복구 절차 (DR Plan)

### 상황 A: 실수로 데이터 삭제 (Human Error)
1.  **DB**: Azure Portal에서 'Restore' 기능 사용 -> 사고 발생 5분 전 시점으로 새 서버 생성 -> 연결 문자열 변경.
2.  **Storage**: 'Undelete' 기능으로 삭제된 Blob 복구.

### 상황 B: 한국 중부 리전 전체 장애 (Region Failure)
1.  **DB**: 한국 남부(Korea South)에 있는 **Read Replica**를 **Primary**로 승격 (Promote).
2.  **App**: 웹 서버 설정을 변경하여 승격된 남부 DB를 바라보게 수정.
3.  **Storage**: (GRS 사용 시) Microsoft가 주도하여 남부 리전으로 Failover 수행.

## 5. 정기 점검
*   **복구 훈련**: 분기별 1회, 실제 복구 시나리오 테스트 수행.
*   **백업 확인**: 매주 월요일 백업 성공 여부 모니터링 대시보드 확인.
