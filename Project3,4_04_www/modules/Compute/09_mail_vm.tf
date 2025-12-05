resource "azurerm_public_ip" "mail_pip" {
  name                = "mail-pip"
  location            = var.loca
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "mail_nic" {
  name                = "mail-nic"
  location            = var.loca
  resource_group_name = var.rgname

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.vm_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mail_pip.id
  }
}

resource "azurerm_linux_virtual_machine" "mail_vm" {
  name                            = "mail-vm"
  location                        = var.loca
  resource_group_name             = var.rgname
  size                            = "Standard_B1s"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.mail_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(file("${path.module}/../../scripts/mail_server_setup.sh"))
}
