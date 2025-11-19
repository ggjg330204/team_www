# 🔐 접근 제어 명세서 (Access Control Specification)

이 문서는 인프라 리소스에 대한 **접근 권한(Identity)**과 **네트워크 보안(Network Security)** 정책을 정의하여 무단 접근을 차단하고 데이터를 보호합니다.

## 1. 네트워크 접근 제어 (Network Security)

### 1.1 기본 원칙
*   **Deny All First**: 명시적으로 허용되지 않은 모든 트래픽은 차단한다.
*   **Private Access**: 데이터베이스와 스토리지는 **Private Endpoint**를 통해서만 접근한다. (Public Access 차단)

### 1.2 리소스별 정책

| 리소스 | 접근 허용 대상 | 방식 | 포트 |
| :--- | :--- | :--- | :--- |
| **MySQL DB** | Web Server Subnet | Private Endpoint | 3306 |
| **Storage** | Web Server Subnet, CDN | Private Endpoint | 443 (HTTPS) |
| **Redis** | Web Server Subnet | Private IP | 6380 (SSL) |
| **Bastion** | 관리자 PC (지정 IP) | Public IP (NSG) | 22 (SSH) |

## 2. 사용자 권한 관리 (RBAC - Role Based Access Control)

Azure AD(Entra ID)를 기반으로 역할별 권한을 부여합니다.

### 2.1 역할 정의

| 역할 (Role) | 대상 | 권한 범위 | 할당 리소스 |
| :--- | :--- | :--- | :--- |
| **Owner** | 팀장 (PM) | 모든 리소스 생성/삭제/권한 관리 | Subscription 전체 |
| **Contributor** | 데이터 엔지니어 | 모든 리소스 생성/수정 (권한 관리 제외) | Resource Group (Data/Storage) |
| **Reader** | 신입/인턴 | 리소스 조회 및 모니터링 (수정 불가) | Resource Group 전체 |
| **DB Admin** | 시니어 개발자 | DB 내부 계정 관리 및 스키마 변경 | MySQL Server |

## 3. 데이터베이스 계정 관리

*   **Admin 계정**: 테라폼으로 생성하며, 평소에는 사용하지 않음. (비상용)
*   **App 계정**: 웹 애플리케이션(WordPress) 전용 계정. 필요한 권한(`SELECT`, `INSERT`, `UPDATE`, `DELETE`)만 부여.
*   **Analyst 계정**: 데이터 분석가용 계정. `SELECT` 권한만 부여 (Read Only).

## 4. 감사 및 로깅 (Auditing)

*   **Activity Log**: 누가 언제 리소스를 변경했는지 기록 (Azure 기본 제공).
*   **DB Audit Log**: 누가 어떤 쿼리를 실행했는지 기록 (스토리지에 보관).
*   **Access Log**: 스토리지 파일 접근 기록 보관.
