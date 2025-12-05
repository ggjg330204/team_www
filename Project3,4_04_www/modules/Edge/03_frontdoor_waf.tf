resource "azurerm_cdn_frontdoor_firewall_policy" "waf_policy" {
  name                              = "wwwfdwafpolicy${random_string.waf_suffix.result}"
  resource_group_name               = var.rgname
  sku_name                          = azurerm_cdn_frontdoor_profile.www_cdn.sku_name
  enabled                           = true
  mode                              = "Prevention"
  custom_block_response_status_code = 403
  custom_block_response_body        = base64encode("Access Denied by WAF")
  managed_rule {
    type    = "Microsoft_DefaultRuleSet"
    version = "2.1"
    action  = "Block"
  }
}

resource "azurerm_cdn_frontdoor_security_policy" "waf_association" {
  name                     = "www-waf-association"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.www_cdn.id
  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.waf_policy.id
      association {
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.www_fd_endpoint.id
        }
        patterns_to_match = ["/*"]
      }
    }
  }
}
resource "random_string" "waf_suffix" {
  length  = 6
  special = false
  upper   = false
}
