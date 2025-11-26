# 📘 DB 모듈 사용 설명서

## 🧐 이게 뭔가요?

`modules/DB` 폴더에는 **2개의 통합 모듈**이 준비되어 있습니다.
각 모듈은 관련된 리소스들을 하나로 묶어서 관리합니다.

### 📁 모듈 구조

```
modules/DB/
├── database/    # MySQL + Redis + Data Factory (데이터 처리)
└── storage/     # Storage + CDN (파일 저장 및 배포)
```

---

## 🎬 사용 방법 (실전 예시)

### 완전한 워드프레스 인프라 구축

Database와 Storage 모듈을 사용하면 **모든 리소스가 자동으로 생성**됩니다:

```hcl
# 1. Database 모듈 - MySQL + Redis + Data Factory
module "database" {
  source = "./modules/DB/database"

  # 기본 설정
  rgname       = azurerm_resource_group.main.name
  loca         = "koreacentral"
  replica_loca = "koreasouth"

  # 네트워크 연결
  db_subnet_id = module.network.db_subnet_id

  # 데이터베이스 설정
  db_password = var.db_password
  db_name     = "wordpress"

  # Redis 설정 (기본값 사용 가능)
  redis_name     = "www-redis"
  redis_sku      = "Standard"  # 운영 환경 권장
  redis_capacity = 1

  # Data Factory 설정 (기본값 사용 가능)
  adf_name = "www-analytics"
}

# 2. Storage 모듈 - Storage + CDN
module "storage" {
  source = "./modules/DB/storage"

  # 기본 설정
  rgname = azurerm_resource_group.main.name
  loca   = "koreacentral"

  # Storage 이름 (전 세계 유일해야 함)
  sa_name = "wpstg2025team1"

  # CDN 설정 (기본값 사용 가능)
  cdn_profile_name = "www-cdn"
}
```

### 📦 생성되는 리소스

**Database 모듈:**
- ✅ MySQL 메인 서버 (Korea Central)
- ✅ MySQL 복제 서버 (Korea South)
- ✅ 데이터베이스
- ✅ Private Endpoint (보안 연결)
- ✅ Redis Cache (캐싱)
- ✅ Data Factory (데이터 분석)

**Storage 모듈:**
- ✅ Storage Account
- ✅ Media 컨테이너
- ✅ Tfstate 컨테이너
- ✅ Lifecycle Policy (비용 절감)
- ✅ CDN Profile
- ✅ CDN Endpoint

---

## 📂 모듈 파일 구조

### Database 모듈
```
database/
├── 01_server.tf      # MySQL 메인 서버
├── 02_db.tf          # 데이터베이스
├── 03_replica.tf     # 복제 서버
├── 04_config.tf      # 보안 설정
├── 05_pe.tf          # Private Endpoint
├── 06_redis.tf       # Redis Cache
├── 08_adf.tf         # Data Factory
├── 99_out.tf         # 출력값
└── 100_var.tf        # 변수
```

### Storage 모듈
```
storage/
├── 01_sa.tf              # Storage Account
├── 02_cont.tf            # Containers (media, tfstate)
├── 03_policy.tf          # Lifecycle Policy
├── 06_cdn_profile.tf     # CDN Profile
├── 07_cdn_endpoint.tf    # CDN Endpoint
├── 99_out.tf             # 출력값
└── 100_var.tf            # 변수
```

---

## 📋 변수 설정 가이드

### Database 모듈 변수

| 변수명 | 필수 | 기본값 | 설명 |
|--------|------|--------|------|
| `rgname` | ✅ | - | Resource Group 이름 |
| `loca` | ✅ | - | Azure 리전 |
| `replica_loca` | ❌ | `"koreasouth"` | 복제 DB 리전 |
| `db_subnet_id` | ✅ | - | DB용 서브넷 ID |
| `db_password` | ✅ | - | MySQL 암호 |
| `db_name` | ❌ | `"www_sql"` | 데이터베이스 이름 |
| `redis_name` | ❌ | `"www-redis-cache"` | Redis 이름 |
| `redis_sku` | ❌ | `"Basic"` | Redis SKU (Basic/Standard/Premium) |
| `redis_family` | ❌ | `"C"` | Redis 패밀리 |
| `redis_capacity` | ❌ | `0` | Redis 용량 (0~6) |
| `adf_name` | ❌ | `"www-data-factory"` | Data Factory 이름 |

