variable "rgname" {
  type = string
}

variable "loca" {
  type = string
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID to associate the NSG with"
}

variable "wwwuser" {
  type    = string
  default = "hamap"
}

variable "vnet_name" {
  type = string
}
