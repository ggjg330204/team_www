resource "azurerm_network_interface" "webvm_nic" {
  name                = "webvm-nic"
  location            = var.loca
  resource_group_name = var.rgname
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.vm_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
  accelerated_networking_enabled = true
}
resource "azurerm_linux_virtual_machine" "webvm" {
  name                = "webvm"
  resource_group_name = var.rgname
  location            = var.loca
  size                = "Standard_D2s_v3"
  admin_username      = var.admin_username
  zone                = "1"
  network_interface_ids = [
    azurerm_network_interface.webvm_nic.id,
  ]
  admin_ssh_key {
    username   = var.admin_username
    public_key = file("${path.module}/../../ssh/id_rsa_school.pub")
  }
  admin_ssh_key {
    username   = var.admin_username
    public_key = file("${path.module}/../../ssh/id_rsa_home.pub")
  }
  
  admin_password                  = var.admin_password
  disable_password_authentication = false
  os_disk {
    caching              = "ReadOnly"
    storage_account_type = "Premium_LRS"
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
  user_data = base64encode(templatefile("${path.module}/../../scripts/web_init.tftpl", {
    was_lb_ip        = var.was_lb_private_ip
    app_insights_key = var.app_insights_key
  }))
  identity {
    type = "SystemAssigned"
  }
  tags = {
    Environment = "Production"
    Purpose     = "Web-Server"
    ManagedBy   = "Terraform"
    Backup      = "Enabled"
  }
  lifecycle {
    ignore_changes = [custom_data]
  }
}
