# 📈 모니터링 대시보드 가이드 (Monitoring Guide)

이 문서는 **Azure Monitor**를 활용하여 시스템의 건강 상태를 실시간으로 감시하고, 이상 징후를 조기에 발견하기 위한 가이드입니다.

## 1. 모니터링 대상 및 주요 지표

### 1.1 데이터베이스 (MySQL Flexible Server)
| 지표명 (Metric) | 설명 | 위험 임계값 (Alert Threshold) | 조치 사항 |
| :--- | :--- | :--- | :--- |
| **CPU Percent** | CPU 사용률 | **> 80%** (5분 지속) | 슬로우 쿼리 확인, 스펙 업그레이드 검토 |
| **Memory Percent** | 메모리 사용률 | **> 85%** | 캐시(Redis) 도입 검토, 커넥션 누수 확인 |
| **Active Connections** | 활성 접속자 수 | **> 80%** (Max 대비) | 좀비 커넥션 정리, Connection Pooling 적용 |
| **Storage Percent** | 디스크 사용률 | **> 90%** | 불필요한 데이터 삭제, 스토리지 자동 확장 확인 |
| **IOPS** | 초당 입출력 횟수 | **> 95%** (Max 대비) | 고성능 IOPS 스토리지로 변경 |

### 1.2 스토리지 (Storage Account)
| 지표명 (Metric) | 설명 | 위험 임계값 | 조치 사항 |
| :--- | :--- | :--- | :--- |
| **Used Capacity** | 사용 용량 | **> 80%** (예산 대비) | 수명주기 정책(Lifecycle) 점검 |
| **Availability** | 가용성 (성공률) | **< 99.9%** | Azure 상태 확인, 네트워크 문제 점검 |
| **E2E Latency** | 응답 속도 | **> 500ms** | CDN 적용 검토, 파일 크기 최적화 |

### 1.3 Redis Cache
| 지표명 (Metric) | 설명 | 위험 임계값 | 조치 사항 |
| :--- | :--- | :--- | :--- |
| **Server Load** | 서버 부하 | **> 80%** | 스케일 업(Scale Up) 또는 샤딩 검토 |
| **Evicted Keys** | 메모리 부족으로 삭제된 키 | **> 0** | 메모리 용량 증설 필요 |

## 2. 알림 설정 (Alert Rules)

### 🚨 P1: 긴급 (Critical) - 즉시 대응 필요
*   **채널**: Slack (#ops-emergency), SMS, 전화
*   **조건**:
    *   DB 접속 불가 (Availability < 100%)
    *   DB CPU > 95% (10분 지속)
    *   스토리지 다운

### ⚠️ P2: 경고 (Warning) - 업무 시간 내 확인
*   **채널**: Slack (#ops-monitoring), Email
*   **조건**:
    *   DB CPU > 80%
    *   스토리지 용량 > 80%
    *   백업 실패 로그 발생

## 3. 대시보드 구성 예시 (Grafana / Azure Dashboard)

1.  **상단 (Summary)**: 전체 서비스 상태 (초록/빨강 신호등 표시)
2.  **중단 (Database)**: CPU, Memory, Connection 그래프 (지난 1시간)
3.  **하단 (Storage/Redis)**: 트래픽 추이, 캐시 적중률(Hit Rate) 그래프
