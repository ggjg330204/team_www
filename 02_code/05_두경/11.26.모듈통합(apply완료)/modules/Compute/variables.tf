variable "rg_name" {}
variable "loca" {}
variable "loca2" {}
variable "teamuser" {}
# Network 모듈에서 받아올 값들
variable "sub_bas_id" {}
variable "sub_web1_id" {}
variable "sub_web2_id" {}
variable "sub_db_id" {}
variable "sub_vmss_id" {}
variable "pub_bas_id" {}       # Bastion Public IP 연결용
variable "appgw_be_pool_id" {} # VMSS 연결용
variable "nic_bas_id" { type = string }
variable "nic_web1_id" { type = string }
variable "nic_web2_id" { type = string }
variable "nic_db_id" { type = string }
variable "nic_web1_v1_id" { type = string }
