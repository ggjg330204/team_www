module "hub" {
  source            = "./modules/Hub"
  rgname            = azurerm_resource_group.rg.name
  loca              = "Korea Central"
  hub_address_space = "10.1.0.0/16"
  enable_vpn        = false
}
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "hub-to-spoke"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = module.hub.hub_vnet_name
  remote_virtual_network_id = module.network_central.vnet_id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = true
  use_remote_gateways       = false
  depends_on = [module.network_central]
}
module "network_central" {
  source        = "./modules/Network"
  rgname        = azurerm_resource_group.rg.name
  loca          = "Korea Central"
  vnet_name     = "vnet0"
  address_space = ["10.0.0.0/16", "172.16.0.0/16", "192.168.0.0/16"]
  subnets = {
    "www-nat" = "10.0.1.0/24"
    "www-db"   = "172.16.1.0/24"
    "www-stor" = "172.16.2.0/24"
    "www-vmss"  = "192.168.1.0/24"
    "www-web"   = "192.168.2.0/24"
    "www-appgw" = "192.168.3.0/24"
    "www-load"  = "192.168.4.0/24"
    "www-was" = "192.168.5.0/24"
  }
  enable_appgw    = true
  enable_nat      = true
  enable_vpn      = false
  enable_cross_lb = false
  enable_ddos     = false
  enable_ssl      = false
  hub_vnet_id     = module.hub.hub_vnet_id
}
resource "azurerm_public_ip" "bastion_vm_pip" {
  name                = "bastion-vm-pip"
  location            = "Korea Central"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
resource "azurerm_network_interface" "bastion_nic" {
  name                = "bastion-vm-nic"
  location            = "Korea Central"
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.network_central.subnet_ids["www-nat"]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_vm_pip.id
  }
}
module "compute" {
  source         = "./modules/Compute"
  rgname         = azurerm_resource_group.rg.name
  loca           = "Korea Central"
  vm_subnet_id   = module.network_central.subnet_ids["www-web"]
  vmss_subnet_id = module.network_central.subnet_ids["www-vmss"]
  was_subnet_id  = module.network_central.subnet_ids["www-was"]
  admin_username         = "www"
  lb_backend_pool_id     = module.network_central.lb_backend_pool_id
  lb_probe_id            = module.network_central.lb_probe_id
  ssh_nat_pool_id        = module.network_central.ssh_nat_pool_id
  was_lb_backend_pool_id = module.network_central.was_lb_backend_pool_id
  was_lb_private_ip      = module.network_central.was_lb_private_ip
  was_lb_probe_id        = module.network_central.was_lb_probe_id
  bastion_nic_id         = azurerm_network_interface.bastion_nic.id
  db_host                = module.database.mysql_server_fqdn
  db_user                = "www"
  db_password            = var.db_password
  db_name                = "www_sql"
  redis_hostname         = module.database.redis_hostname
  redis_port             = module.database.redis_ssl_port
  redis_primary_key      = module.database.redis_primary_key
}
module "database" {
  source                    = "./modules/database"
  rgname                    = azurerm_resource_group.rg.name
  loca                      = "Korea Central"
  db_location               = "Korea Central"
  replica_loca              = "Korea Central"
  db_subnet_id              = module.network_central.subnet_ids["www-db"]
  db_password               = var.db_password
  db_name                   = "www_sql"
  vnet_id                   = module.network_central.vnet_id
  storage_connection_string = module.storage.storage_connection_string
}
module "security" {
  source          = "./modules/Security"
  rgname          = azurerm_resource_group.rg.name
  loca            = "Korea Central"
  subnet_id       = module.network_central.subnet_ids["www-web"]
  wwwuser         = "www"
  vnet_name       = module.network_central.vnet_name
  vmss_id         = module.compute.vmss_id
  mysql_server_id = module.database.mysql_server_id
  redis_id        = module.database.redis_id
  lb_public_ip    = module.network_central.lb_public_ip
  webvm_id        = module.compute.webvm_id
  ssh_allowed_ips            = var.ssh_allowed_ips
  log_analytics_workspace_id = module.database.log_analytics_workspace_id
}
module "storage" {
  source            = "./modules/storage"
  rgname            = azurerm_resource_group.rg.name
  loca              = "Korea Central"
  storage_subnet_id = module.network_central.subnet_ids["www-stor"]
  vnet_id           = module.network_central.vnet_id
}
module "serverless" {
  source                    = "./modules/Serverless"
  rgname                    = azurerm_resource_group.rg.name
  loca                      = "Korea Central"
  storage_account_id        = module.storage.storage_account_id
  storage_connection_string = module.storage.storage_connection_string
}
module "container_registry" {
  source            = "./modules/ContainerRegistry"
  rgname            = azurerm_resource_group.rg.name
  loca              = "Korea Central"
  subnet_id         = module.network_central.subnet_ids["www-web"]
  allowed_ip_ranges = ["61.108.60.26/32"]
}
