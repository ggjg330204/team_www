#project\modules\Security\06_nsg.tf
resource "azurerm_network_security_group" "www_nsg_ssh" {
  name                = var.www_nsg_ssh
  location            = var.loca
  resource_group_name = azurerm_resource_group.www_rg.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefixes    = ["61.108.60.26", "10.0.0.0/16", "192.168.0.0/16"]
    source_port_range          = "*"
    destination_address_prefix = "10.0.0.0/16"
    destination_port_range     = "22"
  }
}

resource "azurerm_network_security_group" "www_nsg_http" {
  name                = var.www_nsg_http
  location            = var.loca
  resource_group_name = azurerm_resource_group.www_rg.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefixes    = ["61.108.60.26", "10.0.0.0/16", "192.168.0.0/16"]
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

resource "azurerm_network_security_group" "www_nsg_db" {
  name                = var.www_nsg_db
  location            = var.loca
  resource_group_name = azurerm_resource_group.www_rg.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefixes    = ["61.108.60.26", "10.0.0.0/16", "192.168.0.0/16"]
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
    source_address_prefixes    = ["10.0.0.0/16", "192.168.0.0/16"]
    source_port_range          = "*"
    destination_address_prefix = "10.0.0.0/16"
    destination_port_range     = "3306"
  }
}

resource "azurerm_network_security_group" "www_v1_nsg_http" {
  name                = var.www_v1_nsg_http
  location            = var.loca2
  resource_group_name = azurerm_resource_group.www_rg.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefixes    = ["61.108.60.26", "10.0.0.0/16", "192.168.0.0/16"]
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
