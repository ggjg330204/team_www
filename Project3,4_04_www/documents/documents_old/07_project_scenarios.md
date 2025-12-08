# 프로젝트 주제 및 시나리오 정의

## 1. 프로젝트 주제
**"제로 트러스트 기반 보안 클라우드 애플리케이션 플랫폼 및 지능형 위협 대응 시스템 구축"**
(Zero Trust-based Secure Cloud Application Platform & Intelligent Threat Response System)

이 프로젝트는 기존의 하이브리드 클라우드 인프라 위에 **데이터 및 애플리케이션 중심의 보안(Data & App Security)**을 강화하고, **지능형 위협 탐지 및 자동화된 대응(SecOps)** 체계를 구축하여 안전하고 탄력적인 클라우드 서비스를 완성하는 것을 목표로 합니다.

---

## 2. 시나리오 상세 (총 60개)

### 가. 아키텍처 검증 (Architecture Verification)
기존 구축된 인프라의 고가용성(HA), 성능, 연결성을 검증합니다.

1.  **Web/WAS VMSS 오토스케일링 검증 (Stress Test)**
    *   **내용:** `stress-ng` 등의 도구로 CPU 부하를 인위적으로 발생시켜 VM 인스턴스가 자동으로 증가(Scale-out)하고, 부하 제거 시 감소(Scale-in)하는지 확인.
2.  **MySQL Flexible Server 고가용성(HA) Failover 테스트**
    *   **내용:** Primary DB를 강제로 중지하거나 Failover를 트리거하여 Standby DB로 즉시 전환되는지, 서비스 중단 시간이 얼마나 되는지 측정.
3.  **MySQL Read Replica 데이터 복제 지연 확인**
    *   **내용:** Primary DB에 대량의 데이터를 Insert하고 Read Replica에 반영되기까지의 지연 시간(Replication Lag)을 모니터링.
4.  **Redis Cache 연결 및 성능 테스트**
    *   **내용:** WAS에서 Redis Cache에 데이터를 Write/Read 하여 정상 동작을 확인하고, 캐시 적용 전후의 응답 속도 비교.
5.  **Traffic Manager 라우팅 및 장애 조치 검증**
    *   **내용:** 주(Primary) 엔드포인트를 비활성화했을 때 Traffic Manager가 보조(Secondary) 엔드포인트로 트래픽을 정상적으로 라우팅하는지 확인.
6.  **Application Gateway WAF 차단 검증**
    *   **내용:** 웹 브라우저나 Curl을 통해 기본적인 SQL Injection(`' OR 1=1 --`) 및 XSS 공격 구문을 전송하여 WAF가 403 Forbidden으로 차단하는지 확인.
7.  **Private Endpoint 연결성 검증**
    *   **내용:** Public 접근이 차단된 Storage Account나 DB에 대해, VNet 내부의 VM에서 Private IP(DNS)를 통해 정상적으로 접근 가능한지 확인.
8.  **Azure Bastion 접속 및 세션 유지 테스트**
    *   **내용:** Bastion을 통해 Private Subnet의 VM에 SSH 접속을 수행하고, 안정적인 세션 연결 및 파일 전송(필요 시) 가능 여부 확인.
9.  **NAT Gateway 아웃바운드 연결 확인**
    *   **내용:** Private Subnet의 VM에서 외부 인터넷(예: `apt-get update`)으로 나가는 트래픽이 NAT Gateway의 공인 IP를 타고 나가는지 확인.
10. **VM 장애 복구 및 Health Probe 확인**
    *   **내용:** 로드밸런서 백엔드 풀의 특정 VM 웹 서비스를 중지시켰을 때, Health Probe가 이를 감지하여 트래픽을 차단하는지 확인.
11. **L4 Load Balancer 부하 분산 확인**
    *   **내용:** 다수의 클라이언트에서 요청을 보낼 때 트래픽이 백엔드 풀의 VM들에 고르게 분산되는지 확인 (세션 지속성 설정 확인).
12. **VMSS 수동 스케일링**
    *   **내용:** 자동이 아닌 수동으로 인스턴스 수를 5개로 늘렸을 때 즉시 반영되는지 확인.
