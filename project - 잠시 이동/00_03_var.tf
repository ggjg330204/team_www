variable "subid" { type = string }
variable "rg_name" { type = string }
variable "loca" { type = string }
variable "loca2" { type = string }
variable "teamuser" { type = string }

variable "db_password" {
  type      = string
  sensitive = true
}

### vnet 가상 네트워크
variable "vnet" {
  type = string
  default = "jhj-vnet"
}

### nsg 네트워크 시큐리티 그룹
variable "www_nsg_ssh" {
  type = string
  default = "www_nsg_ssh"
}
variable "www_nsg_http" {
  type = string
  default = "www_nsg_http"
}
variable "www_nsg_db" {
  type = string
  default = "www_nsg_db" 
}
variable "www_v1_nsg_http" {
  type = string
  default = "www_v1_nsg_http" 
}

### subnet id 서브넷 id
# variable "subnet_bas.id" {
#   type = string
#   default = "azurerm_subnet.www_sub_bas.id"
# }
# variable "subnet_web1.id" {
#   type = string
#   default = "azurerm_subnet.www_sub_web1.id"
# }
# variable "subnet_web2.id" {
#   type = string
#   default = "azurerm_subnet.www_sub_web2.id"
# }
# variable "subnet_db.id" {
#   type = string
#   default = "azurerm_subnet.www_sub_db.id"
# }
# variable "v1_subnet_web1.id" {
#   type = string
#   default = "azurerm_subnet.www_v1_sub_web1.id"
# }
# variable "v1_subnet_web2.id" {
#   type = string
#   default = "azurerm_subnet.www_v1_sub_web2.id"
# }
# variable "v1_subnet_vmss.id" {
#   type = string
#   default = "azurerm_subnet.www_v1_sub_vmss.id"
# }