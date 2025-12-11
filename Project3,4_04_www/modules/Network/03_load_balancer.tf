resource "azurerm_public_ip" "lb_pip" {
  name                = var.loca == "Korea Central" ? "www-lb-pip" : "www-lb-pip-south"
  location            = var.loca
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  domain_name_label   = "www-lb-koreacentral"
  tags = {
    Environment = "Production"
    Purpose     = "Load-Balancer"
    ManagedBy   = "Terraform"
  }
  lifecycle {
    create_before_destroy = false
    ignore_changes        = [zones, tags]
  }
}

locals {
  lb_internal_ip = "192.168.4.10"
}

resource "azurerm_lb" "vmss_lb" {
  name                = var.loca == "Korea Central" ? "www-lb" : "www-lb-south"
  location            = var.loca
  resource_group_name = var.rgname
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }

  tags = {
    Environment = "Production"
    Purpose     = "Load-Balancer"
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_lb_backend_address_pool" "bpepool" {
  loadbalancer_id = azurerm_lb.vmss_lb.id
  name            = "www-backend-pool"
}
resource "azurerm_lb_probe" "vmss_probe" {
  loadbalancer_id     = azurerm_lb.vmss_lb.id
  name                = "http-probe"
  port                = 80
  protocol            = "Http"
  request_path        = "/health.html"
  interval_in_seconds = 15
  number_of_probes    = 2
}
resource "azurerm_lb_rule" "vmss_lb_rule" {
  loadbalancer_id                = azurerm_lb.vmss_lb.id
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bpepool.id]
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.vmss_probe.id
}




resource "azurerm_lb_nat_pool" "ssh_nat_pool" {
  resource_group_name            = var.rgname
  loadbalancer_id                = azurerm_lb.vmss_lb.id
  name                           = "ssh-nat-pool"
  protocol                       = "Tcp"
  frontend_port_start            = 50001
  frontend_port_end              = 50010
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
}
resource "azurerm_lb" "was_lb" {
  name                = "www-was-lb"
  location            = var.loca
  resource_group_name = var.rgname
  sku                 = "Standard"
  frontend_ip_configuration {
    name                          = "InternalIPAddress"
    subnet_id                     = azurerm_subnet.subnets["www-was"].id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    Environment = "Production"
    Purpose     = "WAS-Load-Balancer"
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_lb_backend_address_pool" "was_backend_pool" {
  loadbalancer_id = azurerm_lb.was_lb.id
  name            = "www-was-backend-pool"
}
resource "azurerm_lb_probe" "was_probe" {
  loadbalancer_id     = azurerm_lb.was_lb.id
  name                = "was-http-probe"
  port                = 80
  protocol            = "Http"
  request_path        = "/health.php"
  interval_in_seconds = 15
  number_of_probes    = 2
}
resource "azurerm_lb_rule" "was_lb_rule" {
  loadbalancer_id                = azurerm_lb.was_lb.id
  name                           = "was-http"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.was_backend_pool.id]
  frontend_ip_configuration_name = "InternalIPAddress"
  probe_id                       = azurerm_lb_probe.was_probe.id
}
