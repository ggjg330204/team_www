resource "random_string" "redis_suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_redis_cache" "www_redis" {
  name                 = "${var.redis_name}-${random_string.redis_suffix.result}"
  location             = var.loca
  resource_group_name  = var.rgname
  capacity             = var.redis_capacity
  family               = var.redis_family
  sku_name             = var.redis_sku
  non_ssl_port_enabled = false
  minimum_tls_version  = "1.2"

  redis_configuration {
  }

  tags = {
    environment = "production"
    team        = "www"
  }
}