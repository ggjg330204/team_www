resource "azurerm_route_table" "spoke_rt" {
  name                = "spoke-rt"
  location            = var.loca
  resource_group_name = var.rgname
  bgp_route_propagation_enabled = true

  route {
    name                   = "to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.firewall_private_ip
  }

  tags = {
    Environment = "Production"
    Purpose     = "Data-Exfiltration-Prevention"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_subnet_route_table_association" "web_rt_assoc" {
  subnet_id      = azurerm_subnet.subnets["www-web"].id
  route_table_id = azurerm_route_table.spoke_rt.id
}



resource "azurerm_subnet_route_table_association" "db_rt_assoc" {
  subnet_id      = azurerm_subnet.subnets["www-db"].id
  route_table_id = azurerm_route_table.spoke_rt.id
}
