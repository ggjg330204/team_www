resource "azurerm_linux_virtual_machine" "bas_vm" {
  name                = "www-bas"
  resource_group_name = var.rgname
  location            = var.loca
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  network_interface_ids = [
    var.bastion_nic_id,
  ]
  admin_ssh_key {
    username   = var.admin_username
    public_key = file("${path.module}/../../ssh/id_rsa_school.pub")
  }
  admin_ssh_key {
    username   = var.admin_username
    public_key = file("${path.module}/../../ssh/id_rsa_home.pub")
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "resf"
    offer     = "rockylinux-x86_64"
    sku       = "9-lvm"
    version   = "latest"
  }
  plan {
    publisher = "resf"
    product   = "rockylinux-x86_64"
    name      = "9-lvm"
  }
  user_data = base64encode(templatefile("${path.module}/../../scripts/bastion_init.sh", {
    admin_username = var.admin_username
  }))
  lifecycle {
    ignore_changes = [custom_data, user_data]
  }
}
output "bastion_public_ip" {
  value = "Public IP is managed in root module"
}
