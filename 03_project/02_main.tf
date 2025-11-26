locals {
  teamuser = "leegh"
  rg_name  = "04-t1-${local.teamuser}"
  location    = "koreacentral"
  location_replica = "Korea South"
  db_password = "It12345!"
}

module "network" {
  source = "./modules/Network"

  rgname       = local.rg_name
  loca         = local.location
  loca_replica = local.location_replica
  teamuser     = local.teamuser
  subid        = var.subid
}

module "compute" {
  source = "./modules/Compute"

  rgname         = local.rg_name
  loca           = local.location
  teamuser       = local.teamuser
  subid          = var.subid
  nic_id         = module.network.nic_id
  vmss_subnet_id = module.network.vmss_subnet_id
}

module "storage" {
  source = "./modules/Storage"

  rgname            = local.rg_name
  loca              = local.location
  storage_subnet_id = module.network.storage_subnet_id
  vnet_id           = module.network.vnet_id
}

module "db" {
  source = "./modules/Database"

  rgname                    = local.rg_name
  loca                      = local.location
  db_subnet_id              = module.network.db_subnet_id
  db_password               = local.db_password
  vnet_id                   = module.network.vnet_id
  vnet_south_id             = module.network.vnet_south_id
  storage_connection_string = module.storage.storage_connection_string
}

module "security" {
  source = "./modules/Security"

  rgname   = local.rg_name
  loca     = local.location
  teamuser = local.teamuser
  subid    = var.subid

  bas_subnet_id     = module.network.bas_subnet_id
  web1_subnet_id    = module.network.web1_subnet_id
  web2_subnet_id    = module.network.web2_subnet_id
  db_subnet_id      = module.network.db_subnet_id
  web1_v1_subnet_id = module.network.web1_v1_subnet_id
  vmss_subnet_id    = module.network.vmss_subnet_id
}
