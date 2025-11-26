#source\100_var.tf
variable "subid" { type = string }
variable "rgname" { type = string }
variable "loca" { type = string }
variable "teamuser" { type = string }
# variable "vnet" {
#   type = string
#   default = "www-vnet"
# }
variable "nic_id" { type = string }

variable "subnet_www_bas_nic" {
  type = string
}
variable "subnet_www_web1_nic" {
  type = string
}
variable "subnet_www_web2_nic" {
  type = string
}
variable "subnet_www_db_nic" {
  type = string
}
# variable "subnet_www_app_nic" {
#   type = string
# }
variable "subnet_www_web1_v1_nic" {
  type = string
}
variable "subnet_www_web2_v1_nic" {
  type = string
}
variable "azurerm_subnet_www_vmss" {
  type = string
}
variable "gateway_www_appgw_backend_add_pool" {
  type = string
}