#source\99_out.tf
output "bas_pub_ip" {
    value = azurerm_public_ip.www_basip.ip_address
}
output "nat_pub_ip" {
    value = azurerm_public_ip.www_natip.ip_address
}

output "app_pub_ip" {
    value = azurerm_public_ip.www_appip.ip_address
}
output "nat_v1_pub_ip" {
    value = azurerm_public_ip.www_natip_v1.ip_address
}