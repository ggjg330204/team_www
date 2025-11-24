---

# 데이터 및 스토리지 엔지니어 PPT 제작 가이드 (High-Level)

**목표**: 단순 기능 구현 보고가 아닌, **엔터프라이즈급 인프라의 안정성, 보안성, 효율성**을 입증하는 설득력 있는 발표 자료 제작.

---

## 전체 스토리라인 (Storyline)

1.  **인트로**: 우리는 데이터 인프라를 어떤 원칙(보안, 안정, 성능)으로 설계했는가?
2.  **보안(Security)**: 외부 위협을 원천 차단하는 'Zero Trust' 네트워크 구성.
3.  **연속성(Continuity)**: 데이터 유실 제로에 도전하는 백업 및 DR(재해 복구) 전략.
4.  **성능(Performance)**: 사용자 경험과 비용 효율을 모두 잡은 캐싱 레이어.
5.  **운영(Operations)**: 문제가 터지기 전에 감지하는 모니터링 및 거버넌스.
6.  **인사이트(Insight)**: 제약 사항을 기술적으로 극복한 아키텍처 최적화 사례.
7.  **아웃트로**: 결론 및 비즈니스 기대 효과.

---

## 슬라이드별 상세 가이드

### Slide 1: 표지
*   **[텍스트 구성]**
    *   **대제목**: Enterprise Data Infrastructure Strategy
    *   **소제목**: Security, Reliability, and Scalability (보안, 신뢰성, 확장성을 갖춘 데이터 아키텍처)
    *   **프로젝트명**: 04_t1_www Project
    *   **발표자**: Data & Storage Engineer 이두경
    *   **날짜**: 2025. 11. 24
*   **[디자인 요소]**
    *   배경은 깔끔한 화이트/그레이 톤.
    *   하단에 Azure 로고나 Terraform 로고를 작게 배치하여 사용 기술 스택을 암시.
*   **[대본 (Script)]**
    "안녕하십니까. 04_t1_www 프로젝트에서 데이터 및 스토리지 엔지니어링을 담당한 이두경입니다. 저는 오늘 단순한 데이터 저장을 넘어, 보안과 비즈니스 연속성을 보장하는 엔터프라이즈급 데이터 인프라 전략에 대해 말씀드리겠습니다."

### Slide 2: 아키텍처 오버뷰 (Architectural Overview)
*   **주제**: 관리형 서비스(PaaS)와 코드형 인프라(IaC)의 결합.
*   **[비주얼 구성]**
    *   **중앙**: VNet 박스 안에 `MySQL Flexible Server`, `Storage Account`, `Redis Cache` 아이콘 배치.
    *   **좌측 (외부)**: `Azure Front Door` 아이콘이 VNet을 가리키도록 배치.
    *   **하단 (기반)**: 인프라 전체를 받치고 있는 블록 모양으로 **"Terraform (IaC)"** 로고 및 텍스트 배치.
*   **[텍스트 포인트]**
    *   **Managed PaaS**: Azure MySQL Flexible Server & Blob Storage.
    *   **Performance**: Redis Cache & Azure Front Door.
    *   **Infrastructure as Code**: 100% Terraform 기반 배포.
*   **[대본 (Script)]**
    "먼저 전체 아키텍처입니다. 저희 팀은 운영 효율성과 안정성을 위해 Azure의 **PaaS(Platform as a Service)** 모델을 전면 도입했습니다.
    핵심 데이터는 MySQL Flexible Server와 Blob Storage에 저장되며, 성능 가속을 위해 Redis와 Front Door를 유기적으로 결합했습니다.
    특히, 이 모든 인프라는 **Terraform 코드(IaC)**로 구현되어 있어, 휴먼 에러 없이 언제든 동일한 환경을 즉시 재현할 수 있는 '불변 인프라' 환경을 갖추고 있습니다."

### Slide 3: 보안 전략 (Security & Governance)
*   **주제**: Attack Surface(공격 표면)의 최소화
*   **[비주얼 구성]**
    *   **비교 그림 (좌/우)**:
        *   (좌) Public IP 사용 시: 해커 아이콘이 DB에 접근 가능 -> **빨간 X 표시**.
        *   (우) Private Endpoint 사용 시: VNet 내부의 App Server만 DB에 연결됨 (자물쇠 아이콘) -> **초록 O 표시**.
    *   **키워드 박스**: `Zero Trust`, `Private DNS`, `Encryption`.
*   **[텍스트 포인트]**
    *   **Public Access Deny**: 0.0.0.0 (공용 접근 원천 차단).
    *   **Private Endpoint**: 사설 IP를 통한 데이터 접근.
    *   **Private DNS Zone**: 내부 도메인(`privatelink...`) 기반의 안정적 연결.
