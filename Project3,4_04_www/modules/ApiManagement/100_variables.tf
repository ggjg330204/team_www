variable "rgname" {
  type = string
}
variable "loca" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "lb_private_ip" {
  type = string
}

variable "publisher_email" {
  type        = string
  description = "Publisher email for API Management"
}
