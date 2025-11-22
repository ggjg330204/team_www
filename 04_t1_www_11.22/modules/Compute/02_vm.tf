resource "azurerm_network_interface" "webvm_nic" {
  name                = "webvm-nic"
  location            = var.loca
  resource_group_name = var.rgname

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.vm_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "webvm" {
  name                = "webvm-source"
  resource_group_name = var.rgname
  location            = var.loca
  size                = "Standard_B2s"
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.webvm_nic.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("${path.module}/../../ssh/id_ed25519.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "resf"
    offer     = "rockylinux-x86_64"
    sku       = "9-lvm"
    version   = "9.3.20231113"
  }
  
  plan {
    publisher = "resf"
    product   = "rockylinux-x86_64"
    name      = "9-lvm"
  }

  user_data = base64encode(file("${path.module}/../../scripts/ins.sh"))

  identity {
    type = "SystemAssigned"
  }
}