13. **Storage Account GRS(Geo-Redundant) 확인**
    *   **내용:** 보조 지역(Secondary Region)으로 데이터가 복제되고 있는지 설정 및 상태 확인 (Failover 테스트는 주의 필요).
14. **Azure Function 트리거 동작 테스트**
    *   **내용:** Blob 스토리지에 파일을 업로드했을 때 Function이 자동으로 실행되어 로그를 남기거나 DB를 업데이트하는지 확인.
15. **Service Bus 메시지 큐 처리**
    *   **내용:** Service Bus에 메시지를 보내고, WAS(또는 로직 앱)가 이를 정상적으로 수신하여 처리하는지 확인.
16. **ACR(Azure Container Registry) 이미지 풀 테스트**
    *   **내용:** VM 또는 ACI에서 Private ACR에 로그인하여 이미지를 정상적으로 Pull 할 수 있는지 확인.
17. **내부 DNS 해석(Name Resolution) 검증**
    *   **내용:** Private Endpoint를 사용하는 리소스(DB, Storage)의 도메인 이름이 내부 IP로 정상적으로 해석되는지 `nslookup`으로 확인.
18. **Hub-Spoke 네트워크 지연 시간(Latency) 측정**
    *   **내용:** Hub VNet의 Bastion과 Spoke VNet의 VM 간 핑(Ping) 또는 연결 테스트로 네트워크 지연 측정.
19. **App Gateway SSL/TLS 오프로딩 및 정책 확인**
    *   **내용:** HTTPS로 접속 시 인증서가 유효한지, 그리고 최소 TLS 버전(1.2)이 강제되는지 확인.
20. **VM 백업 및 복구 테스트 (Azure Backup)**
    *   **내용:** 특정 VM을 백업하고, 파일을 삭제한 뒤 백업본에서 파일 또는 VM 전체를 복원해보기.

#### 💡 Lupang 쇼핑몰 기반 추가 시나리오

21. **Lupang 쇼핑몰 동시 접속자 부하 테스트**
    *   **내용:** `ab` (Apache Bench) 또는 JMeter로 `/index.php`에 100명 이상 동시 접속 시뮬레이션하여 응답 시간 및 처리량 측정.
22. **Lupang DB 연결 풀(Connection Pool) 고갈 테스트**
    *   **내용:** 대량의 상품 조회 요청을 보내 MySQL 연결 수가 한계에 도달했을 때의 에러 처리 및 복구 확인.
23. **상품 이미지 CDN 전송 속도 비교**
    *   **내용:** Storage Account에 저장된 상품 이미지를 Front Door CDN을 통해 전송할 때와 직접 전송할 때의 응답 속도 차이 측정.
24. **Lupang 로그 파일(`/var/log/lupang_app.log`) 수집 확인**
    *   **내용:** Application Insights 또는 Log Analytics에 Lupang 애플리케이션 로그가 정상적으로 수집되고 검색 가능한지 확인.
25. **세션 지속성(Session Affinity) 테스트**
    *   **내용:** 로그인 후 쿠키(`lupang_token`)가 있을 때, 로드밸런서가 동일 백엔드 서버로 요청을 라우팅하는지 확인.
26. **Lupang 상품 업로드 시 Storage 자동 저장 확인**
    *   **내용:** 상품 이미지를 업로드했을 때 `/var/www/html/uploads`와 Azure Storage Account 양쪽에 정상 저장되는지 확인.
27. **Apache 웹서버 재시작 시 서비스 중단 시간 측정**
    *   **내용:** 특정 WAS VMSS 인스턴스의 Apache를 재시작할 때 로드밸런서가 트래픽을 다른 인스턴스로 우회시키는 시간 측정.
28. **Lupang 검색 기능(`search.php`) 응답 속도 테스트**
    *   **내용:** 다양한 검색 쿼리를 보내고 DB 인덱스 유무에 따른 응답 속도 차이 비교.
29. **HTTP에서 HTTPS로 자동 리디렉션 확인**
    *   **내용:** `http://04www.cloud`로 접속 시 Application Gateway가 자동으로 `https://`로 리디렉션하는지 확인.
