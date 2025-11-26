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

variable "www_v1_nsg_http" {
  type = string
  default = "www_v1_nsg_http" 
}



### 팀 유저

variable "teamuser" {
  type = string
  default = "www"
}



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
variable "subnet_www_app_nic" {
  type = string
}
variable "subnet_www_web1_v1_nic" {
  type = string
}
variable "subnet_www_web2_v1_nic" {
  type = string
}

# subnet
variable "azurerm_subnet_www_bas" {
  type = string
}
variable "azurerm_subnet_www_nat" {
  type = string
}
variable "azurerm_subnet_www_web1" {
  type = string
}
variable "azurerm_subnet_www_web2" {
  type = string
}
variable "azurerm_subnet_www_db" {
  type = string
}
variable "azurerm_subnet_www_app" {
  type = string
}
variable "azurerm_subnet_www_nat_v1" {
  type = string
}
variable "azurerm_subnet_www_load" {
  type = string
}
variable "azurerm_subnet_www_web1_v1" {
  type = string
}
variable "azurerm_subnet_www_web2_v1" {
  type = string
}
variable "azurerm_subnet_www_vmss" {
  type = string
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