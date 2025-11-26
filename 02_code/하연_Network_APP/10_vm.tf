#source\10_vm.tf
resource "azurerm_linux_virtual_machine" "www_basvm" {
  name                  = "${var.teamuser}-basvm"
  resource_group_name   = azurerm_resource_group.www_rg.name
  location              = "KoreaCentral"
  size                  = "Standard_B1s"
  admin_username        = "www"
  network_interface_ids = [azurerm_network_interface.www_bas_nic.id]

  admin_ssh_key {
    username   = "www"
    #public_key = file("${path.module}/../../ssh/id_ed25519.pub")
    public_key = file("./id_ed25519.pub")
  }
  user_data = base64encode("${file("key.sh")}${file("bas.sh")}")

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
  boot_diagnostics {
    storage_account_uri = null
  }
}

resource "azurerm_linux_virtual_machine" "www_web1vm" {
  name                  = "${var.teamuser}-web1vm"
  resource_group_name   = azurerm_resource_group.www_rg.name
  location              = "KoreaCentral"
  size                  = "Standard_B1s"
  admin_username        = "www"
  network_interface_ids = [azurerm_network_interface.www_web1_nic.id]

  admin_ssh_key {
    username   = "www"
    #public_key = file("${path.module}/../../ssh/id_ed25519.pub")
    public_key = file("./id_ed25519.pub")
  }
  user_data = base64encode(file("web.sh")) 

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
  boot_diagnostics {
    storage_account_uri = null
  }
}

resource "azurerm_linux_virtual_machine" "www_web2vm" {
  name                  = "${var.teamuser}-web2vm"
  resource_group_name   = azurerm_resource_group.www_rg.name
  location              = "KoreaCentral"
  size                  = "Standard_B1s"
  admin_username        = "www"
  network_interface_ids = [azurerm_network_interface.www_web2_nic.id]

  admin_ssh_key {
    username   = "www"
    #public_key = file("${path.module}/../../ssh/id_ed25519.pub")
    public_key = file("./id_ed25519.pub")
  }
  user_data = base64encode(file("web.sh")) 

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
  boot_diagnostics {
    storage_account_uri = null
  }
}


resource "azurerm_linux_virtual_machine" "www_dbvm" {
  name                  = "${var.teamuser}-dbvm"
  resource_group_name   = azurerm_resource_group.www_rg.name
  location              = "KoreaCentral"
  size                  = "Standard_B1s"
  admin_username        = "www"
  network_interface_ids = [azurerm_network_interface.www_db_nic.id]

  admin_ssh_key {
    username   = "www"
    #public_key = file("${path.module}/../../ssh/id_ed25519.pub")
    public_key = file("./id_ed25519.pub")
  }
  user_data = base64encode(file("db.sh")) 

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
  boot_diagnostics {
    storage_account_uri = null
  }
}





resource "azurerm_linux_virtual_machine" "www_web1_v1" {
  name                  = "${var.teamuser}-web1-v1"
  resource_group_name   = azurerm_resource_group.www_rg.name
  location              = "KoreaSouth"
  size                  = "Standard_B1s"
  admin_username        = "www"
  network_interface_ids = [azurerm_network_interface.www_web1_v1_nic.id]

  admin_ssh_key {
    username   = "www"
    #public_key = file("${path.module}/../../ssh/id_ed25519.pub")
    public_key = file("./id_ed25519.pub")
  }
  user_data = base64encode(file("web.sh")) 

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
  boot_diagnostics {
    storage_account_uri = null
  }
}

resource "azurerm_linux_virtual_machine" "www_web2_v1" {
  name                  = "${var.teamuser}-web2-v1"
  resource_group_name   = azurerm_resource_group.www_rg.name
  location              = "KoreaSouth"
  size                  = "Standard_B1s"
  admin_username        = "www"
  network_interface_ids = [azurerm_network_interface.www_web2_v1_nic.id]

  admin_ssh_key {
    username   = "www"
    #public_key = file("${path.module}/../../ssh/id_ed25519.pub")
    public_key = file("./id_ed25519.pub")
  }
  user_data = base64encode(file("web.sh")) 

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
  boot_diagnostics {
    storage_account_uri = null
  }
}