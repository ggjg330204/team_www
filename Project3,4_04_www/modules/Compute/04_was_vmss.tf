resource "azurerm_linux_virtual_machine_scale_set" "was_vmss" {
  name                = "was-vmss"
  resource_group_name = var.rgname
  location            = var.loca
  sku                 = "Standard_D2s_v3"
  instances           = 1
  admin_username      = var.admin_username
  source_image_id     = azurerm_shared_image_version.version.id
  upgrade_mode        = "Rolling"
  health_probe_id     = var.was_lb_probe_id
  zones               = ["1", "2"]
  overprovision       = true
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

  admin_password                  = var.admin_password
  disable_password_authentication = false
  os_disk {
    caching              = "ReadOnly"
    storage_account_type = "Premium_LRS"
  }
  network_interface {
    name                          = "was-vmss-nic"
    primary                       = true
    enable_accelerated_networking = true
    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = var.was_subnet_id
      load_balancer_backend_address_pool_ids = [var.was_lb_backend_pool_id]
    }
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [var.vmss_identity_id]
  }
  plan {
    publisher = "resf"
    product   = "rockylinux-x86_64"
    name      = "9-lvm"
  }
  user_data = base64encode(templatefile("${path.module}/../../scripts/was_init.tftpl", {
    db_host    = var.db_host
    db_ro_host = var.db_ro_host
    db_user    = var.db_user
    db_password= var.db_password
    db_name    = var.db_name
    redis_host = var.redis_hostname
    redis_key        = var.redis_primary_key
    redis_port       = var.redis_port
    app_insights_key = var.app_insights_key
  }))
  tags = {
    Environment = "Production"
    Purpose     = "WAS-Scale-Set"
    ManagedBy   = "Terraform"
  }
}
