# 04. 외부 보안 검증 보고서

## 목차

1. [개요](#1-개요)
2. [웹 애플리케이션 방화벽 (WAF) 검증](#2-웹-애플리케이션-방화벽-waf-검증)
3. [결론](#3-결론)

---

## 1. 개요

본 문서는 **Report 02 (아키텍처 검증)**에서 분리된 **외부 보안 위협 차단** 항목에 대한 검증 보고서입니다. 외부 인터넷 접점(Edge & Network)에서 발생하는 공격에 대한 방어 체계를 확인합니다.

---

## 2. 웹 애플리케이션 방화벽 (WAF) 검증

### 2.1 App Gateway WAF 차단 (SQL/XSS)

외부에서 주입되는 웹 공격 트래픽이 WAF(Web Application Firewall)에 의해 차단되는지 검증했습니다.

*   **설정:** Application Gateway WAF v2 (OWASP 3.2 Rule Set)
*   **시나리오:** URL에 SQL Injection 공격 패턴(예: `OR 1=1`)을 포함하여 요청.
*   **검증:**
    *   정상적인 페이지 대신 `403 Forbidden` 에러 응답 반환 확인.
    *   이를 통해 애플리케이션 계층의 취약점 공격이 방어됨을 입증.

> [!NOTE] 스크린샷 가이드: Front Door & App Gateway 접속
> *   **Image 1 (Front Door):** 브라우저 주소창에 `https://www.04www.cloud` 입력 후 나비 모양 로고가 있는 메인 페이지가 뜬 화면. (주소창 자물쇠 아이콘 포함)
> *   **Image 2 (App Gateway):** 브라우저 주소창에 `http://<AppGW_Public_IP>` 입력 후 동일한 메인 페이지가 뜨거나, 403 Forbidden 에러가 뜨는 화면 (WAF 차단 테스트 시).

---

## 3. 결론

외부 보안 검증 결과, **Application Gateway WAF**가 비정상적인 웹 요청(SQL Injection 등)을 효과적으로 탐지 및 차단하고 있음을 확인했습니다.