### Storage 모듈 변수

| 변수명 | 필수 | 기본값 | 설명 |
|--------|------|--------|------|
| `rgname` | ✅ | - | Resource Group 이름 |
| `loca` | ✅ | - | Azure 리전 |
| `sa_name` | ✅ | `"wwwstorage"` | Storage 이름 (전 세계 유일) |
| `cdn_profile_name` | ❌ | `"www-cdn-profile"` | CDN Profile 이름 |

---

## 📤 출력값 (Outputs)

### Database 모듈 출력

```hcl
# MySQL
module.database.mysql_server_fqdn       # 메인 DB 접속 주소
module.database.mysql_server_id         # 메인 DB ID
module.database.replica_server_fqdn     # 복제 DB 접속 주소

# Redis
module.database.redis_hostname          # Redis 접속 주소
module.database.redis_ssl_port          # Redis SSL 포트
module.database.redis_primary_key       # Redis 접근 키

# Data Factory
module.database.adf_name                # Data Factory 이름
module.database.adf_id                  # Data Factory ID
```

### Storage 모듈 출력

```hcl
# Storage
module.storage.storage_account_name     # 스토리지 계정 이름
module.storage.primary_access_key       # 접근 키 (민감 정보)

# CDN
module.storage.cdn_endpoint_hostname    # CDN 접속 주소
```

---

## 💡 주요 특징 정리

| 항목 | 구성 | 목적 |
|------|------|------|
| **고가용성** | Primary + Replica DB | 재해 대비 |
| **성능 향상** | Redis Cache | 응답 속도 10배 ↑ |
| **글로벌 배포** | Azure CDN | 전 세계 빠른 접속 |
| **보안 강화** | Private Endpoint | 외부 차단 |
| **비용 절감** | Lifecycle Policy | 자동 정리 |
| **데이터 분석** | Data Factory | ETL 작업 |

---

## ⚠️ 주의사항

### 1. Storage Account 이름 규칙
```
✅ 좋은 예: wwwstorage2025, team1storage01
❌ 나쁜 예: WWW-Storage-2025 (대문자 X, 특수문자 X)
```

### 2. 민감 정보 관리
비밀번호나 키는 **절대 코드에 직접 작성하지 마세요**:

```hcl
# ❌ 나쁜 예
db_password = "MyPassword123!"

# ✅ 좋은 예
db_password = var.db_password  # terraform.tfvars에 저장
```

### 3. 리소스 선택적 제외 방법

특정 리소스가 필요 없다면 해당 파일을 삭제하거나 주석 처리하세요:

**Redis가 필요 없다면:**
- `database/06_redis.tf` 파일 삭제 또는 주석 처리
- `100_var.tf`와 `99_out.tf`에서 Redis 관련 부분도 제거

**CDN이 필요 없다면:**
- `storage/06_cdn_profile.tf` 파일 삭제
- `storage/07_cdn_endpoint.tf` 파일 삭제
- `100_var.tf`와 `99_out.tf`에서 CDN 관련 부분도 제거

**Data Factory가 필요 없다면:**
- `database/08_adf.tf` 파일 삭제 또는 주석 처리
- `100_var.tf`와 `99_out.tf`에서 ADF 관련 부분도 제거

---

## 🔍 트러블슈팅

### "Storage account name already taken"
→ `sa_name`을 다른 이름으로 변경하세요 (전 세계 유일해야 함)

### "Subnet ID is invalid"
→ 네트워크 모듈이 먼저 생성되었는지 확인하세요

### "변수명 오류"
→ `resource_group_name`이 아니라 `rgname`, `location`이 아니라 `loca`를 사용하세요

---

## 📚 관련 문서

- [Azure MySQL Flexible Server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server)
- [Azure Storage Account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)
- [Azure Redis Cache](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache)
- [Azure CDN](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_profile)
- [Azure Data Factory](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory)

---

**작성일:** 2025-11-20  
**버전:** 3.0 (모듈 통합 완료)