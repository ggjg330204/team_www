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

  route {
    name           = "to-vnet-172"
    address_prefix = "172.16.0.0/16"
    next_hop_type  = "VnetLocal"
  }

  route {
    name           = "to-vnet-192"
    address_prefix = "192.168.0.0/16"
    next_hop_type  = "VnetLocal"
  }

  route {
    name           = "to-vnet-10"
    address_prefix = "10.0.0.0/16"
    next_hop_type  = "VnetLocal"
  }

  dynamic "route" {
    for_each = var.ssh_allowed_ips
    content {
      name           = "ssh-bypass-${index(var.ssh_allowed_ips, route.value)}"
      address_prefix = "${route.value}/32"
      next_hop_type  = "Internet"
    }
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

resource "azurerm_subnet_route_table_association" "was_rt_assoc" {
  subnet_id      = azurerm_subnet.subnets["www-was"].id
  route_table_id = azurerm_route_table.spoke_rt.id
}

resource "azurerm_route_table" "appgw_rt" {
  name                          = "appgw-rt"
  location                      = var.loca
  resource_group_name           = var.rgname
  bgp_route_propagation_enabled = true

  route {
    name           = "to-web-direct"
    address_prefix = "192.168.1.0/24"
    next_hop_type  = "VnetLocal"
  }

  route {
    name           = "to-was-direct"
    address_prefix = "192.168.5.0/24"
    next_hop_type  = "VnetLocal"
  }

  route {
    name                   = "to-firewall-10"
    address_prefix         = "10.0.0.0/8"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.firewall_private_ip
  }

  route {
    name                   = "to-firewall-172"
    address_prefix         = "172.16.0.0/12"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.firewall_private_ip
  }

  route {
    name                   = "to-firewall-192"
    address_prefix         = "192.168.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.firewall_private_ip
  }

  tags = {
    Environment = "Production"
    Purpose     = "AppGw-Routing"
    ManagedBy   = "Terraform"
  }
}