30. **Lupang DB 데이터 실시간 복제(Read Replica) 일관성 검증**
    *   **내용:** Primary DB에 새 상품을 추가하고, Read Replica에서 즉시 조회 가능한지 확인 (복제 지연 측정).

---

### 나. 내부 보안 (Internal Security - Project 3)
데이터 보호, 접근 제어, 애플리케이션 보안 설정을 검증합니다.

1.  **Entra ID (Azure AD) RBAC 권한 분리**
    *   **내용:** 사용자 A에게는 'Reader' 권한, 사용자 B에게는 'Contributor' 권한을 부여하여 리소스 생성/수정 가능 여부 차이 검증.
2.  **Azure Policy 리소스 생성 제한**
    *   **내용:** 'Korea Central' 리전 외에는 리소스 생성을 금지하거나, 특정 태그가 없는 리소스 생성을 거부하는 정책을 할당하고 위반 시도 테스트.
3.  **Key Vault 비밀(Secret) 관리 및 연동**
    *   **내용:** DB 접속 문자열이나 API Key를 Key Vault에 저장하고, 애플리케이션(VM/App Service)이 Managed Identity를 통해 이를 안전하게 가져오는지 확인.
4.  **Storage Account SAS(Shared Access Signature) 보안**
    *   **내용:** 특정 IP 대역에서만 접근 가능하거나, 읽기 권한만 있는 SAS 토큰을 생성하여 제한된 접근 권한이 작동하는지 테스트.
5.  **Azure SQL Database TDE 및 데이터 마스킹**
    *   **내용:** TDE(투명한 데이터 암호화) 활성화 상태를 확인하고, 민감한 컬럼(주민번호, 전화번호 등)에 동적 데이터 마스킹을 적용하여 조회 시 가려지는지 확인.
6.  **DB 방화벽 및 VNet 규칙 설정**
    *   **내용:** Azure SQL Server의 방화벽 설정에서 'Azure 서비스 및 리소스에서 이 서버에 액세스하도록 허용'을 끄고, 특정 VNet/Subnet에서만 접근되도록 설정 검증.
7.  **Managed Identity(관리 ID) 활용**
    *   **내용:** VM에 시스템 할당 관리 ID를 부여하고, 이를 사용하여 코드 내 자격 증명(ID/PW) 하드코딩 없이 Azure 리소스(Storage 등)에 접근하는지 확인.
8.  **NSG(네트워크 보안 그룹) Flow Logs 분석**
    *   **내용:** Network Watcher를 통해 NSG Flow Logs를 활성화하고, 특정 트래픽의 허용/거부 로그가 Storage Account에 저장되는지 확인.
9.  **Azure Disk Encryption (ADE) 적용**
    *   **내용:** VM의 OS 디스크 및 데이터 디스크를 암호화(BitLocker/DM-Crypt)하고, 암호화 상태를 포털 또는 CLI로 검증.
10. **데이터베이스 시점 복원 (PITR)**
    *   **내용:** DB 데이터를 일부 삭제하거나 변경한 후, 변경 이전 시점으로 데이터베이스를 복원(Restore)하여 데이터 무결성 회복 확인.
11. **조건부 액세스(Conditional Access) 정책 - MFA 강제**
    *   **내용:** 관리자 계정 로그인 시 다단계 인증(MFA)을 요구하도록 설정하고 테스트 (라이선스 확인 필요, 불가 시 보안 기본값 사용).
12. **사용자 지정 RBAC 역할 생성 및 할당**
    *   **내용:** 'VM 재부팅만 가능한' 커스텀 역할을 만들고 사용자에게 할당하여 권한 범위를 검증.
13. **Resource Lock(자원 잠금) 설정**
    *   **내용:** 중요한 리소스(예: 운영 DB)에 '삭제 방지(CanNotDelete)' 락을 걸고 삭제 시도 시 차단되는지 확인.
14. **ACR 취약점 스캔 (Defender for Containers)**
    *   **내용:** 컨테이너 이미지를 ACR에 푸시하고, Defender가 이미지의 취약점을 스캔하여 리포트하는지 확인.
