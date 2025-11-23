#source\100_var.tf
variable "subid" { 
    type = string 
    default = "99b79efe-ebd6-468c-b39f-5669acb259e1"
}

variable "rgname" { 
    type = string
    default = "04-hj" 
}

variable "loca" { 
    type = string 
    default = "KoreaCentral"
}



variable "teamuser" { 
    type = string
    default = "www" 
}

# variable "vnet" {
#   type = string
#   default = "www-vnet"
# }

/*
variable "vnet-bas" { 
    type = string 
}

variable "vnet-nat" { 
    type = string 
}

variable "vnet-load" { 
    type = string 
}

variable "vnet-web1" { 
    type = string 
}

variable "vnet-web2" { 
    type = string 
}

variable "vnet-db" { 
    type = string 
}

variable "vnet-vmss" { 
    type = string 
} 
*/