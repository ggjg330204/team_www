module "network" {
  source = "./modules/Network"

  rgname       = var.rg_name
  loca         = var.location
  loca_replica = "Korea South"
  teamuser     = var.teamuser
  subid        = var.subid
}

module "compute" {
  source = "./modules/Compute"

  rgname         = var.rg_name
  loca           = var.location
  teamuser       = var.teamuser
  subid          = var.subid
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

module "security" {
  source = "./modules/Security"

  rgname   = module.network.rg_name
  loca     = var.location
  teamuser = var.teamuser
  subid    = var.subid

  bas_subnet_id     = module.network.bas_subnet_id
  web1_subnet_id    = module.network.web1_subnet_id
  web2_subnet_id    = module.network.web2_subnet_id
  db_subnet_id      = module.network.db_subnet_id
  web1_v1_subnet_id = module.network.web1_v1_subnet_id
  vmss_subnet_id    = module.network.vmss_subnet_id
}
