variable "subid" {
  type      = string
  default   = "99b79efe-ebd6-468c-b39f-5669acb259e1"
  sensitive = true
}

variable "rgname" {
  type    = string
  default = "04-jhj"
}

variable "loca" {
  type    = string
  default = "KoreaCentral"
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

variable "www_sth_nsg_http" {
  type = string
  default = "www_sth_nsg_http" 
}



### 팀 유저

variable "teamuser" {
  type = string
  default = "www"
}



### subnet 서브넷

variable "subnet_bas" {
  type = string
  default = "azurerm_subnet.www_sub_bas"
}

variable "subnet_web1" {
  type = string
  default = "azurerm_subnet.www_sub_web1"
}

variable "subnet_web2" {
  type = string
  default = "azurerm_subnet.www_sub_web2"
}

variable "subnet_db" {
  type = string
  default = "azurerm_subnet.www_sub_db"
}

variable "sth_subnet_web1" {
  type = string
  default = "azurerm_subnet.www_sth_sub_web1"
}

variable "sth_subnet_web2" {
  type = string
  default = "azurerm_subnet.www_sth_sub_web2"
}

variable "sth_subnet_vmss" {
  type = string
  default = "azurerm_subnet.www_sth_sub_vmss"
}