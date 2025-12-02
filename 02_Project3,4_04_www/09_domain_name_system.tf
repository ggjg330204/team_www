resource "azurerm_dns_zone" "public" {
  name                = "04www.cloud"
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    Environment = "Production"
    Purpose     = "Public-DNS"
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_dns_a_record" "www_public" {
  name                = "www"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [module.network_central.lb_public_ip]
}
resource "azurerm_dns_a_record" "root_public" {
  name                = "@"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [module.network_central.lb_public_ip]
}
resource "azurerm_private_dns_zone" "private" {
  name                = "04www.cloud"
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    Environment = "Production"
    Purpose     = "Private-DNS"
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_private_dns_zone_virtual_network_link" "link_vnet0" {
  name                  = "link-vnet0"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.private.name
  virtual_network_id    = module.network_central.vnet_id
  registration_enabled  = true
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}
resource "azurerm_private_dns_zone_virtual_network_link" "link_hub" {
  name                  = "link-hub"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.private.name
  virtual_network_id    = module.hub.hub_vnet_id
  registration_enabled  = false
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}
resource "azurerm_private_dns_a_record" "db_private" {
  name                = "db"
  zone_name           = azurerm_private_dns_zone.private.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [module.database.mysql_private_endpoint_ip]
}
