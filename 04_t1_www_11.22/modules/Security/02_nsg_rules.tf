resource "azurerm_network_security_group" "nsg_ssh" {
  name                = "${var.vnet_name}-nsg-ssh"
  location            = var.loca
  resource_group_name = var.rgname

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefixes    = ["61.108.60.26", "10.0.0.0/8"] # Added 10.0.0.0/8 for internal access
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "22"
  }
}

resource "azurerm_network_security_group" "nsg_http" {
  name                = "${var.vnet_name}-nsg-http"
  location            = var.loca
  resource_group_name = var.rgname

  security_rule {
    name                       = "ssh-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_ranges    = ["22", "80"]
  }
}

resource "azurerm_network_security_group" "nsg_db" {
  name                = "${var.vnet_name}-nsg-db"
  location            = var.loca
  resource_group_name = var.rgname

  security_rule {
    name                       = "ssh-db"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "10.0.0.0/8" # Allow internal traffic
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_ranges    = ["22", "3306"]
  }
}
