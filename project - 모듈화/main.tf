locals {
  rg_name     = "04-t1-test"
  location    = "koreacentral"
  db_password = "It12345!"
  teamuser    = "test"
  subid       = "99b79efe-ebd6-468c-b39f-5669acb259e1"
}
resource "azurerm_resource_group" "www_rg" {
  name     = local.rg_name
  location = local.location
}

module "compute" {
  source = "./modules/Compute"

  rgname    = local.rg_name
  loca      = local.location
  teamuser  = local.teamuser
  subid     = local.subid
  nic_id    = module.network.nic_id
  # 폴더 참조용
  subnet_www_bas_nic = module.network.subnet_www_bas_nic
  subnet_www_web1_nic = module.network.subnet_www_web1_nic
  subnet_www_web2_nic = module.network.subnet_www_web2_nic
  subnet_www_db_nic = module.network.subnet_www_db_nic
  #subnet_www_app_nic = module.network.subnet_www_app_nic
  subnet_www_web1_v1_nic = module.network.subnet_www_web1_v1_nic
  subnet_www_web2_v1_nic = module.network.subnet_www_web1_v1_nic
  
  azurerm_subnet_www_vmss = module.network.azurerm_subnet_www_vmss

  gateway_www_appgw_backend_add_pool = module.appgw.backend_address_pool_ids
}

# module "database" {
#   source = "./modules/database"

#   rgname    = local.rg_name
#   loca      = local.location
#   teamuser  = local.teamuser
#   db_subnet_id = module.network.subnet_id
#   db_password  = local.db_password
# }


module "network" {
  source = "./modules/Network"

  rgname    = local.rg_name
  loca      = local.location
  teamuser  = local.teamuser
  loca2     = "KoreaSouth"
  subid     = "unused" # Not used in module

}

module "security" {
  source = "./modules/Security"
  rgname    = local.rg_name
  loca      = local.location
  teamuser  = local.teamuser

    # 폴더 참조용
  subnet_www_bas_nic = module.network.subnet_www_bas_nic
  subnet_www_web1_nic = module.network.subnet_www_web1_nic
  subnet_www_web2_nic = module.network.subnet_www_web2_nic
  subnet_www_db_nic = module.network.subnet_www_db_nic
  #subnet_www_app_nic = module.network.subnet_www_app_nic
  subnet_www_web1_v1_nic = module.network.subnet_www_web1_v1_nic
  subnet_www_web2_v1_nic = module.network.subnet_www_web1_v1_nic
  
  #subnet
  azurerm_subnet_www_bas = module.network.azurerm_subnet_www_bas
  azurerm_subnet_www_nat = module.network.azurerm_subnet_www_nat
  azurerm_subnet_www_web1 = module.network.azurerm_subnet_www_web1
  azurerm_subnet_www_web2 = module.network.azurerm_subnet_www_web2
  azurerm_subnet_www_db = module.network.azurerm_subnet_www_db
  #azurerm_subnet_www_app = module.network.azurerm_subnet_www_app
  azurerm_subnet_www_nat_v1 = module.network.azurerm_subnet_www_nat_v1
 # azurerm_subnet_www_load = module.network.azurerm_subnet_www_load
  azurerm_subnet_www_web1_v1 = module.network.azurerm_subnet_www_web1_v1
  azurerm_subnet_www_web2_v1 = module.network.azurerm_subnet_www_web2
  
  azurerm_subnet_www_vmss = module.network.azurerm_subnet_www_vmss

}

# module "storage" {
#   source = "./modules/storage"

#   rgname    = local.rg_name
#   loca      = local.location
#   teamuser  = local.teamuser
# }
