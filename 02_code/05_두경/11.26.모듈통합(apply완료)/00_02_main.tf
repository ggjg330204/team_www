# main.tf

# =============================================================================
# 1. Resource Group (모든 리소스의 부모)
# =============================================================================
resource "azurerm_resource_group" "www_rg" {
  name     = var.rg_name
  location = var.loca
}

# =============================================================================
# 2. Network Module
#    - VNet, Subnet, Public IP, NAT, AppGateway 생성
#    - Output: Subnet IDs, VNet IDs, AppGateway Backend Pool ID 등
# =============================================================================
module "network" {
  source = "./modules/Network"

  # 변수 전달
  rg_name  = azurerm_resource_group.www_rg.name
  loca     = azurerm_resource_group.www_rg.location
  loca2    = var.loca2
  teamuser = var.teamuser
}

# =============================================================================
# 3. Security Module
#    - NSG 생성 및 Subnet 연결
#    - Network 모듈에서 생성된 Subnet ID를 받아와야 함
# =============================================================================
module "security" {
  source = "./modules/Security"

  rg_name = azurerm_resource_group.www_rg.name
  loca    = azurerm_resource_group.www_rg.location
  loca2   = var.loca2

  # [의존성 연결] Network 모듈의 Output -> Security 모듈의 Input
  # Network 모듈의 outputs.tf에 해당 이름들이 정의되어 있어야 합니다.
  sub_bas_id  = module.network.sub_bas_id
  sub_web1_id = module.network.sub_web1_id
  sub_web2_id = module.network.sub_web2_id
  sub_db_id   = module.network.sub_db_id
  sub_vmss_id = module.network.sub_vmss_id

  # vnet1(South Korea) 쪽 서브넷 ID 연결 (변수가 정의되어 있다면)
  sub_web1_v1_id = module.network.sub_web1_v1_id
  # sub_web2_v1_id = module.network.sub_web2_v1_id (필요 시 추가)
}

# =============================================================================
# 4. Storage Module
#    - Storage Account, Container, Private Endpoint
#    - DB 모듈보다 먼저 생성되어야 함 (Connection String 제공)
# =============================================================================
module "storage" {
  source = "./modules/Storage"

  # DB/Storage 모듈 내부는 변수명이 'rgname' 이었음
  rgname = azurerm_resource_group.www_rg.name
  loca   = azurerm_resource_group.www_rg.location

  # Storage Account 이름 (전세계 유일해야 하므로 랜덤성 추가 권장)
  sa_name = "wwwstore${var.teamuser}001"

  # Private Endpoint가 위치할 서브넷 (DB 서브넷 활용)
  storage_subnet_id = module.network.sub_db_id

  # Private DNS Zone 연결을 위한 VNet ID
  vnet_id = module.network.vnet0_id
}

# =============================================================================
# 5. Database Module
#    - MySQL Flexible Server, Redis, ADF
#    - Storage 모듈의 Connection String을 받아옴
# =============================================================================
module "database" {
  source = "./modules/Database"

  rgname = azurerm_resource_group.www_rg.name
  loca   = azurerm_resource_group.www_rg.location

  # DB 설정
  db_name     = "wordpress"
  db_user     = "www"
  db_password = var.db_password # terraform.tfvars의 민감 변수 전달

  # 네트워크 연결
  db_subnet_id = module.network.sub_db_id
  vnet_id      = module.network.vnet0_id

  # [핵심] Storage 모듈 결과값 주입 (순서 제어: Storage -> DB)
  storage_connection_string = module.storage.storage_connection_string

  # Redis, ADF 설정
  redis_name = "${var.teamuser}-redis"
  adf_name   = "${var.teamuser}-adf"
}

# =============================================================================
# 6. Compute Module
#    - VMs (Bastion, Web, DB), VMSS, Gallery
#    - 가장 마지막에 생성 (네트워크, DB 등이 준비된 후)
# =============================================================================
module "compute" {
  source = "./modules/Compute"

  rg_name  = azurerm_resource_group.www_rg.name
  loca     = azurerm_resource_group.www_rg.location
  loca2    = var.loca2
  teamuser = var.teamuser

  # Subnet 연결 (VM을 배치할 위치)
  sub_bas_id     = module.network.sub_bas_id
  sub_web1_id    = module.network.sub_web1_id
  sub_web2_id    = module.network.sub_web2_id
  sub_db_id      = module.network.sub_db_id
  sub_vmss_id    = module.network.sub_vmss_id
  nic_bas_id     = module.network.nic_bas_id
  nic_web1_id    = module.network.nic_web1_id
  nic_web2_id    = module.network.nic_web2_id
  nic_db_id      = module.network.nic_db_id
  nic_web1_v1_id = module.network.nic_web1_v1_id

  # Public IP 연결 (Bastion용, NIC 생성 시 필요)
  # Network 모듈에서 output "pub_bas_id" { value = azurerm_public_ip.www_basip.id } 필요
  pub_bas_id = module.network.pub_bas_id

  # AppGateway Backend Pool 연결 (VMSS를 AppGW에 붙이기 위함)
  # Network 모듈에서 output "appgw_be_pool_id" 필요
  appgw_be_pool_id = module.network.appgw_be_pool_id
}
