resource "azurerm_traffic_manager_profile" "main" {
  name                   = "www-traffic-manager"
  resource_group_name    = azurerm_resource_group.rg.name
  traffic_routing_method = "Performance"
  dns_config {
    relative_name = "www-tm"
    ttl           = 60
  }
  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 10
    tolerated_number_of_failures = 3
  }
  tags = {
    Environment = "Production"
    Purpose     = "Traffic-Manager"
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_traffic_manager_azure_endpoint" "korea_central" {
  name               = "korea-central-endpoint"
  profile_id         = azurerm_traffic_manager_profile.main.id
  target_resource_id = module.network_central.lb_public_ip_id
  weight             = 100
  priority           = 1
}
