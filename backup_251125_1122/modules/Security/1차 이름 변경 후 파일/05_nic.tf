#project\modules\Security\05_nic.tf
resource "azurerm_network_interface" "www_nic_bas" {
  name                = "www-nic-bas"
  resource_group_name = var.rgname
  location            = var.loca

  ip_configuration {
    name                          = "www-ip-bas"
    subnet_id                     = azurerm_subnet.www_sub_bas.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "10.0.0.4"
    public_ip_address_id          = azurerm_public_ip.www_pip_bas.id
  }
}

resource "azurerm_network_interface" "www_nic_nat" {
  name                = "www-nic-nat"
  resource_group_name = var.rgname
  location            = var.loca

  ip_configuration {
    name                          = "www-ip-nat"
    subnet_id                     = azurerm_subnet.www_sub_nat.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "10.0.1.4"
  }
}

resource "azurerm_network_interface" "www_nic_web" {
  name                = "www-nic-web"
  resource_group_name = var.rgname
  location            = var.loca

  ip_configuration {
    name                          = "www-ip-web"
    subnet_id                     = azurerm_subnet.www_sub_web.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "10.0.3.4"
  }
}

resource "azurerm_network_interface" "www_nic_db" {
  name                = "www-nic-db"
  resource_group_name = var.rgname
  location            = var.loca

  ip_configuration {
    name                          = "www-ip-db"
    subnet_id                     = azurerm_subnet.www_sub_db.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "10.0.4.4"
  }
}

/* resource "azurerm_network_interface" "www_nic_app" {
  name                = "www-nic-app"
  resource_group_name = var.rgname
  location            = var.loca

  ip_configuration {
    name                          = "www-ip-app"
    subnet_id                     = azurerm_subnet.www_sub_app.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "10.0.2.4"
    public_ip_address_id          = azurerm_public_ip.www_pip_app.id
  }
} */