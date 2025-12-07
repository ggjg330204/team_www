resource "azurerm_public_ip" "bastion_pip" {
  name                = "hub-bastion-pip"
  location            = var.loca
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
}
resource "azurerm_bastion_host" "hub_bastion" {
  name                = "hub-bastion"
  location            = var.loca
  resource_group_name = var.rgname
  sku                 = "Standard"
  tunneling_enabled   = true
  file_copy_enabled   = true

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
  tags = {
    Environment = "Production"
    Purpose     = "Hub-Bastion"
    ManagedBy   = "Terraform"
  }
}
