variable "rgname" {
  type = string
}

variable "loca" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "address_space" {
  type = list(string)
}

variable "subnets" {
  type        = map(string)
  description = "Map of subnet names to address prefixes"
}


variable "enable_bastion" {
  type    = bool
  default = false
}
