#project\modules\Security\06_nsg.tf
resource "azurerm_network_security_group" "www_nsg_ssh" {
  name                = "www-nsg-ssh"
  location            = var.loca
  resource_group_name = var.rgname

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

resource "azurerm_network_security_group" "www_nsg_ssh_http" {
  name                = "www-nsg-ssh-http"
  location            = var.loca
  resource_group_name = var.rgname

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

resource "azurerm_network_security_group" "www_nsg_ssh_db" {
  name                = "www-nsg-ssh-db"
  location            = var.loca
  resource_group_name = var.rgname

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