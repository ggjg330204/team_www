resource "azurerm_redis_cache" "main" {
  name                 = var.redis_name
  location             = var.location
  resource_group_name  = var.resource_group_name
  capacity             = var.capacity
  family               = var.family
  sku_name             = var.sku_name
  non_ssl_port_enabled = false # 보안을 위해 SSL(6380 포트)만 허용
  minimum_tls_version  = "1.2"

  redis_configuration {
  }

  tags = {
    environment = "production"
    team        = "www"
  }
}

/*
### 학습 포인트 (Redis)
- **azurerm_redis_cache**: 아주 빠른 메모리 저장소입니다. DB가 책이라면, Redis는 포스트잇입니다.
- **non_ssl_port_enabled = false**: 암호화되지 않은 통신은 막습니다. 해커가 데이터를 엿보지 못하게 합니다.

### 관련 문서 (Terraform Registry)
- **Redis Cache**: [azurerm_redis_cache](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache)
*/
