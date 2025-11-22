# Azure Infrastructure 계층별 아키텍처

> **최종 업데이트**: 2025-11-22  
> 이 문서는 현재 구축된 Azure 인프라의 계층별 아키텍처와 연결 흐름을 시각화합니다.

---

## 1. 전체 아키텍처 개요 (High-Level Overview)

```mermaid
graph TD
    User[사용자 / 관리자] -->|HTTP (80)| LB[Load Balancer (Public IP)]
    User -->|SSH (22)| Bastion[Bastion Host (Public IP)]
    
    subgraph "Azure Cloud (Korea Central)"
        subgraph "VNet0 (10.0.0.0/16)"
            direction TB
            Bastion -->|SSH (22)| VM[Source VM]
            LB -->|HTTP (80)| VMSS[VM Scale Set (Web Servers)]
            VMSS -->|Private Link| DB[(MySQL Primary)]
            DB -.->|동일 리전 복제| Replica[(MySQL Replica)]
            VMSS -->|Private Link| Storage[Storage Account]
            VM -->|이미지 생성| Gallery[Image Gallery]
            Gallery -->|배포| VMSS
        end
    end
    
    subgraph "Azure Cloud (Korea South)"
        subgraph "VNet1 (192.168.0.0/16)"
            DR_Zone[DR Zone (Reserved)]
        end
    end
    
    VNet0 <-->|VNet Peering| VNet1
    
    Storage -.->|연동 (비활성)| CDN[Azure CDN]
    CDN -.->|빠른 전송| User
```

---

## 2. 계층별 상세 연결 흐름 (Layered Connectivity)

### 2.1. Access Layer (접근 계층)
- **Bastion Host**: 외부 관리자가 내부 리소스에 안전하게 접근하기 위한 점프 호스트
- **Load Balancer**: 외부 사용자 트래픽을 VMSS 인스턴스로 분산

### 2.2. Compute Layer (컴퓨팅 계층)
- **Source VM**: WordPress 설치 및 설정용 관리 VM
- **Image Gallery**: Source VM에서 생성한 이미지 저장소
- **VM Scale Set (VMSS)**: 웹 애플리케이션을 실행하는 가상 머신 그룹 (자동 확장 가능)

### 2.3. Security Layer (보안 계층)
- **NSG (Network Security Group)**:
  - `AllowSSH`: Bastion 및 특정 IP에서의 SSH 접근 허용
  - `AllowHTTP/HTTPS`: 인터넷에서의 웹 트래픽 허용
  - `DenyMySQL`: 외부에서의 직접적인 DB 접근 차단

### 2.4. Data Layer (데이터 계층)
- **MySQL Flexible Server**: 주 데이터베이스 (Korea Central)
- **Private Endpoint**: VNet 내부 IP를 통해 DB에 안전하게 접속
- **Private DNS Zone**: `privatelink.mysql.database.azure.com`을 통해 호스트 이름 해석
- **MySQL Replica**: 읽기 전용 복제본 (Korea Central, 동일 리전 구성)
- **Redis Cache**: 고성능 캐싱 레이어 (활성화됨)

### 2.5. Storage Layer (스토리지 계층)
- **Storage Account**: 미디어 파일 및 Terraform State 저장
  - 복제 방식: **GRS (Geo-Redundant Storage)**
  - Lifecycle Policy 적용 (30일 → Cool, 90일 → Archive, 365일 → 삭제)
- **CDN**: Front Door를 통한 글로벌 배포 (활성화됨)

---

## 3. 네트워크 분리 및 보안 (Network Segmentation & Security)

| VNet | Region | Address Space | 역할 |
|---|---|---|---|
| **VNet0** | Korea Central | `10.0.0.0/16` | **메인 서비스 존** (Web, App, DB Primary/Replica) |
| **VNet1** | Korea South | `192.168.0.0/16` | **DR / 백업 존** (Network Peering 연결) |

**보안 특징**:
- ✅ **VNet Peering**: 서로 다른 리전/IP 대역 간의 안전한 사설 통신 보장
- ✅ **NSG**: 서브넷 레벨에서 트래픽 제어 (Web Subnet, DB Subnet 등)
- ✅ **Private Endpoint**: DB와 Storage는 Public IP 없이 VNet 내부에서만 접근
- ✅ **Bastion**: SSH 접근을 위한 전용 관리 호스트 (점프 서버)
- `admin_username` 기본값 변경: `azureuser` → `wwwuser`

---

## 5. 데이터 흐름 (Data Flow)

### 5.1. 사용자가 글 작성 시
```
1. 웹 서버 ──> Redis 캐시 확인
2. 웹 서버 ──> Private Endpoint ──> MySQL (글 저장)
3. MySQL ──────────────────────────> Replica (자동 복제)
4. 웹 서버 ──> Redis (캐시 업데이트)
```

### 5.2. 사용자가 이미지 업로드 시
```
1. 웹 서버 ──> Private Endpoint ──> Storage Account (파일 저장)
2. Storage ──────────────────────> CDN (전 세계 배포)
3. 사용자 ──> CDN Edge 서버 (빠른 다운로드)
```

---

## 5. 확장 로드맵

자세한 내용은 [`Module_Scalability.md`](./Module_Scalability.md)를 참조하세요.

**단기 확장 우선순위**:
1. Redis Cache 활성화 →성능 10배 향상
2. CDN 활성화 → 글로벌 속도 개선
3. Auto-Scaling 설정 → 트래픽 변화 대응

---

**작성일**: 2025-11-22  
**버전**: 2.0 (모듈 재구성 반영)
