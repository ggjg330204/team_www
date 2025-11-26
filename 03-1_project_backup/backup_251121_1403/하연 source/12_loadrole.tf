resource "azurerm_lb_rule" "www_lb_rule" {
  name                           = "${var.teamuser}-lb-rule"
  loadbalancer_id                = azurerm_lb.www_lb.id
  frontend_ip_configuration_name = "lbpublicip"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.www_back.id]
  probe_id                       = azurerm_lb_probe.www_lb_probe.id

}
