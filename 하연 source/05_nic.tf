#source\05_nic.tf
resource "azurerm_network_interface" "www_bas_nic" {
  name                = "${var.teamuser}-bas-nic"
  resource_group_name = var.rgname
  location            = var.loca

  ip_configuration {
    name                          = "hamap-bas-nic-ipconf"
    subnet_id                     = azurerm_subnet.www_bas.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "10.0.0.4"
    public_ip_address_id          = azurerm_public_ip.www_basip.id
  }
}

resource "azurerm_network_interface" "www_web1_nic" {
  name                = "${var.teamuser}-web1-nic"
  resource_group_name = var.rgname
  location            = var.loca

  ip_configuration {
    name                          = "hamap-web1-nic-ipconf"
    subnet_id                     = azurerm_subnet.www_web1.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "10.0.3.4"
    # public_ip_address_id          = azurerm_public_ip.www_webip.id
  }
}

resource "azurerm_network_interface" "www_db_nic" {
  name                = "${var.teamuser}db-nic"
  resource_group_name = var.rgname
  location            = var.loca

  ip_configuration {
    name                          = "hamap-db-nic-ipconf"
    subnet_id                     = azurerm_subnet.www_db.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "10.0.4.4"
    # public_ip_address_id          = azurerm_public_ip.www_dbip.id
  }
}

