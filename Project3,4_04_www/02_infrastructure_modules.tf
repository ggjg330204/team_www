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
  enable_ssl    = var.enable_ssl 
  hub_vnet_id     = module.hub.hub_vnet_id
  keyvault_id     = module.security.key_vault_id
  keyvault_name   = module.security.keyvault_name
  frontdoor_endpoint_hostname = module.edge.frontdoor_endpoint_hostname
  mysql_private_endpoint_ip   = module.database.mysql_private_endpoint_ip
  log_analytics_workspace_id  = module.security.log_analytics_workspace_id
  appgw_identity_id           = module.identity.appgw_identity_id
  appgw_identity_principal_id = module.identity.appgw_identity_principal_id
}
module "compute" {
  source         = "./modules/Compute"
  rgname         = azurerm_resource_group.rg.name
  loca           = "Korea Central"
  vm_subnet_id   = module.network_central.subnet_ids["www-web"]
  vmss_subnet_id = module.network_central.subnet_ids["www-vmss"]
  was_subnet_id  = module.network_central.subnet_ids["www-was"]
  admin_username         = "www"
  admin_password         = var.db_password
  lb_backend_pool_id     = module.network_central.lb_backend_pool_id
  lb_probe_id            = module.network_central.lb_probe_id
  ssh_nat_pool_id        = module.network_central.ssh_nat_pool_id
  was_lb_backend_pool_id = module.network_central.was_lb_backend_pool_id
  was_lb_private_ip      = module.network_central.was_lb_private_ip
  was_lb_probe_id        = module.network_central.was_lb_probe_id
  db_host                = module.database.mysql_server_fqdn
  db_user                = "www"
  db_password            = var.db_password
  db_name                = "www_sql"
  db_ro_host        = module.database.mysql_replica_fqdn
  redis_hostname         = module.database.redis_hostname
  redis_port             = module.database.redis_ssl_port
  redis_primary_key      = module.database.redis_primary_key
  app_insights_key       = module.security.app_insights_instrumentation_key
  vmss_identity_id       = module.identity.vmss_identity_id
  log_analytics_workspace_id = module.security.log_analytics_workspace_id
  data_collection_rule_id    = module.security.data_collection_rule_id
  ssh_allowed_ips        = var.ssh_allowed_ips
  domain_name            = var.domain_name
  key_vault_id           = module.security.key_vault_id
  key_vault_name         = module.security.keyvault_name
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
  log_analytics_workspace_id = module.security.log_analytics_workspace_id
}
module "security" {
  source                     = "./modules/Security"
  rgname                     = azurerm_resource_group.rg.name
  loca                       = "Korea Central"
  subnet_id                  = module.network_central.subnet_ids["www-web"]
  wwwuser                    = "www"
  vnet_name                  = module.network_central.vnet_name
  vmss_id                    = module.compute.vmss_id
  mysql_server_id            = module.database.mysql_server_id
  redis_id                   = module.database.redis_id
  lb_public_ip               = module.network_central.lb_public_ip

  allowed_subnet_ids = [
    module.network_central.subnet_ids["www-web"],
    module.network_central.subnet_ids["www-was"]
  ]

  ssh_allowed_ips             = var.ssh_allowed_ips
  appgw_identity_principal_id = module.identity.appgw_identity_principal_id
  vmss_identity_principal_id  = module.identity.vmss_identity_principal_id
  enable_appgw                = module.network_central.enable_appgw
  db_password                 = var.db_password
  admin_emails                = var.admin_emails
  admin_phone                 = var.admin_phone
  domain_name                 = var.domain_name
}

module "storage" {
  source            = "./modules/storage"
  rgname            = azurerm_resource_group.rg.name
  loca              = "Korea Central"
  storage_subnet_id = module.network_central.subnet_ids["www-stor"]
  vnet_id           = module.network_central.vnet_id
  log_analytics_workspace_id = module.security.log_analytics_workspace_id
  allowed_ips       = var.ssh_allowed_ips
}

module "edge" {
  source                         = "./modules/Edge"
  rgname                         = azurerm_resource_group.rg.name
  loca                           = "Korea Central"
  lb_public_ip                   = module.network_central.lb_public_ip
  appgw_public_ip                = module.network_central.appgw_public_ip
  keyvault_certificate_secret_id = ""
  key_vault_id                   = module.security.key_vault_id
  domain_name                    = var.domain_name
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
  allowed_ip_ranges = var.ssh_allowed_ips
}

module "identity" {
  source = "./modules/Identity"
  rgid   = azurerm_resource_group.rg.id
  rgname = azurerm_resource_group.rg.name
  loca   = "Korea Central"
}

module "dns" {
  source                      = "./modules/Dns"
  rgname                      = azurerm_resource_group.rg.name
  domain_name                 = var.domain_name
  frontdoor_endpoint_hostname  = module.edge.frontdoor_endpoint_hostname
  frontdoor_endpoint_id        = module.edge.frontdoor_endpoint_id
  www_domain_validation_token  = module.edge.www_custom_domain_validation_token
  apex_domain_validation_token = module.edge.apex_custom_domain_validation_token
  mail_server_ip               = module.compute.mail_vm_public_ip
}

module "governance" {
  source = "./modules/Governance"
  rgname = azurerm_resource_group.rg.name
  rgid   = azurerm_resource_group.rg.id
  db_id  = module.database.mysql_server_id
}

module "api_management" {
  source          = "./modules/ApiManagement"
  rgname          = azurerm_resource_group.rg.name
  loca            = "Korea Central"
  subnet_id       = module.network_central.subnet_ids["www-web"]
  lb_private_ip   = module.network_central.was_lb_private_ip
  publisher_email = var.admin_emails[0]
}
