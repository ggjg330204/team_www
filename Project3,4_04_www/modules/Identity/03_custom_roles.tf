resource "azurerm_role_definition" "operator_role" {
  name        = "Critical Infrastructure Operator"
  scope       = var.rgid
  description = "Can restart and read VMs but cannot delete them. Designed for L1 Operations team."

  permissions {
    actions = [
      "Microsoft.Compute/virtualMachines/restart/action",
      "Microsoft.Compute/virtualMachines/start/action",
      "Microsoft.Compute/virtualMachines/read",
      "Microsoft.Network/networkInterfaces/read",
      "Microsoft.Network/publicIPAddresses/read",
      "Microsoft.Resources/subscriptions/resourceGroups/read"
    ]
    not_actions = [
      "Microsoft.Compute/virtualMachines/delete",
      "Microsoft.Compute/virtualMachines/write"
    ]
  }

  assignable_scopes = [
    var.rgid
  ]
}
