# =============================================================================
# 1. Storage Module
# =============================================================================
module "storage" {
  source = "./modules/Storage"

  # [핵심] 리소스 그룹 생성 후 실행되도록 리소스 자체를 참조
  rgname = azurerm_resource_group.www_rg.name
  loca   = azurerm_resource_group.www_rg.location

  # Storage Account 이름 (소문자, 숫자만 가능, 전세계 유일해야 함)
  # 충돌 방지를 위해 뒤에 랜덤값 붙이는 로직이 모듈 내부에 없다면 여기서 유니크하게 지정 필요
  # 모듈 내부에 08_premium은 랜덤이 있는데, 01_st_acct는 wwwstore${var.teamuser}004을 그대로 씁니다.
  # 테스트용으로 유니크해 보이는 이름을 넣습니다.
  sa_name = "wwwstore${var.teamuser}004"

  # Storage PE가 위치할 서브넷 (기존 www_db 서브넷 활용하거나 별도 서브넷 지정)
  storage_subnet_id = azurerm_subnet.www_db.id

  # Private DNS Zone 연결을 위한 VNet ID
  vnet_id = azurerm_virtual_network.www_vnet0.id
}

# =============================================================================
# 2. Database Module
# =============================================================================
module "database" {
  source = "./modules/Database"

  # 리소스 그룹 종속성 해결
  rgname = azurerm_resource_group.www_rg.name
  loca   = azurerm_resource_group.www_rg.location

  # DB 접속 정보
  db_name     = "wordpress" # 워드프레스용 DB 이름
  db_user     = "www"
  db_password = var.db_password

  # 네트워크 설정
  db_subnet_id = azurerm_subnet.www_db.id
  vnet_id      = azurerm_virtual_network.www_vnet0.id

  # [핵심] Storage 모듈에서 생성된 Connection String을 받아옴
  # 이를 통해 "Storage 생성 -> DB 생성" 순서가 강제됨
  storage_connection_string = module.storage.storage_connection_string

  # Redis 설정 (필요 시 크기 조정)
  redis_name     = "${var.teamuser}-redis"
  redis_sku      = "Basic"
  redis_family   = "C"
  redis_capacity = 0

  # ADF 이름
  adf_name = "${var.teamuser}-adf"
}