15. **Key Vault 키 자동 회전(Rotation) 시뮬레이션**
    *   **내용:** Key Vault의 암호화 키 버전을 업데이트하고, 애플리케이션이 중단 없이 새 키를 사용하는지(또는 수동 갱신 절차) 확인.
16. **SQL Database 감사(Auditing) 로그 확인**
    *   **내용:** DB에 대한 모든 쿼리 내역을 Storage Account로 저장하도록 설정하고, 실제 쿼리 로그가 남는지 확인.
17. **JIT(Just-In-Time) VM 액세스**
    *   **내용:** Defender for Cloud를 통해 관리 포트(22/3389)를 평소에는 닫아두고, 요청 시에만 한시적으로 여는 기능 테스트.
18. **파일 무결성 모니터링(FIM)**
    *   **내용:** VM의 중요 설정 파일(/etc/passwd 등)이 변경되었을 때 Defender가 이를 감지하는지 확인.
19. **Subnet 간 NSG 차단 검증**
    *   **내용:** App Subnet에서 Data Subnet의 DB 포트(3306) 외에 다른 포트(SSH 등)로 접근 시도 시 NSG가 차단하는지 확인.
20. **Purview 정보 보호 레이블 적용**
    *   **내용:** 문서나 데이터에 '기밀(Confidential)' 레이블을 적용하고, 해당 레이블에 따른 보호 정책이 동작하는지 확인.

#### 💡 Lupang 쇼핑몰 기반 추가 시나리오 (인증 토큰 보안 중심)

21. **Lupang 인증 토큰(lupang_token) 탈취 및 재사용 방지**
    *   **내용:** 쿠키의 Base64 인코딩된 토큰을 디코딩하여 내용을 확인하고, Key Vault에 저장된 서명 키로 JWT 토큰 방식으로 전환하여 위변조 방지 구현.
22. **SQL Injection 공격 차단 (login.php)**
    *   **내용:** 로그인 페이지에서 `' OR '1'='1` 같은 SQL Injection 공격 시도 시 Prepared Statement로 차단되는지 확인 및 WAF 로그 분석.
23. **SQL Injection 공격 차단 (product.php, mypage.php)**
    *   **내용:** `product.php?id=1 OR 1=1`, `mypage.php` 등에서 SQL Injection을 시도하고, 취약점 존재 시 Prepared Statement로 수정 후 재검증.
24. **XSS(Cross-Site Scripting) 공격 차단 (search.php)**
    *   **내용:** 검색어에 `<script>alert('XSS')</script>` 입력 시 WAF가 차단하거나 output sanitization으로 무해화되는지 확인.
25. **파일 업로드 취약점 검증 (uploads 디렉토리)**
    *   **내용:** PHP 웹쉘 파일을 `/var/www/html/uploads`에 업로드 시도하고, 확장자 필터링 및 실행 권한 제거로 방어되는지 확인.
26. **세션 하이재킹(Session Hijacking) 방지**
    *   **내용:** 다른 사용자의 `lupang_token` 쿠키를 복사하여 사용 시, IP 주소 또는 User-Agent 검증으로 차단되는지 테스트.
27. **관리자 권한 우회 시도 탐지 (role 조작)**
    *   **내용:** 일반 사용자의 토큰을 디코딩하여 `role: admin`으로 변조 후 재인코딩하여 사용 시, 서버 측에서 검증 실패하는지 확인.
28. **CSRF(Cross-Site Request Forgery) 공격 방지**
    *   **내용:** 외부 사이트에서 Lupang의 상품평 작성 Form을 Submit 시도할 때 CSRF 토큰이 없으면 차단되도록 구현 및 검증.
29. **민감한 정보 노출 방지 (DB 비밀번호)**
    *   **내용:** `db_config.php`에 하드코딩된 DB 비밀번호를 Key Vault로 이동하고, Managed Identity를 통해 안전하게 가져오도록 개선.
