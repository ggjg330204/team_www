#source\100_var.tf
variable "subid" { type = string }
variable "rgname" { type = string }
variable "loca" { type = string }
variable "loca1" { type = string }
variable "vnet-bas" { type = string }
variable "vnet-nat" { type = string }
variable "vnet-load" { type = string }
variable "vnet-web1" { type = string }
variable "vnet-web2" { type = string }
variable "vnet-db" { type = string }
variable "vnet-vmss" { type = string }
variable "teamuser" { type = string }
# variable "vnet" {
#   type = string
#   default = "www-vnet"
# }