resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "web-vmss"
  resource_group_name = var.rgname
  location            = var.loca
  sku                 = "Standard_D2s_v3"
  instances           = 2
  admin_username      = var.admin_username
  source_image_id     = azurerm_shared_image_version.version.id
  upgrade_mode        = "Rolling"
  health_probe_id     = var.lb_probe_id
  zones               = ["1", "2"]
  overprovision       = false
  rolling_upgrade_policy {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 5
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
  plan {
    publisher = "resf"
    product   = "rockylinux-x86_64"
    name      = "9-lvm"
  }
  user_data = base64encode(templatefile("${path.module}/../../scripts/vmss_web_init.sh", {
    was_lb_ip = var.was_lb_private_ip
  }))
  tags = {
    Environment = "Production"
    Purpose     = "Web-Scale-Set"
    ManagedBy   = "Terraform"
  }
}
