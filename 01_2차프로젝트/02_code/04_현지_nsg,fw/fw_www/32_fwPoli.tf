### 방화벽 정책
resource "azurerm_firewall_policy" "www_fwpo" {
  name                = "www-fwpo"
  resource_group_name = azurerm_resource_group.04-1T-www.name
  location            = azurerm_resource_group.04-1T-www.location
}


### 방화벽 정책 그룹
resource "azurerm_firewall_policy_rule_collection_group" "www_fwporcg" {
  name               = "www_fwporcg"
  firewall_policy_id = azurerm_firewall_policy.www_fwpo.id
  priority           = 500

  application_rule_collection {
    name     = "apprc1"
    priority = 300
    action   = "Allow"
    rule {
      name = "apprc1-1-http"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["*.04www.cloud"]
    }
  }

  network_rule_collection {
    name     = "netrc1"
    priority = 200
    action   = "Allow"
    rule {
      name                  = "netrc1-ssh"
      protocols             = ["TCP"]
      source_addresses      = ["61.108.60.26", "10.0.0.0/16", "172.17.0.0/16", "10.1.0.0/16"]
      destination_addresses = ["10.0.0.0/16", "10.1.0.0/16"]
      destination_ports     = ["22"]
    }
  }

  nat_rule_collection {
    name     = "natrc1"
    priority = 100
    action   = "Dnat"
    rule {
      name                = "natrc1"
      protocols           = ["TCP", "UDP"]
      source_addresses    = ["10.0.1.4", "10.0.1.5"]
      destination_address = "0.0.0.0/24"
      destination_ports   = ["80"]
      translated_address  = azurerm_public_ip.www_pip_app.ip_address
      translated_port     = "8080"
    }
  }
}