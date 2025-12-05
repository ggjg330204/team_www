resource "azurerm_dns_zone" "public" {
  name                = "04www.cloud"
  resource_group_name = var.rgname
  tags = {
    Environment = "Production"
    Purpose     = "Public-DNS"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_dns_cname_record" "www_public" {
  name                = "www"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = var.rgname
  ttl                 = 300
  record              = var.frontdoor_endpoint_hostname
}

resource "azurerm_dns_txt_record" "www_validation" {
  name                = "_dnsauth.www"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = var.rgname
  ttl                 = 300

  record {
    value = var.www_domain_validation_token
  }
}

resource "azurerm_dns_txt_record" "apex_validation" {
  name                = "_dnsauth"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = var.rgname
  ttl                 = 300

  record {
    value = var.apex_domain_validation_token
  }
}

resource "azurerm_dns_a_record" "root_public" {
  name                = "@"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = var.rgname
  ttl                 = 300
  target_resource_id  = var.frontdoor_endpoint_id
}
