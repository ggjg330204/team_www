#modules\vm.tf\04_pubip.tf
resource "azurerm_public_ip" "www_basip" {
    name = "www-basip"
    location = var.loca
    resource_group_name = var.rgname
    allocation_method = "Static"
    sku = "Standard"
    ip_version = "IPv4"
    depends_on = [ azurerm_subnet.www_bas ]
}

resource "azurerm_public_ip" "www_natip" {
  name = "www-natip"
  location = var.loca
  resource_group_name = var.rgname
  allocation_method = "Static"
  sku = "Standard"
  ip_version = "IPv4"
  depends_on = [ azurerm_subnet.www_nat ]
}

resource "azurerm_public_ip" "www_loadip" {
  name = "www-loadip"
  location = var.loca
  resource_group_name = var.rgname
  allocation_method = "Static"
  sku = "Standard"
  ip_version = "IPv4"
  depends_on = [ azurerm_subnet.www_load ]
}