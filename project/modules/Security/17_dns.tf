resource "azurerm_dns_zone" "hj_dns" {
  name = "hjmscs4.site"
  resource_group_name = var.rgname
  depends_on = [ azurerm_resource_group.hj_rg ]
}

resource "azurerm_dns_a_record" "hj_record1" {
  name = "@"
  zone_name = azurerm_dns_zone.hj_dns.name
  resource_group_name = var.rgname
  ttl = 300
  records = [azurerm_public_ip.hj_pip_app.ip_address]
}

resource "azurerm_dns_a_record" "name" {
  name = "www"
  zone_name = azurerm_dns_zone.hj_dns.name
  resource_group_name = var.rgname
  ttl = 300
  records = [azurerm_public_ip.hj_pip_app.ip_address]
}