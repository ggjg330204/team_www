variable "rgname" {
  type = string
}
variable "loca" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "allowed_ip_ranges" {
  type    = list(string)
  default = ["61.108.60.26/32"]
}
