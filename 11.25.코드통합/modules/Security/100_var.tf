variable "subid" {
  type      = string
  default   = "unused"
  sensitive = true
}

variable "rgname" {
  type = string
}

variable "loca" {
  type = string
}

variable "vnet" {
  type = string
}

variable "teamuser" {
  type = string
}

variable "www_nsg_ssh" {
  type    = string
  default = "www_nsg_ssh"
}

variable "www_nsg_http" {
  type    = string
  default = "www_nsg_http"
}

variable "www_nsg_db" {
  type    = string
  default = "www_nsg_db"
}

variable "www_v1_nsg_http" {
  type    = string
  default = "www_v1_nsg_http"
}
