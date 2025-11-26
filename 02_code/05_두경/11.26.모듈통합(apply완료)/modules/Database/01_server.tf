resource "random_string" "mysql_suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_mysql_flexible_server" "www_mysql" {
  name                   = "www-mysql-server-${random_string.mysql_suffix.result}"
  resource_group_name    = var.rgname
  location               = var.loca
  administrator_login    = "www"
  administrator_password = var.db_password
  sku_name               = "GP_Standard_D4ds_v4"
  version                = "8.0.21"
  backup_retention_days  = 35
  zone                   = "1"
  high_availability {
    # ZoneRedundant: 메인은 1번 존, 스탠바이는 2번 존에 두어 데이터센터 화재 등 대비
    # 만약 이것도 에러 나면 "SameZone"으로 변경하세요.
    mode                      = "ZoneRedundant"
    standby_availability_zone = "2"
  }
}
