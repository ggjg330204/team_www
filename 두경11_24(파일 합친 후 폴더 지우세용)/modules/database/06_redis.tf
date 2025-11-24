resource "azurerm_redis_cache" "www_redis" {
  name                 = var.redis_name
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