*   **[대본 (Script)]**
    "데이터 보안의 제1원칙은 '격리'입니다. 저희는 데이터베이스에 대한 공용 인터넷 접근을 원천 차단하는 **Zero Trust** 모델을 적용했습니다.
    대신 **Private Endpoint**를 구축하여 오직 인가된 내부 네트워크에서만 접근이 가능합니다. 또한, **Private DNS Zone**을 통합하여 IP가 변경되더라도 안정적인 도메인 연결이 보장되도록 설계했습니다."

### Slide 4: 비즈니스 연속성 (Business Continuity & DR)
*   **주제**: 멈추지 않는 서비스, 사라지지 않는 데이터
*   **[비주얼 구성]**
    *   **타임라인 그래프**:
        *   장애 발생 시점(0분) -> **RPO(5분)** 시점으로 데이터 복구 -> **RTO(30분)** 시점에 서비스 정상화.
    *   **지도 그래픽**:
        *   Korea Central (Main DB/Storage) <--(화살표: GRS 복제)--> Korea South (Backup Storage).
*   **[텍스트 포인트]**
    *   **Backup Strategy**: 35일 보존 (Point-in-Time Restore).
    *   **Storage DR**: GRS (Geo-Redundant Storage).
    *   **Safety Net**: Soft Delete 7일 (실수 삭제 방지).
*   **[대본 (Script)]**
    "서비스가 멈추더라도 데이터는 사라지면 안 됩니다. 저희는 **RPO 5분, RTO 30분**이라는 명확한 복구 목표를 수립했습니다.
    MySQL은 최대 35일간의 시점 복원을 지원하며, 스토리지 계정은 **GRS(지리적 중복)** 설정을 통해 한국 중부 리전이 완전히 파괴되는 재해 상황에서도 남부 리전에서 데이터를 살려낼 수 있도록 이중화했습니다."

### Slide 5: 성능 및 효율화 (Performance & Optimization)
*   **주제**: 응답 속도 개선 및 백엔드 부하 분산
*   **[비주얼 구성]**
    *   **깔대기(Funnel) 흐름도**:
        1.  User Traffic (많은 양)
        2.  **Front Door** (정적 파일 처리) -> 트래픽 감소
        3.  **Redis Cache** (반복 쿼리 처리) -> 트래픽 대폭 감소
        4.  **Database** (최종 쓰기/읽기) -> 필수 트래픽만 도달
    *   **우측 하단**: DB 아이콘 옆에 'Scale Up/Out' 가능 표시.
*   **[텍스트 포인트]**
    *   **Caching Layer**: 백엔드 부하 70% 이상 감소 기대.
    *   **Scalability**: 버튼 클릭으로 vCore 증설 및 Replica 추가 가능.
*   **[대본 (Script)]**
    "성능 최적화의 핵심은 데이터베이스가 일하지 않게 하는 것입니다.
    Azure Front Door와 Redis Cache를 앞단에 배치하여 트래픽의 상당 부분을 미리 처리함으로써 DB 부하를 최소화하고 응답 속도를 높였습니다.
    또한, 향후 트래픽이 폭증하더라도 아키텍처 변경 없이 즉시 스펙을 올리거나(Scale-up), 읽기 전용 복제본을 추가(Scale-out)할 수 있는 유연성을 확보했습니다."

### Slide 6: 운영 및 모니터링 (Observability)
*   **주제**: 데이터 투명성 확보와 TCO(총 소유 비용) 절감
*   **[비주얼 구성]**
    *   **아이콘 3개 나열**:
        1.  **눈 모양 (Visibility)**: Audit Logs & Monitoring.
        2.  **돈 모양 (Cost)**: Lifecycle Management.
        3.  **방패 모양 (Compliance)**: Governance.
*   **[텍스트 포인트]**
    *   **Traceability**: "누가, 언제, 무엇을" 했는지 추적 (Audit Logs).
    *   **Cost Optimization**: 스토리지 자동 증가 및 수명주기 관리로 불필요한 비용 절감.
*   **[대본 (Script)]**
    "구축만큼 중요한 것이 운영입니다. 모든 데이터 접근 이력은 감사 로그(Audit Log)로 기록되어 보안 사고를 추적할 수 있습니다.
    또한, PaaS의 장점인 관리 편의성을 통해 엔지니어의 단순 반복 업무를 줄이고, 스토리지 수명주기 정책을 통해 불필요한 비용 낭비를 막는 효율적인 운영 체계를 마련했습니다."

