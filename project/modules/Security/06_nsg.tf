#project\modules\Security\06_nsg.tf
resource "azurerm_network_security_group" "hj_nsg_ssh" {
  name                = "hj-nsg-ssh"
  location            = azurerm_resource_group.hj_rg.location
  resource_group_name = azurerm_resource_group.hj_rg.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefixes    = ["61.108.60.26", "10.0.0.0/16"]
    source_port_range          = "*"
    destination_address_prefix = "10.0.0.0/16"
    destination_port_range     = "22"
  }
}

resource "azurerm_network_security_group" "hj_nsg_ssh_http" {
  name                = "hj-nsg-ssh-http"
  location            = azurerm_resource_group.hj_rg.location
  resource_group_name = azurerm_resource_group.hj_rg.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefixes    = ["61.108.60.26", "10.0.0.0/16"]
    source_port_range          = "*"
    destination_address_prefix = "10.0.0.0/16"
    destination_port_range     = "22"
  }

    security_rule {
    name                       = "http"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "10.0.0.0/16"
    destination_port_range     = "80"
  }
}

resource "azurerm_network_security_group" "hj_nsg_ssh_db" {
  name                = "hj-nsg-ssh-db"
  location            = azurerm_resource_group.hj_rg.location
  resource_group_name = azurerm_resource_group.hj_rg.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefixes    = ["61.108.60.26", "10.0.0.0/16"]
    source_port_range          = "*"
    destination_address_prefix = "10.0.0.0/16"
    destination_port_range     = "22"
  }

    security_rule {
    name                       = "db"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix    = "10.0.0.0/16"
    source_port_range          = "*"
    destination_address_prefix = "10.0.0.0/16"
    destination_port_range     = "3306"
  }
}