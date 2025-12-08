resource "azurerm_traffic_manager_profile" "www_tm" {
  name                   = "www-tm-${random_string.tm_suffix.result}"
  resource_group_name    = var.rgname
  traffic_routing_method = "Priority"
  dns_config {
    relative_name = "www-tm-${random_string.tm_suffix.result}"
    ttl           = 60
  }
  monitor_config {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }
  tags = {
    Environment = "Production"
    Purpose     = "Global-Traffic-Management"
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_traffic_manager_azure_endpoint" "www_tm_endpoint_primary" {
  name               = "www-tm-endpoint-primary"
  profile_id         = azurerm_traffic_manager_profile.www_tm.id
  priority           = 1
  weight             = 100
  target_resource_id = azurerm_public_ip.appgw_pip[0].id
}
resource "random_string" "tm_suffix" {
  length  = 6
  special = false
  upper   = false
}
