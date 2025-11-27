resource "azurerm_lb" "www_lb_v1" {
  name                = "${var.teamuser}-lb-v1"
  resource_group_name = var.rgname
  location            = "KoreaSouth"
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "lbpublicip"
    public_ip_address_id = azurerm_public_ip.www_loadip.id
  }
}

resource "azurerm_lb_backend_address_pool" "www_back_v1" {
  name            = "${var.teamuser}-back-v1"
  loadbalancer_id = azurerm_lb.www_lb_v1.id
}

resource "azurerm_lb_probe" "www_lb_probe_v1" {
  name                = "${var.teamuser}-lb-probe-v1"
  loadbalancer_id     = azurerm_lb.www_lb_v1.id
  protocol            = "Http"
  port                = 80
  request_path        = "/health.html"
  interval_in_seconds = 5
}