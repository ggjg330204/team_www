variable "subid" {
  type      = string
  default   = "99b79efe-ebd6-468c-b39f-5669acb259e1"
  sensitive = true
}

variable "rgname" {
  type    = string
}

variable "loca" {
  type    = string
  default = "KoreaCentral"
}



### vnet 가상 네트워크

variable "vnet" {
  type = string
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



### 팀 유저

variable "teamuser" {
  type = string
  default = "www"
}



### subnet id 서브넷 id

variable "subnet_bas.id" {
  type = string
  default = "azurerm_subnet.www_bas.id"
}

variable "subnet_web1.id" {
  type = string
  default = "azurerm_subnet.www_web1.id"
}

variable "subnet_web2.id" {
  type = string
  default = "azurerm_subnet.www_web2.id"
}

variable "subnet_db.id" {
  type = string
  default = "azurerm_subnet.www_db.id"
}

variable "v1_subnet_web1.id" {
  type = string
  default = "azurerm_subnet.www_web1_v1.id"
}

variable "v1_subnet_web2.id" {
  type = string
  default = "azurerm_subnet.www_web2_v1.id"
}

variable "v1_subnet_vmss.id" {
  type = string
  default = "azurerm_subnet.www_vmss.id"
}