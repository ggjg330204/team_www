# Azure Bastion 구성
# VMSS 및 Database 접속을 위한 Bastion Host

# Bastion용 서브넷 (반드시 AzureBastionSubnet 이름 사용)
resource "azurerm_subnet" "bastion_subnet" {
  count                = var.enable_bastion ? 1 : 0
  name                 = "AzureBastionSubnet"  # 고정 이름 (Azure 요구사항)
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.255.0/26"]  # 최소 /26 필요
}

# Bastion용 Public IP
resource "azurerm_public_ip" "bastion_pip" {
  count               = var.enable_bastion ? 1 : 0
  name                = "bastion-pip"
  location            = var.loca
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Azure Bastion Host
resource "azurerm_bastion_host" "bastion" {
  count               = var.enable_bastion ? 1 : 0
  name                = "www-bastion"
  location            = var.loca
  resource_group_name = var.rgname

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion_subnet[0].id
    public_ip_address_id = azurerm_public_ip.bastion_pip[0].id
  }

  tags = {
    Environment = "Production"
    Purpose     = "Secure Access"
  }
}