30. **Lupang 애플리케이션 로그 암호화 및 접근 제어**
    *   **내용:** `/var/log/lupang_app.log`에 민감 정보(비밀번호 시도 등)가 평문으로 기록되지 않도록 마스킹 처리하고, 파일 권한을 root만 읽을 수 있게 설정.

---

### 다. 외부 보안 (External Security - Project 4)
위협 탐지, 로그 분석, 자동화된 대응(SOAR)을 검증합니다.

1.  **Microsoft Sentinel 데이터 커넥터 연결**
    *   **내용:** Azure Activity Log, VM Security Event 등을 Sentinel에 연결하고 로그 데이터가 Log Analytics Workspace에 수집되는지 확인.
2.  **SSH Brute Force 공격 탐지**
    *   **내용:** 외부(공격자 VM)에서 내부 VM으로 무작위 SSH 로그인 시도를 수행하고, Sentinel에서 이를 탐지하여 경고(Alert)를 생성하는지 확인.
3.  **악성 IP 통신 탐지 (Threat Intelligence)**
    *   **내용:** 위협 인텔리전스(TI) 피드에 등록된 악성 IP(테스트용)와 통신을 시도하고, Sentinel이 이를 탐지하는지 확인.
4.  **KQL(Kusto Query Language) 기반 위협 분석**
    *   **내용:** 특정 시간 동안 실패한 로그인 시도가 10회 이상인 계정을 추출하는 KQL 쿼리를 작성하고 실행하여 결과 확인.
5.  **Defender for Cloud (CSPM) 보안 권고 사항 확인**
    *   **내용:** Defender for Cloud를 활성화하고, 현재 인프라의 보안 점수(Secure Score)와 취약점 권고 사항(예: MFA 미설정, 포트 개방 등)을 확인.
6.  **VM 멀웨어 탐지 시뮬레이션 (EICAR)**
    *   **내용:** VM 내에 EICAR 테스트 파일을 다운로드하여 Defender for Servers가 이를 악성코드로 탐지하고 격리/알림을 보내는지 확인.
7.  **Sentinel 분석 규칙(Analytics Rule) 생성**
    *   **내용:** "중요한 파일 삭제" 또는 "비정상적인 시간대의 로그인" 등 사용자 지정 탐지 규칙을 생성하고 트리거 조건 테스트.
8.  **SOAR 자동화 대응 (Logic App Playbook)**
    *   **내용:** Sentinel에서 특정 경고(Alert) 발생 시, 자동으로 관리자에게 Teams 메시지나 이메일을 발송하는 Logic App을 만들고 실행 확인.
9.  **의심스러운 프로세스 실행 탐지**
    *   **내용:** VM에서 코인 채굴기나 해킹 도구로 의심되는 프로세스(모의)를 실행하고, Defender 또는 Sentinel에서 이를 탐지하는지 확인.
10. **보안 사고(Incident) 조사 및 종결**
    *   **내용:** 생성된 보안 사고(Incident)에 대해 Sentinel 조사 그래프(Investigation Graph)를 통해 공격의 흐름을 분석하고, 조치 후 사고 상태를 'Closed'로 변경.
11. **DDoS 공격 시뮬레이션 (Basic)**
    *   **내용:** `hping3` 등을 이용해 대량의 패킷을 전송하고, Azure DDoS Protection(Basic) 또는 방화벽/NSG에서의 처리 확인 (서비스 다운 여부 모니터링).
12. **데이터 유출(Data Exfiltration) 시도 탐지**
    *   **내용:** 내부 VM에서 허용되지 않은 외부 IP(C&C 서버 가정)로 대용량 데이터를 전송 시도하고 탐지 여부 확인.
13. **웹쉘(Web Shell) 업로드 및 실행 차단**
    *   **내용:** 웹 게시판 등에 웹쉘 파일(php, jsp 등) 업로드를 시도하고 WAF나 백신이 차단하는지 확인.
14. **권한 상승(Privilege Escalation) 시도**
    *   **내용:** 일반 사용자로 로그인하여 `sudo` 권한 획득을 시도하거나, 시스템 파일 접근을 시도하여 로그에 남는지 확인.
