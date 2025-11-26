# modules/Network/03_dns.tf

# 1. 공용 DNS Zone (04www.cloud)
resource "azurerm_dns_zone" "public" {
  name                = "04www.cloud"
  resource_group_name = var.rg_name
}

# 1-1. www 레코드 -> AppGateway Public IP 연결
resource "azurerm_dns_a_record" "www_public" {
  name                = "www"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = var.rg_name
  ttl                 = 300
  records             = [azurerm_public_ip.www_appip.ip_address]
}

# 1-2. 루트(@) 레코드 -> AppGateway Public IP 연결
resource "azurerm_dns_a_record" "root_public" {
  name                = "@"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = var.rg_name
  ttl                 = 300
  records             = [azurerm_public_ip.www_appip.ip_address]
}


# 2. 사설 DNS Zone (04www.cloud)
resource "azurerm_private_dns_zone" "private" {
  name                = "04www.cloud"
  resource_group_name = var.rg_name
}

# 3. VNet0 연결 (Korea Central)
resource "azurerm_private_dns_zone_virtual_network_link" "link_vnet0" {
  name                  = "link-vnet0"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.private.name
  virtual_network_id    = azurerm_virtual_network.www_vnet0.id
  registration_enabled  = true
}

# 4. VNet1 연결 (Korea South)
resource "azurerm_private_dns_zone_virtual_network_link" "link_vnet1" {
  name                  = "link-vnet1"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.private.name
  virtual_network_id    = azurerm_virtual_network.www_vnet1.id
  registration_enabled  = true
}

# 5. DB 사설 IP 레코드
resource "azurerm_private_dns_a_record" "db_private" {
  name                = "db"
  zone_name           = azurerm_private_dns_zone.private.name
  resource_group_name = var.rg_name
  ttl                 = 300
  records             = [azurerm_network_interface.www_db_nic.private_ip_address]
}
