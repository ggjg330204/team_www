resource "azurerm_firewall_application_rule_collection" "web_google" {
  name                = "web-google"
  azure_firewall_name = azurerm_firewall.www_fw.name
  resource_group_name = azurerm_resource_group.04-1T-www.name
  priority            = 100
  action              = "Allow"

  rule {
    name = "web-to-google"

    source_addresses = [
      "10.0.0.0/16",
    ]

    target_fqdns = [
      "*.google.com",
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
}