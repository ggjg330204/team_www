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

variable "teamuser" {
  type = string
}

variable "bas_subnet_id" {
  type = string
}

variable "web1_subnet_id" {
  type = string
}

variable "web2_subnet_id" {
  type = string
}

variable "db_subnet_id" {
  type = string
}

variable "web1_v1_subnet_id" {
  type = string
}

variable "vmss_subnet_id" {
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
