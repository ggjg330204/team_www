#source\05_nic.tf
resource "azurerm_network_interface" "www_bas_nic" {
  name                = "${var.teamuser}-bas-nic"
  resource_group_name = azurerm_resource_group.www_rg.name
  location            = azurerm_resource_group.www_rg.location

  ip_configuration {
    name                          = "hamap-bas-nic"
    subnet_id                     = azurerm_subnet.www_bas.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "10.0.0.4"
    public_ip_address_id          = azurerm_public_ip.www_basip.id
  }
}

resource "azurerm_network_interface" "www_web1_nic" {
  name                = "${var.teamuser}-web1-nic"
  resource_group_name = azurerm_resource_group.www_rg.name
  location            = azurerm_resource_group.www_rg.location

  ip_configuration {
    name                          = "hamap-web1-nic"
    subnet_id                     = azurerm_subnet.www_web1.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "10.0.3.4"
  }
}

resource "azurerm_network_interface" "www_web2_nic" {
  name                = "${var.teamuser}-web2-nic"
  resource_group_name = azurerm_resource_group.www_rg.name
  location            = azurerm_resource_group.www_rg.location

  ip_configuration {
    name                          = "hamap-web2-nic"
    subnet_id                     = azurerm_subnet.www_web2.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "10.0.4.4"
  }
}

resource "azurerm_network_interface" "www_db_nic" {
  name                = "${var.teamuser}-db-nic"
  resource_group_name = azurerm_resource_group.www_rg.name
  location            = azurerm_resource_group.www_rg.location

  ip_configuration {
    name                          = "hamap-db-nic"
    subnet_id                     = azurerm_subnet.www_db.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "10.0.5.4"
  }
}