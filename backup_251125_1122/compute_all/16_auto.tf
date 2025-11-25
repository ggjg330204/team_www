#source\16_auto.tf
resource "azurerm_monitor_autoscale_setting" "www_vmss_auto" {
    name = "${var.teamuser}-vmss-auto"
    resource_group_name = azurerm_resource_group.www_rg.name
    location = var.loca
#scaling resource
target_resource_id = azurerm_linux_virtual_machine_scale_set.www_vmss.id
enabled = true

profile {
    name = "cpu-profile"
capacity {
    default = 2
    minimum = 1
    maximum = 6
}
rule {
    metric_trigger {
        metric_name = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.www_vmss.id
        time_grain = "PT1M"
        statistic = "Average"
        time_window = "PT5M"
        time_aggregation = "Average"
        operator = "GreaterThanOrEqul"
        threshold = 70
    }
    scale_action {
        direction = "Increase"
        type = "ChangeCount"
        value = "1"
        cooldown = "PT5M"
    }
}
rule {
    metric_trigger {
        metric_name = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.www_vmss.id
        time_grain = "PT1M"
        statistic = "Average"
        time_window = "PT5M"
        time_aggregation = "Average"
        operator = "LessThanOrEqul"
        threshold = 20
    }
    scale_action {
        direction = "Decrease"
        type = "ChangeCount"
        value = "1"
        cooldown = "PT5M"
    }
}
}
}