variable "rgname" {
  type = string
}

variable "loca" {
  type = string
}

variable "vm_subnet_id" {
  type = string
}

variable "vmss_subnet_id" {
  type = string
}

variable "admin_username" {
  type    = string
  default = "wwwuser"
}

variable "lb_backend_pool_id" {
  type = string
}
