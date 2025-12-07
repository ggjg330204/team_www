locals {
  mail_setup_script = templatefile("${path.module}/../../scripts/mail_server_setup.sh", {
    db_host     = var.db_host
    db_user     = var.db_user
    db_password = var.db_password
    db_name     = var.db_name
  })
  mail_cloud_init = <<-EOF
#cloud-config
package_update: true
package_upgrade: true

write_files:
  - path: /opt/mail_setup.sh
    permissions: '0755'
    content: |
      ${indent(6, local.mail_setup_script)}

runcmd:
  - /opt/mail_setup.sh
EOF
}

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
  size                            = "Standard_B2s"
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

  custom_data = base64encode(local.mail_cloud_init)

  tags = {
    Service = "Mail Server"
    Role    = "Postfix + Dovecot + Roundcube"
  }
}

resource "azurerm_virtual_machine_extension" "mail_ama" {
  name                 = "AzureMonitorLinuxAgent"
  virtual_machine_id   = azurerm_linux_virtual_machine.mail_vm.id
  publisher            = "Microsoft.Azure.Monitor"
  type                 = "AzureMonitorLinuxAgent"
  type_handler_version = "1.2"
  auto_upgrade_minor_version = true
}

resource "azurerm_monitor_data_collection_rule_association" "mail_vm_dcr" {
  name                    = "mail-vm-dcr-association"
  target_resource_id      = azurerm_linux_virtual_machine.mail_vm.id
  data_collection_rule_id = var.data_collection_rule_id
}

resource "azurerm_network_security_group" "mail_nsg" {
  name                = "mail-nsg"
  location            = var.loca
  resource_group_name = var.rgname
  tags                = {
    Service = "Mail Server"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "80"
  }

  security_rule {
    name                       = "AllowSSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = null
    source_address_prefixes    = var.ssh_allowed_ips
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "22"
  }

  security_rule {
    name                       = "AllowSMTP"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "25"
  }

  security_rule {
    name                       = "AllowIMAP"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "143"
  }

  security_rule {
    name                       = "AllowPOP3"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "110"
  }
}

resource "azurerm_network_interface_security_group_association" "mail_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.mail_nic.id
  network_security_group_id = azurerm_network_security_group.mail_nsg.id
}

resource "azurerm_monitor_diagnostic_setting" "nsg_mail_diag" {
  name                       = "nsg-mail-diag"
  target_resource_id         = azurerm_network_security_group.mail_nsg.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }
  enabled_log {
    category = "NetworkSecurityGroupRuleCounter"
  }
}
