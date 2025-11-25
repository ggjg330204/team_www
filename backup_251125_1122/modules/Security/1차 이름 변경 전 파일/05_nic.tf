#project\modules\Security\05_nic.tf
resource "azurerm_network_interface" "hj_nic_bas" {
  name                = "hj-nic-bas"
  resource_group_name = azurerm_resource_group.hj_rg.name
  location            = azurerm_resource_group.hj_rg.location

  ip_configuration {
    name                          = "hj-ip-bas"
    subnet_id                     = azurerm_subnet.hj_sub_bas.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "10.0.0.4"
    public_ip_address_id          = azurerm_public_ip.hj_pip_bas.id
  }
}

resource "azurerm_network_interface" "hj_nic_nat" {
  name                = "hj-nic-nat"
  resource_group_name = azurerm_resource_group.hj_rg.name
  location            = azurerm_resource_group.hj_rg.location

  ip_configuration {
    name                          = "hj-ip-nat"
    subnet_id                     = azurerm_subnet.hj_sub_nat.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "10.0.1.4"
  }
}

resource "azurerm_network_interface" "hj_nic_web" {
  name                = "hj-nic-web"
  resource_group_name = azurerm_resource_group.hj_rg.name
  location            = azurerm_resource_group.hj_rg.location

  ip_configuration {
    name                          = "hj-ip-web"
    subnet_id                     = azurerm_subnet.hj_sub_web.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "10.0.3.4"
  }
}

resource "azurerm_network_interface" "hj_nic_db" {
  name                = "hj-nic-db"
  resource_group_name = azurerm_resource_group.hj_rg.name
  location            = azurerm_resource_group.hj_rg.location

  ip_configuration {
    name                          = "hj-ip-db"
    subnet_id                     = azurerm_subnet.hj_sub_db.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "10.0.4.4"
  }
}

/* resource "azurerm_network_interface" "hj_nic_app" {
  name                = "hj-nic-app"
  resource_group_name = azurerm_resource_group.hj_rg.name
  location            = azurerm_resource_group.hj_rg.location

  ip_configuration {
    name                          = "hj-ip-app"
    subnet_id                     = azurerm_subnet.hj_sub_app.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "10.0.2.4"
    public_ip_address_id          = azurerm_public_ip.hj_pip_app.id
  }
} */