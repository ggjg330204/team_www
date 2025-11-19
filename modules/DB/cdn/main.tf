resource "azurerm_cdn_profile" "main" {
  name                = var.cdn_profile_name
  location            = "global" # CDN은 전 세계 대상이므로 위치가 'global'입니다.
  resource_group_name = var.resource_group_name
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "main" {
  name                = "www-cdn-endpoint-${random_string.suffix.result}" # 유니크해야 함
  profile_name        = azurerm_cdn_profile.main.name
  location            = azurerm_cdn_profile.main.location
  resource_group_name = var.resource_group_name

  origin {
    name      = "storage-origin"
    host_name = var.origin_host_name
  }
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

/*
### 학습 포인트 (CDN)
- **azurerm_cdn_profile**: CDN 서비스 계약서 같은 겁니다. "Microsoft망을 쓰겠다" 등을 정합니다.
- **azurerm_cdn_endpoint**: 실제 접속 주소입니다. `https://www-cdn-endpoint-xxxx.azureedge.net` 같은 주소가 생깁니다.
- **origin**: 원본 데이터가 어디 있는지 알려줍니다. 우리는 스토리지(Blob)를 가리킵니다.
*/
