module "network" {
  source = "./modules/Network"

  rgname    = var.rg_name
  loca      = var.location
  loca1     = "Korea South"
  teamuser  = var.teamuser
  subid     = var.subid
  vnet-bas  = "${var.teamuser}-vnet"
  vnet-nat  = "${var.teamuser}-vnet"
  vnet-load = "${var.teamuser}-vnet"
  vnet-web1 = "${var.teamuser}-vnet"
  vnet-web2 = "${var.teamuser}-vnet"
  vnet-db   = "${var.teamuser}-vnet"
  vnet-vmss = "${var.teamuser}-vnet"
}

module "compute" {
  source = "./modules/Compute"

  rgname         = var.rg_name
  loca           = var.location
  teamuser       = var.teamuser
  subid          = var.subid # 실제 구독 ID 사용
  vnet-bas       = "${var.teamuser}-vnet"
  vnet-nat       = "${var.teamuser}-vnet"
  vnet-load      = "${var.teamuser}-vnet"
  vnet-web1      = "${var.teamuser}-vnet"
  vnet-web2      = "${var.teamuser}-vnet"
  vnet-db        = "${var.teamuser}-vnet"
  vnet-vmss      = "${var.teamuser}-vnet"
  nic_id         = module.network.nic_id
  vmss_subnet_id = module.network.vmss_subnet_id
}

module "storage" {
  source = "./modules/Storage"

  rgname            = module.network.rg_name
  loca              = var.location
  storage_subnet_id = module.network.storage_subnet_id
  vnet_id           = module.network.vnet_id
}

module "db" {
  source = "./modules/Database"

  rgname                    = module.network.rg_name
  loca                      = var.location
  db_subnet_id              = module.network.db_subnet_id
  db_password               = var.db_password
  vnet_id                   = module.network.vnet_id
  vnet_south_id             = module.network.vnet_south_id
  storage_connection_string = module.storage.storage_connection_string
}

# TODO: Security 모듈이 존재하지 않는 변수를 참조하고 있어 주석 처리
# Security 모듈은 Network 모듈의 subnet ID를 직접 받아야 함
# module "security" {
#   source = "./modules/Security"
#
#   rgname    = module.network.rg_name
#   loca      = var.location
#   teamuser  = var.teamuser
#   subid     = var.subid # 실제 구독 ID 사용사용
#   vnet      = "${var.teamuser}-vnet"
# }
