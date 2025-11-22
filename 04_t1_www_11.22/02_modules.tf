# Root module configuration
module "network_central" {
  source              = "./modules/Network"
  rgname              = azurerm_resource_group.rg.name
  loca                = "Korea Central"
  vnet_name           = "vnet0"
  address_space       = ["10.0.0.0/16"]
  subnets = {
    "subnet-web"  = "10.0.1.0/24"
    "subnet-vmss" = "10.0.2.0/24"
    "subnet-db"   = "10.0.3.0/24"
  }
  
  enable_bastion = true # Bastion enabled for Central
}

module "network_south" {
  source              = "./modules/Network"
  rgname              = azurerm_resource_group.rg.name
  loca                = "Korea South"
  vnet_name           = "vnet1"
  address_space       = ["192.168.0.0/16"]
  subnets = {
    "subnet-replica" = "192.168.1.0/24"
  }

  enable_bastion = false # Bastion disabled for South
}

resource "azurerm_virtual_network_peering" "central_to_south" {
  name                      = "peer-central-to-south"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = module.network_central.vnet_name
  remote_virtual_network_id = module.network_south.vnet_id
}

resource "azurerm_virtual_network_peering" "south_to_central" {
  name                      = "peer-south-to-central"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = module.network_south.vnet_name
  remote_virtual_network_id = module.network_central.vnet_id
}


module "compute" {
  source              = "./modules/Compute"
  rgname              = azurerm_resource_group.rg.name
  loca                = "Korea Central"
  vm_subnet_id        = module.network_central.subnet_ids["subnet-web"]
  vmss_subnet_id      = module.network_central.subnet_ids["subnet-vmss"]
  admin_username      = "hamap"
  lb_backend_pool_id  = module.network_central.lb_backend_pool_id
}

module "database" {
  source         = "./modules/database"
  rgname         = azurerm_resource_group.rg.name
  loca           = "Korea Central"
  replica_loca   = "Korea Central"
  db_subnet_id   = module.network_central.subnet_ids["subnet-db"]
  db_password    = var.db_password
  db_name        = "www_sql"
  vnet_id        = module.network_central.vnet_id
}


module "security" {
  source              = "./modules/Security"
  rgname              = azurerm_resource_group.rg.name
  loca                = "Korea Central"
  subnet_id           = module.network_central.subnet_ids["subnet-web"]
  wwwuser             = "hamap"
  vnet_name           = module.network_central.vnet_name
}
