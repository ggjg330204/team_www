output "bas_pub_ip" {
  value = module.network.bas_pub_ip
}

output "mysql_fqdn" {
  value = module.database.mysql_server_fqdn
}
