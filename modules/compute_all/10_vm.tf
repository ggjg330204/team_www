#modules\vm.tf\10_vm.tf
resource "azurerm_linux_virtual_machine" "www_basvm" {
    name = "www-basvm"
    resource_group_name = var.rgname
    location = var.loca
    size = local.size
    admin_username = local.user
    network_interface_ids = [azurerm_network_interface.www_bas_nic.id]


admin_ssh_key {
    username = local.user
    public_key = file("./id_ed25519.pub")
}
user_data = base64encode("${file("key.sh")}${file("bas.sh")}")

os_disk {
    caching = "READWrite"
    storage_account_type = "Standard_LRS"
}

source_image_reference {
    publisher = "resf"
    offer = "rockylinux-x86_64"
    sku = "9-1vm"
    version = "9.3.20231113"
}

plan {
    publisher = "resf"
    product = "rockylinux-x86_64"
    name = "9-1vm"
}

boot_diagnostics {
    storage_account_uri = null
}
}

resource "azurerm_linux_virtual_machine" "www_web1vm" {
    name = "www-web1vm"
    resource_group_name = var.rgname
    location = var.loca
    size = local.size1
    admin_username = local.user
    network_interface_ids = [azurerm_network_interface.www_web1_nic.id]


admin_ssh_key {
    username = local.user
    public_key = file("./id_ed25519.pub")
}
user_data = base64encode(file("web.sh"))

os_disk {
    caching = "READWrite"
    storage_account_type = "Standard_LRS"
}

source_image_reference {
    publisher = "resf"
    offer = "rockylinux-x86_64"
    sku = "9-1vm"
    version = "9.3.20231113"
}

plan {
    publisher = "resf"
    product = "rockylinux-x86_64"
    name = "9-1vm"
}
boot_diagnostics {
    storage_account_uri = null
}
}

resource "azurerm_linux_virtual_machine" "www_web2vm" {
    name = "www-web2vm"
    resource_group_name = var.rgname
    location = var.loca
    size = local.size1
    admin_username = local.user
    network_interface_ids = [azurerm_network_interface.www_web2_nic.id]


admin_ssh_key {
    username = local.user
    public_key = file("./id_ed25519.pub")
}
user_data = base64encode(file("web.sh"))

os_disk {
    caching = "READWrite"
    storage_account_type = "Standard_LRS"
}

source_image_reference {
    publisher = "resf"
    offer = "rockylinux-x86_64"
    sku = "9-1vm"
    version = "9.3.20231113"
}

plan {
    publisher = "resf"
    product = "rockylinux-x86_64"
    name = "9-1vm"
}
boot_diagnostics {
    storage_account_uri = null
}
}

resource "azurerm_linux_virtual_machine" "www_dbvm" {
    name = "www-dbvm"
    resource_group_name = var.rgname
    location = var.loca
    size = local.size
    admin_username = local.user
    network_interface_ids = [azurerm_network_interface.www_db_nic.id]


admin_ssh_key {
    username = local.user
    public_key = file("./id_ed25519.pub")
}
user_data = base64encode(file("db.sh"))

os_disk {
    caching = "READWrite"
    storage_account_type = "Standard_LRS"
}

source_image_reference {
    publisher = "resf"
    offer = "rockylinux-x86_64"
    sku = "9-1vm"
    version = "9.3.20231113"
}

plan {
    publisher = "resf"
    product = "rockylinux-x86_64"
    name = "9-1vm"
}
boot_diagnostics {
    storage_account_uri = null
}
}

locals {
    size = "Standard_B2s_v2"
    size1 = "Standard_B4ls_v2"
    user = "www"
}