15. **포트 스캐닝(Port Scanning) 탐지**
    *   **내용:** 외부에서 공인 IP를 대상으로 Nmap 스캔을 수행하고, Sentinel이나 방화벽 로그에 스캔 행위가 기록되는지 확인.
16. **랜섬웨어 행위 모의 실험**
    *   **내용:** 특정 폴더의 파일들을 대량으로 암호화하거나 확장자를 변경하는 스크립트를 실행하고, 엔드포인트 보안 솔루션(Defender) 반응 확인.
17. **불가능한 여행(Impossible Travel) 로그인**
    *   **내용:** 짧은 시간 내에 물리적으로 이동 불가능한 두 지역(예: 한국, 미국)에서 동일 계정으로 로그인 시도 (VPN 활용).
18. **로그 삭제/변조 시도 탐지**
    *   **내용:** 공격자가 침입 흔적을 지우기 위해 시스템 로그(syslog, event log)를 삭제하거나 서비스를 중지하려는 행위 탐지.
19. **알려진 취약점(CVE) 익스플로잇 시도**
    *   **내용:** 웹 서버나 OS의 알려진 취약점(패치 안 된 버전 가정)에 대한 공격 코드를 전송하고 탐지 여부 확인.
20. **비정상적인 프로세스/서비스 등록 탐지**
    *   **내용:** 백도어 역할을 하는 서비스를 레지스트리나 systemd에 등록하려는 시도를 탐지.

#### 💡 Lupang 쇼핑몰 기반 추가 시나리오 (공격 탐지 및 대응)

21. **Lupang 로그인 Brute Force 공격 탐지 (KQL 쿼리)**
    *   **내용:** `/var/log/lupang_app.log`에서 "Login Failed" 로그가 3분 내 10회 이상 발생한 IP를 추출하는 KQL 쿼리 작성 및 Alert 생성.
22. **SQL Injection 공격 시도 자동 탐지 및 차단**
    *   **내용:** WAF 또는 Sentinel에서 `' OR 1=1`, `UNION SELECT` 같은 SQL Injection 패턴을 탐지하여 즉시 IP를 NSG에 자동 차단하는 Playbook 구현.
23. **관리자 권한 무단 접근 탐지 (DB Dump 버튼 클릭)**
    *   **내용:** Mypage에서 "전체 회원 목록 다운로드" 버튼 클릭 시 로그 기록 및 Sentinel Alert 발생 여부 확인.
24. **XSS 공격 시도 로그 분석**
    *   **내용:** `search.php`에서 `<script>` 태그 입력 시도를 WAF가 차단한 내역을 Log Analytics에서 조회 및 패턴 분석.
25. **의심스러운 토큰 조작 탐지**
    *   **내용:** `lupang_token` 쿠키 값이 짧은 시간 내 여러 번 변경되는 패턴(토큰 위변조 시도)을 Sentinel에서 탐지.
26. **비정상적인 대량 상품 조회 패턴 탐지**
    *   **내용:** 1분 내 100개 이상의 상품 페이지를 조회하는 봇/크롤러 행위를 탐지하고 Rate Limiting 적용.
27. **웹쉘 업로드 시도 탐지 (uploads 디렉토리)**
    *   **내용:** `/var/www/html/uploads`에 `.php`, `.jsp` 등 실행 가능한 파일이 업로드될 때 Defender for Servers가 경고 발생.
28. **Lupang 서비스 중단(DoS) 탐지 및 복구**
    *   **내용:** Apache 서비스가 비정상 종료되거나 응답하지 않을 때 Health Probe 실패 → 자동 재시작 Playbook 동작 확인.
29. **의심스러운 시간대 로그인 탐지 (새벽 2~5시)**
    *   **내용:** 업무 시간 외(새벽)에 관리자 계정으로 로그인 시도 시 Sentinel이 이상 행위로 탐지하여 Alert 생성.
30. **데이터베이스 무단 접근 시도 탐지**
    *   **내용:** 허용되지 않은 IP나 애플리케이션에서 MySQL DB로 직접 연결 시도 시 방화벽 로그 및 Sentinel에서 탐지.

