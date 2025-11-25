#source\99_out.tf
output "bas_pub_ip" {
    value = azurerm_public_ip.www_basip.ip_address
}