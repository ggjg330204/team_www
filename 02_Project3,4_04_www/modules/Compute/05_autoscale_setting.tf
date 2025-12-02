resource "azurerm_monitor_autoscale_setting" "vmss_autoscale" {
  name                = "vmss-autoscale"
  resource_group_name = var.rgname
  location            = var.loca
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.vmss.id
  profile {
    name = "defaultProfile"
    capacity {
      default = 2
      minimum = 2
      maximum = 10
    }
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT10M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT10M"
      }
    }
  }
  tags = {
    Environment = "Production"
    Purpose     = "Autoscale"
    ManagedBy   = "Terraform"
  }
}
