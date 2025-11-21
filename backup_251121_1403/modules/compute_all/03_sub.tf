#modules\vm.tf\03_sub.tf\vnet x -redline
resource "azurerm_subnet" "www_bas" {
    #count = 5
    name = "www-bas"
    resource_group_name = var.rgname
    virtural_network_name = azurerm_virtual_network.www_vnet.name
    address_prefixes = [10.0.0.0/24]
    default_outbound_access_enabled = true
    depends_on = [ azurerm_virtual_network.www_vnet ]
}

resource "azurerm_subnet" "www_nat" {
    name = "www-nat"
    resource_group_name = var.rgname
    virtual_network_name = azurerm_virtual_network.www_vnet.name
    address_prefixes = [10.0.1.0/24]
    default_outbound_access_enabled = true
    depends_on = [ azurerm_virtual_network.www_vnet ]
}

resource "azurerm_subnet" "www_load" {
    name = "www-load"
    resource_group_name = var.rgname
    virtual_network_name = azurerm_virtual_network.www_vnet.name
    address_prefixes = [10.0.2.0/24]
    default_outbound_access_enabled = true
    depends_on = [ azurerm_virtual_network.www_vnet ]
}

resource "azurerm_subnet" "www_web1" {
    name = "www-web1"
    resource_group_name = var.rgname
    virtual_network_name = azurerm_virtual_network.www_vnet.name
    address_prefixes = [10.0.3.0/24]
    default_outbound_access_enabled = false
    depends_on = [ azurerm_virtual_network.www_vnet ]
}

resource "azurerm_subnet" "www_web2" {
    name = "www-web2"
    resource_group_name = var.rgname
    virtual_network_name = azurerm_virtual_network.www_vnet.name
    address_prefixes = [10.0.4.0/24]
    default_outbound_access_enabled = false
    depends_on = [ azurerm_virtual_network.www_vnet ]
}

resource "azurerm_subnet" "www_db" {
    name = "www-db"
    resource_group_name = var.rgname
    virtual_network_name = azurerm_virtual_network.www_vnet.name
    address_prefixes = [10.0.5.0/24]
    default_outbound_access_enabled = false
    depends_on = [ azurerm_virtual_network.www_vnet ]
}