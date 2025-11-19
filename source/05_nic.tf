resource "azurerm_network_interface" "www_bas_nic" {
  name                = "www-bas-nic"
  resource_group_name = var.rgname
  location            = var.loca

  ip_configuration {
    name                          = "hamap-bas-nic"
    subnet_id                     = azurerm_subnet.www_bas.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "10.0.0.4"
    public_ip_address_id          = azurerm_public_ip.www_basip.id
  }
}