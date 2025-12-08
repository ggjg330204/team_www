resource "azurerm_public_ip" "vpn_pip" {
  count               = var.enable_vpn ? 1 : 0
  name                = "hub-vpn-pip"
  location            = var.loca
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2"]
  tags = {
    Environment = "Production"
    Purpose     = "VPN-Gateway-PIP"
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_virtual_network_gateway" "hub_vpn" {
  count               = var.enable_vpn ? 1 : 0
  name                = "hub-vpn-gateway"
  location            = var.loca
  resource_group_name = var.rgname
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw2AZ"
  active_active       = true
  enable_bgp          = false
  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_pip[0].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway_subnet.id
  }
  ip_configuration {
    name                          = "vnetGatewayConfig2"
    public_ip_address_id          = azurerm_public_ip.vpn_pip_2[0].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway_subnet.id
  }
  vpn_client_configuration {
    address_space = ["172.20.0.0/24"]
    root_certificate {
      name             = "VPN-Root-Cert"
      public_cert_data = fileexists("${path.module}/../../certs/vpn-root-cert-base64.txt") ? file("${path.module}/../../certs/vpn-root-cert-base64.txt") : ""
    }
  }
  tags = {
    Environment = "Production"
    Purpose     = "Hub-VPN-Gateway"
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_public_ip" "vpn_pip_2" {
  count               = var.enable_vpn ? 1 : 0
  name                = "hub-vpn-pip-2"
  location            = var.loca
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2"]
  tags = {
    Environment = "Production"
    Purpose     = "VPN-Gateway-PIP-2"
    ManagedBy   = "Terraform"
  }
}
