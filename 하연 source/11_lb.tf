resource "azurerm_lb" "www_lb" {
  name                = "${var.teamuser}-lb"
  resource_group_name = var.rgname
  location            = var.loca
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "lbpublicip"
    public_ip_address_id = azurerm_public_ip.www_loadip.id
  }
}

resource "azurerm_lb_backend_address_pool" "www_back" {
  name            = "${var.teamuser}-back"
  loadbalancer_id = azurerm_lb.www_lb.id
}

resource "azurerm_lb_probe" "www_lb_probe" {
  name                = "${var.teamuser}-lb-probe"
  loadbalancer_id     = azurerm_lb.www_lb.id
  protocol            = "Http"
  port                = 80
  request_path        = "/health.html"
  interval_in_seconds = 5
}