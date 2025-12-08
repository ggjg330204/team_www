resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "web-vmss"
  resource_group_name = var.rgname
  location            = var.loca
  sku                 = "Standard_D2s_v3"
  instances           = 2
  admin_username      = var.admin_username

  upgrade_mode        = "Rolling"
  health_probe_id     = var.lb_probe_id
  zones               = ["1", "2"]
  overprovision       = false
  rolling_upgrade_policy {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 100
    max_unhealthy_upgraded_instance_percent = 100
    pause_time_between_batches              = "PT0S"
  }
  automatic_os_upgrade_policy {
    disable_automatic_rollback  = false
    enable_automatic_os_upgrade = false
  }
  automatic_instance_repair {
    enabled      = true
    grace_period = "PT30M"
  }
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
  network_interface {
    name                          = "vmss-nic"
    primary                       = true
    enable_accelerated_networking = true
    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = var.vmss_subnet_id
      load_balancer_backend_address_pool_ids = [var.lb_backend_pool_id]
      load_balancer_inbound_nat_rules_ids    = [var.ssh_nat_pool_id]
    }
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [var.vmss_identity_id]
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
  extension {
    name                       = "WebInitScript"
    publisher                  = "Microsoft.Azure.Extensions"
    type                       = "CustomScript"
    type_handler_version       = "2.1"
    auto_upgrade_minor_version = true
    protected_settings = jsonencode({
      script = base64encode(templatefile("${path.module}/../../scripts/web_init.tftpl", {
        was_lb_ip        = var.was_lb_private_ip
        app_insights_key = var.app_insights_key
      }))
    })
  }
  tags = {
    Environment = "Production"
    Purpose     = "Web-Scale-Set"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_virtual_machine_scale_set_extension" "ama" {
  name                         = "AzureMonitorLinuxAgent"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.vmss.id
  publisher                    = "Microsoft.Azure.Monitor"
  type                         = "AzureMonitorLinuxAgent"
  type_handler_version         = "1.2"
  auto_upgrade_minor_version   = true
}

resource "azurerm_monitor_data_collection_rule_association" "vmss_dcr" {
  name                    = "vmss-dcr-association"
  target_resource_id      = azurerm_linux_virtual_machine_scale_set.vmss.id
  data_collection_rule_id = var.data_collection_rule_id
}
