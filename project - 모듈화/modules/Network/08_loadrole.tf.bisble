resource "azurerm_lb_rule" "www_lb_rule_v1" {
  name                           = "${var.teamuser}-lb-rule-v1"
  loadbalancer_id                = azurerm_lb.www_lb_v1.id
  frontend_ip_configuration_name = "lbpublicip"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.www_back_v1.id]
  probe_id                       = azurerm_lb_probe.www_lb_probe_v1.id

}