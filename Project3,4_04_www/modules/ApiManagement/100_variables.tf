variable "rgname" {
  type = string
}
variable "loca" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "appgw_public_ip" {
  type        = string
  description = "Application Gateway Public IP for API backend"
}

variable "publisher_email" {
  type        = string
  description = "Publisher email for API Management"
}
