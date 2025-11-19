# 📘 데이터 & 스토리지 모듈 사용 설명서

안녕하세요! 이 문서는 **데이터(DB)**와 **스토리지(저장소)**를 담당한 엔지니어가 **팀장님(PM)**을 위해 작성했습니다.
테라폼이 처음이라도 걱정 마세요. 아래 내용을 **그대로 복사해서** 사용하시면 됩니다!

---
# 📘 데이터 & 스토리지 모듈 사용 설명서

안녕하세요! 이 문서는 **데이터(DB)**와 **스토리지(저장소)**를 담당한 엔지니어가 **팀장님(PM)**을 위해 작성했습니다.
테라폼이 처음이라도 걱정 마세요. 아래 내용을 **그대로 복사해서** 사용하시면 됩니다!

---

## 🧐 이게 뭔가요?

제가 **"데이터베이스 자판기"**와 **"스토리지 자판기"**를 만들어 두었습니다.
팀장님은 이 자판기를 **팀장님의 `main.tf` 파일**에 가져다 놓고, **동전(변수 값)**만 넣으시면 됩니다.

- **자판기 위치**: `./modules/DB/database`, `./modules/DB/storage`
- **팀장님이 할 일**: 아래 코드를 `main.tf`에 복사하고, 빈칸만 채우기!

---

## 🚀 1단계: 데이터베이스 만들기 (MySQL)

워드프레스의 글과 설정이 저장되는 곳입니다.
**특징**: 한국 중부(Central)에 메인 DB를 만들고, 한국 남부(South)에 백업용 DB를 자동으로 만들어줍니다. (안전 제일!)

### 👇 이 코드를 `main.tf`에 복사해서 붙여넣으세요

```hcl
# -------------------------------------------------------
# 2. 데이터베이스 모듈 (팀원이 만든 자판기 가져오기)
# -------------------------------------------------------
module "database" {
  # [1] 자판기 위치 (건드리지 마세요!)
  source = "./modules/DB/database"

  # [2] 리소스 그룹 & 위치 (팀장님이 만든 것과 똑같이 맞추세요)
  resource_group_name = azurerm_resource_group.main.name
  location            = "koreacentral"
  
  # [3] 백업 DB 위치 (혹시 모를 재난 대비, 남부 추천!)
  replica_location    = "koreasouth"

  # [4] 네트워크 연결 (가장 중요! ⭐)
  # 네트워크 팀원이 만든 "서브넷 ID"를 여기에 연결해야 합니다.
  # 보통 module.network.database_subnet_id 이런 식일 겁니다.
  db_subnet_id        = module.network.database_subnet_id

  # [5] 비밀번호 설정
  # 보안을 위해 직접 적지 말고, var.db_password 처럼 변수로 쓰는 게 좋아요.
  db_password         = var.db_password
  
  # [6] DB 이름 (원하는 대로 지으세요)
  db_name             = "www_wordpress_db"
}
```

---

## 📦 2단계: 스토리지 만들기 (저장소)

이미지나 동영상 파일, 그리고 테라폼 상태 파일(.tfstate)을 저장하는 창고입니다.

### 👇 이 코드를 `main.tf`에 복사해서 붙여넣으세요

```hcl
# -------------------------------------------------------
# 3. 스토리지 모듈
# -------------------------------------------------------
module "storage" {
  source = "./modules/DB/storage"

  # [1] 기본 설정
  resource_group_name  = azurerm_resource_group.main.name
  location             = "koreacentral"
  
  # [2] 스토리지 이름 (주의! 🚨)
  # 이 이름은 전 세계에서 딱 하나여야 합니다.
  # 중복되면 에러가 나니까, 뒤에 날짜나 팀 이름을 붙여보세요.
  # (소문자와 숫자만 가능합니다. 특수문자 X, 대문자 X)
  storage_account_name = "wwwstorage2025"
}
```

---

## 💡 3단계: 결과값 사용하기 (Outputs)

모듈이 다 만들어지면, **접속 주소** 같은 중요한 정보를 뱉어냅니다.
웹 서버를 만들 때 이 주소가 필요하겠죠?

- **DB 접속 주소**: `module.database.mysql_server_fqdn`
- **스토리지 계정 키**: `module.storage.primary_access_key`

---

## 4. (선택) 고도화 서비스 - 속도와 분석

웹 사이트가 느리거나 데이터를 분석하고 싶을 때 추가하세요.

### ⚡ Redis (속도 향상)
데이터베이스가 힘들어할 때 도와주는 "메모리 보조 배터리"입니다.

```hcl
module "redis" {
  source = "./modules/DB/redis"

  resource_group_name = azurerm_resource_group.main.name
  location            = "koreacentral"
  redis_name          = "www-redis-cache"
}
```

### 🌍 CDN (이미지 로딩 가속)
전 세계 어디서든 이미지가 빨리 뜨게 해줍니다.

```hcl
module "cdn" {
  source = "./modules/DB/cdn"

  resource_group_name = azurerm_resource_group.main.name
  location            = "koreacentral"
  
  # 스토리지 모듈에서 만든 주소를 연결합니다.
  origin_host_name    = "${module.storage.storage_account_name}.blob.core.windows.net"
}
```

### 📊 Analytics (데이터 분석)
데이터를 분석해서 인사이트를 얻고 싶을 때 사용합니다. (Data Factory)

```hcl
module "analytics" {
  source = "./modules/DB/analytics"

  resource_group_name = azurerm_resource_group.main.name
  location            = "koreacentral"
}
```

---

# 📘 데이터 & 스토리지 모듈 사용 설명서

안녕하세요! 이 문서는 **데이터(DB)**와 **스토리지(저장소)**를 담당한 엔지니어가 **팀장님(PM)**을 위해 작성했습니다.
테라폼이 처음이라도 걱정 마세요. 아래 내용을 **그대로 복사해서** 사용하시면 됩니다!

---
> **Tip**: 모듈 내부 코드를 수정할 때는 주석에 달린 `[PM 수정 필요]` 태그를 참고하세요.! 화이팅입니다! 👍
