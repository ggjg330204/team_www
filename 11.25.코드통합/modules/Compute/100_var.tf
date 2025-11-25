variable "rgname" {
  type = string
}

variable "loca" {
  type = string
}

variable "teamuser" {
  type = string
}

variable "subid" {
  type = string
}

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

variable "nic_id" {
  type = map(string)
}

variable "vmss_subnet_id" {
  type = string
}

