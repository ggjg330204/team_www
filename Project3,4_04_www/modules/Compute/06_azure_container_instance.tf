resource "azurerm_container_group" "aci" {
  name                = "www-aci"
  location            = var.loca
  resource_group_name = var.rgname
  ip_address_type     = "Public"
  dns_name_label      = "www-aci-${random_string.aci_suffix.result}"
  os_type             = "Linux"
  container {
    name   = "www-container"
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld"
    cpu    = "0.5"
    memory = "1.5"
    ports {
      port     = 80
      protocol = "TCP"
    }
  }
  tags = {
    Environment = "Production"
    Purpose     = "Container-Instance"
    ManagedBy   = "Terraform"
  }
}
resource "random_string" "aci_suffix" {
  length  = 6
  special = false
  upper   = false
}