### Slide 7: 아키텍처 최적화 사례 (Architectural Decisions)
*   **주제**: 제약 사항 극복 및 최적의 대안 도출
*   **[비주얼 구성]**
    *   **Problem -> Solution 다이어그램**:
        *   **[Problem]**: 타 리전(Korea South) vCPU 할당량 부족 -> "Cross-Region Replica 생성 불가".
        *   **[Decision]**: 컴퓨팅 가용성 vs 데이터 내구성 분리 접근.
        *   **[Solution]**:
            *   **DB**: 동일 리전 내 Replica로 가용성 확보.
            *   **Storage**: GRS 유지로 지리적 재해 대비.
*   **[텍스트 포인트]**
    *   **Issue**: Region Resource Quota Limit.
    *   **Result**: Hybrid DR Strategy (Local HA + Geo Storage).
*   **[대본 (Script)]**
    "프로젝트 중 리전 할당량 제한으로 인해 계획했던 교차 리전 DB 복제가 불가능한 상황이 발생했습니다.
    하지만 포기하지 않고, '데이터 내구성'이라는 본질에 집중했습니다. 리전 제한이 없는 스토리지는 GRS로 지리적 이중화를 유지하고, DB는 동일 리전 내에서 가용성을 확보하는 하이브리드 전략으로 수정하여, 현실적인 제약 안에서 최적의 안정성을 도출해냈습니다."

### Slide 8: 결론 (Conclusion)
*   **주제**: 신뢰할 수 있는 데이터 기반 마련
*   **[비주얼 구성]**
    *   중앙에 3개의 큰 원이 겹치는(벤 다이어그램) 형태.
    *   각 원에 **Secure** (보안), **Reliable** (안정), **Scalable** (확장) 텍스트 배치.
    *   하단에 **"Enterprise Ready"** 문구 강조.
*   **[텍스트 포인트]**
    *   **Risk Minimized**: 데이터 유실 가능성 최소화.
    *   **Cost Optimized**: TCO(총 소유 비용) 절감.
    *   **Future Proof**: 성장에 제약 없는 인프라.
*   **[대본 (Script)]**
    "결론입니다. 저희 팀은 단순히 데이터를 저장하는 공간이 아니라, 비즈니스의 리스크를 최소화하고, 비용을 최적화하며, 미래의 성장을 담아낼 수 있는 '엔터프라이즈급 데이터 플랫폼'을 완성했습니다.
    이상으로 데이터 및 스토리지 엔지니어링 발표를 마치겠습니다. 감사합니다."

## 3. 발표 준비 팁 (Q&A 대비)

다음과 같은 날카로운 질문이 나올 수 있습니다. 미리 답변을 준비하세요.

1.  **Q: "IaaS(VM에 DB 설치)보다 PaaS가 비싸지 않나요?"**
    *   **A**: "단순 인프라 비용은 높을 수 있지만, 백업, 보안 패치, HA 구성 등에 투입되는 엔지니어의 시간과 운영 비용(OpEx)을 고려하면 TCO 관점에서 PaaS가 훨씬 경제적이고 안정적입니다."
2.  **Q: "Private Endpoint를 쓰면 개발자들이 DB에 접근하기 불편하지 않나요?"**
    *   **A**: "보안을 위해 편의성을 일부 타협했습니다. 직접 접근은 차단되지만, VNet 내의 Bastion Host(Jumpbox)를 경유하거나 VPN을 통해 안전하고 통제된 방식으로 접근하는 프로세스를 정립했습니다."
3.  **Q: "RPO 5분이 비즈니스에 치명적이라면 어떻게 하나요?"**
    *   **A**: "현재는 비용 효율성을 고려한 설정입니다. 만약 '데이터 손실 제로(Zero Data Loss)'가 필수적인 워크로드라면, 상위 티어인 'Business Critical'로 업그레이드하여 동기식 복제를 적용함으로써 해결할 수 있도록 설계되어 있습니다."

---

## PPT 디자인 & 톤앤매너 팁

1.  **색상 사용의 절제**: Azure의 **Blue**를 메인으로 하되, 보안 관련 내용은 **Dark Grey**나 **Green**(안전)을 사용하여 신뢰감을 줍니다. 붉은색(위험/강조)은 최소한으로 사용합니다.
2.  **도식화 (Diagramming)**: 텍스트를 줄이고, **아이콘(DB, Shield, Cloud, Lock)**을 활용한 아키텍처 다이어그램을 크게 배치하세요. "백문이 불여일견"은 엔지니어링 발표의 핵심입니다.
3.  **수치 강조**: RPO **5분**, 보존 기간 **35일**, Soft Delete **7일** 등 숫자는 굵게(Bold) 처리하여 신뢰도를 높이세요.
4.  **애니메이션 최소화**: 화려한 전환 효과보다는, 데이터 흐름을 보여주는 단순한 '닦아내기'나 '나타나기' 정도만 사용하여 전문성을 유지하세요.