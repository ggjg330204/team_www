variable "rgname" {
  type = string
}
variable "loca" {
  type = string
}
variable "hub_address_space" {
  type = string
}
variable "enable_vpn" {
  type    = bool
  default = false
}
variable "ddos_protection_plan_id" {
  description = "DDoS Protection Plan ID"
  type        = string
  default     = ""
}
