#vnet0 nic
resource "azurerm_network_interface" "www_bas_nic" {
  name                = "${var.teamuser}-bas-nic"
  resource_group_name = azurerm_resource_group.www_rg.name
  location            = "KoreaCentral"

  ip_configuration {
    name                          = "www-bas-nic-ipconf"
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
  location            = "KoreaCentral"

  ip_configuration {
    name                          = "www-web1-nic-ipconf"
    subnet_id                     = azurerm_subnet.www_web1.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "10.0.2.4"
    # public_ip_address_id          = azurerm_public_ip.www_webip.id
  }
}

resource "azurerm_network_interface" "www_web2_nic" {
  name                = "${var.teamuser}-web2-nic"
  resource_group_name = azurerm_resource_group.www_rg.name
  location            = "KoreaCentral"

  ip_configuration {
    name                          = "www-web2-nic-ipconf"
    subnet_id                     = azurerm_subnet.www_web2.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "10.0.3.4"
    # public_ip_address_id          = azurerm_public_ip.www_webip.id
  }
}

resource "azurerm_network_interface" "www_db_nic" {
  name                = "${var.teamuser}db-nic"
  resource_group_name = azurerm_resource_group.www_rg.name
  location            = "KoreaCentral"

  ip_configuration {
    name                          = "www-db-nic-ipconf"
    subnet_id                     = azurerm_subnet.www_db.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "10.0.4.4"
    # public_ip_address_id          = azurerm_public_ip.www_dbip.id
  }
}

#vnet1 nic
resource "azurerm_network_interface" "www_app_nic" {
  name                = "${var.teamuser}app-nic"
  resource_group_name = azurerm_resource_group.www_rg.name
  location            = "KoreaSouth"

  ip_configuration {
    name                          = "www-app-nic-ipconf"
    subnet_id                     = azurerm_subnet.www_app.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "192.168.0.4"
    public_ip_address_id          = azurerm_public_ip.www_appip.id
  }
}

resource "azurerm_network_interface" "www_web1_v1_nic" {
  name                = "${var.teamuser}web1-v1-nic"
  resource_group_name = azurerm_resource_group.www_rg.name
  location            = "KoreaSouth"

  ip_configuration {
    name                          = "www-web1-v1-nic-ipconf"
    subnet_id                     = azurerm_subnet.www_web1_v1.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "192.168.3.4"
    # public_ip_address_id          = azurerm_public_ip.www_wep1ip.id
  }
}

resource "azurerm_network_interface" "www_web2_v1_nic" {
  name                = "${var.teamuser}web2-v1-nic"
  resource_group_name = azurerm_resource_group.www_rg.name
  location            = "KoreaSouth"

  ip_configuration {
    name                          = "www-web2-v1-nic-ipconf"
    subnet_id                     = azurerm_subnet.www_web2_v1.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "192.168.4.4"
    # public_ip_address_id          = azurerm_public_ip.www_wep2ip.id
  }
}
