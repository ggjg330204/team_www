resource "random_string" "redis_suffix" {
  length  = 4
  special = false
  upper   = false
}
resource "azurerm_redis_cache" "www_redis" {
  name                          = "${var.redis_name}-${random_string.redis_suffix.result}"
  location                      = var.loca
  resource_group_name           = var.rgname
  capacity                      = 1
  family                        = "P"
  sku_name                      = "Premium"
  non_ssl_port_enabled          = false
  minimum_tls_version           = "1.2"
  redis_configuration {
    maxmemory_policy              = "allkeys-lru"
    maxmemory_reserved            = 10
    maxmemory_delta               = 10
    rdb_backup_enabled            = true
    rdb_backup_frequency          = 60
    rdb_backup_max_snapshot_count = 1
    rdb_storage_connection_string = var.storage_connection_string
  }
  patch_schedule {
    day_of_week    = "Sunday"
    start_hour_utc = 3
  }
  tags = {
    Environment = "Production"
    Purpose     = "Redis-Cache"
    ManagedBy   = "Terraform"
  }
  lifecycle {
    ignore_changes = [
      public_network_access_enabled,
      subnet_id,
      zones
    ]
  }
}