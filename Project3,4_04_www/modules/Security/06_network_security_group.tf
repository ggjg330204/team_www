resource "azurerm_network_security_group" "nsg_ssh" {
  name                = "www-nsg-ssh"
  location            = var.loca
  resource_group_name = var.rgname
  tags = {
    Environment = "Production"
    Purpose     = "SSH-Access"
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_network_security_group" "nsg_http" {
  name                = "www-nsg-http"
  location            = var.loca
  resource_group_name = var.rgname
  tags = {
    Environment = "Production"
    Purpose     = "Web-Access"
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_network_security_group" "nsg_db" {
  name                = "www-nsg-db"
  location            = var.loca
  resource_group_name = var.rgname
  tags = {
    Environment = "Production"
    Purpose     = "Database-Access"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_network_security_group" "nsg_hub_bastion" {
  name                = "hub-nsg-bastion"
  location            = var.loca
  resource_group_name = var.rgname
  tags = {
    Environment = "Production"
    Purpose     = "Azure-Bastion-Service"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_network_security_rule" "hub_bas_https_inbound" {
  name                        = "AllowHttpsInbound"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "Internet"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "443"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.nsg_hub_bastion.name
}

resource "azurerm_network_security_rule" "hub_bas_gateway_manager" {
  name                        = "AllowGatewayManagerInbound"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "GatewayManager"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "443"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.nsg_hub_bastion.name
}

resource "azurerm_network_security_rule" "hub_bas_load_balancer" {
  name                        = "AllowAzureLoadBalancerInbound"
  priority                    = 140
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "AzureLoadBalancer"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "443"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.nsg_hub_bastion.name
}

resource "azurerm_network_security_rule" "hub_bas_host_communication" {
  name                        = "AllowBastionHostCommunication"
  priority                    = 150
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_address_prefix       = "VirtualNetwork"
  source_port_range           = "*"
  destination_address_prefix  = "VirtualNetwork"
  destination_port_ranges     = ["8080", "5701"]
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.nsg_hub_bastion.name
}

resource "azurerm_network_security_rule" "hub_bas_ssh_rdp_outbound" {
  name                        = "AllowSshRdpOutbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "VirtualNetwork"
  destination_port_ranges     = ["22", "3389"]
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.nsg_hub_bastion.name
}

resource "azurerm_network_security_rule" "hub_bas_azure_cloud_outbound" {
  name                        = "AllowAzureCloudOutbound"
  priority                    = 110
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "AzureCloud"
  destination_port_range      = "443"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.nsg_hub_bastion.name
}

resource "azurerm_network_security_rule" "hub_bas_communication_outbound" {
  name                        = "AllowBastionCommunicationOutbound"
  priority                    = 120
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_address_prefix       = "VirtualNetwork"
  source_port_range           = "*"
  destination_address_prefix  = "VirtualNetwork"
  destination_port_ranges     = ["8080", "5701"]
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.nsg_hub_bastion.name
}

resource "azurerm_network_security_rule" "hub_bas_get_session_outbound" {
  name                        = "AllowGetSessionInformation"
  priority                    = 130
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "Internet"
  destination_port_range      = "80"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.nsg_hub_bastion.name
}
resource "azurerm_network_security_rule" "web_http_https" {
  name                        = "allow-http-https"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_ranges     = ["80", "443"]
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.nsg_http.name
}
resource "azurerm_network_security_rule" "web_ssh_internal" {
  name                        = "allow-ssh-from-bastion"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefixes     = ["10.0.1.0/24", "10.1.1.0/24", "192.168.0.0/16"]
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "22"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.nsg_http.name
}
resource "azurerm_network_security_rule" "web_ssh_nat_pool" {
  name                        = "allow-ssh-nat-pool"
  priority                    = 105
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefixes     = var.ssh_allowed_ips
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "22"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.nsg_http.name
}
resource "azurerm_network_security_rule" "web_allow_lb" {
  name                        = "allow-azure-load-balancer"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_address_prefix       = "AzureLoadBalancer"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "*"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.nsg_http.name
}
resource "azurerm_network_security_rule" "web_allow_vnet" {
  name                        = "allow-vnet-internal"
  priority                    = 115
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_address_prefix       = "VirtualNetwork"
  source_port_range           = "*"
  destination_address_prefix  = "VirtualNetwork"
  destination_port_range      = "*"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.nsg_http.name
}
resource "azurerm_network_security_rule" "web_outbound" {
  name                        = "allow-web-outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "Internet"
  destination_port_ranges     = ["80", "443"]
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.nsg_http.name
}
resource "azurerm_network_security_rule" "web_dns_outbound" {
  name                        = "allow-dns-outbound"
  priority                    = 110
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "Internet"
  destination_port_range      = "53"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.nsg_http.name
}
resource "azurerm_network_security_rule" "web_smtp_inbound" {
  name                        = "allow-smtp-inbound"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_ranges     = ["25", "587"]
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.nsg_http.name
}
resource "azurerm_network_security_rule" "web_imap_inbound" {
  name                        = "allow-imap-inbound"
  priority                    = 140
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "993"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.nsg_http.name
}
resource "azurerm_network_security_rule" "web_smtp_outbound" {
  name                        = "allow-smtp-outbound"
  priority                    = 120
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "Internet"
  destination_port_ranges     = ["25", "587"]
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.nsg_http.name
}
resource "azurerm_network_security_rule" "web_deny_all" {
  name                        = "deny-all-inbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "*"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.nsg_http.name
}
resource "azurerm_network_security_rule" "db_access" {
  name                        = "allow-mysql-internal"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefixes     = ["10.0.1.0/24", "192.168.0.0/16"]
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "3306"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.nsg_db.name
}
resource "azurerm_network_security_rule" "ssh_internal" {
  name                        = "allow-ssh-internal"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "10.0.1.0/24"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "22"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.nsg_ssh.name
}
resource "azurerm_network_security_rule" "ssh_deny_all" {
  name                        = "deny-all-inbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "*"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.nsg_ssh.name
}
resource "azurerm_network_security_rule" "db_deny_all" {
  name                        = "deny-all-inbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "*"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.nsg_db.name
}



# [추가] Application Gateway NSG (인라인 규칙 적용)
resource "azurerm_network_security_group" "nsg_appgw" {
  name                = "www-nsg-appgw"
  location            = var.loca
  resource_group_name = var.rgname
  tags = {
    Environment = "Production"
    Purpose     = "AppGateway-Access"
    ManagedBy   = "Terraform"
  }

  security_rule {
    name                       = "allow-gateway-manager"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "GatewayManager"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "65200-65535"
  }

  security_rule {
    name                       = "allow-http-https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_ranges    = ["80", "443"]
  }

  security_rule {
    name                       = "allow-azure-load-balancer"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = "AzureLoadBalancer"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }
}

resource "azurerm_monitor_diagnostic_setting" "nsg_ssh_diag" {
  name                       = "nsg-ssh-diag"
  target_resource_id         = azurerm_network_security_group.nsg_ssh.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }
  enabled_log {
    category = "NetworkSecurityGroupRuleCounter"
  }
}

resource "azurerm_monitor_diagnostic_setting" "nsg_http_diag" {
  name                       = "nsg-http-diag"
  target_resource_id         = azurerm_network_security_group.nsg_http.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }
  enabled_log {
    category = "NetworkSecurityGroupRuleCounter"
  }
}

resource "azurerm_monitor_diagnostic_setting" "nsg_db_diag" {
  name                       = "nsg-db-diag"
  target_resource_id         = azurerm_network_security_group.nsg_db.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }
  enabled_log {
    category = "NetworkSecurityGroupRuleCounter"
  }
}

resource "azurerm_monitor_diagnostic_setting" "nsg_hub_bastion_diag" {
  name                       = "nsg-hub-bastion-diag"
  target_resource_id         = azurerm_network_security_group.nsg_hub_bastion.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }
  enabled_log {
    category = "NetworkSecurityGroupRuleCounter"
  }
}

resource "azurerm_monitor_diagnostic_setting" "nsg_appgw_diag" {
  name                       = "nsg-appgw-diag"
  target_resource_id         = azurerm_network_security_group.nsg_appgw.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }
  enabled_log {
    category = "NetworkSecurityGroupRuleCounter"
  }
}
