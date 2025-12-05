resource "azurerm_public_ip" "cross_region_lb_pip" {
  count               = var.enable_cross_lb ? 1 : 0
  name                = "cross-region-lb-pip"
  resource_group_name = var.rgname
  location            = var.loca
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Global"
}
resource "azurerm_lb" "cross_region_lb" {
  count               = var.enable_cross_lb ? 1 : 0
  name                = "www-cross-region-lb"
  location            = var.loca
  resource_group_name = var.rgname
  sku                 = "Standard"
  sku_tier            = "Global"
  frontend_ip_configuration {
    name                 = "GlobalFrontend"
    public_ip_address_id = azurerm_public_ip.cross_region_lb_pip[0].id
  }
  tags = {
    Environment = "Production"
    Purpose     = "Global-Load-Balancer"
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_lb_backend_address_pool" "global_backend" {
  count           = var.enable_cross_lb ? 1 : 0
  loadbalancer_id = azurerm_lb.cross_region_lb[0].id
  name            = "GlobalBackendPool"
}