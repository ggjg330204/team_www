resource "azurerm_public_ip" "fw_pip" {
  name                = "hub-fw-pip"
  location            = var.loca
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2"]
  tags = {
    Environment = "Production"
    Purpose     = "Firewall-PIP"
    ManagedBy   = "Terraform"
  }
  lifecycle {
    create_before_destroy = false
    ignore_changes = [zones, tags]
  }
}
resource "azurerm_firewall" "hub_fw" {
  name                = "hub-firewall"
  location            = var.loca
  resource_group_name = var.rgname
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.fw_policy.id
  zones               = ["1", "2"]
  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.fw_subnet.id
    public_ip_address_id = azurerm_public_ip.fw_pip.id
  }
  tags = {
    Environment = "Production"
    Purpose     = "Hub-Firewall"
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_firewall_policy" "fw_policy" {
  name                = "hub-fw-policy"
  resource_group_name = var.rgname
  location            = var.loca
}
resource "azurerm_firewall_policy_rule_collection_group" "fw_policy_rcg" {
  name               = "hub-fw-policy-rcg"
  firewall_policy_id = azurerm_firewall_policy.fw_policy.id
  priority           = 100
  application_rule_collection {
    name     = "app_rules"
    priority = 100
    action   = "Allow"
    rule {
      name = "Allow-Windows-Update"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["*.update.microsoft.com", "*.windowsupdate.com"]
    }
    rule {
      name = "Allow-Azure-Services"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["management.azure.com", "login.microsoftonline.com"]
    }
  }
  network_rule_collection {
    name     = "network_rules"
    priority = 200
    action   = "Allow"
    rule {
      name                  = "Allow-DNS"
      protocols             = ["UDP", "TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["53"]
    }
    rule {
      name                  = "Allow-NTP"
      protocols             = ["UDP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["123"]
    }
  }
}
