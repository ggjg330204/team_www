# 3. MySQL Replica Server
# 주석: 구독에서 다른 리전(koreasouth, japaneast) GP SKU 지원 안 함
# 필요시 아래 주석 해제하고 replica_loca를 "koreasouth"로 설정
# resource "azurerm_mysql_flexible_server" "www_replica" {
#   name                = "www-mysql-replica"
#   resource_group_name = var.rgname
#   location            = var.replica_loca  # replica_loca = "koreasouth"
#   sku_name            = "GP_Standard_D2ds_v4"
#   version             = "8.0.21"
#   create_mode         = "Replica"
#   source_server_id    = azurerm_mysql_flexible_server.www_mysql.id
# }
