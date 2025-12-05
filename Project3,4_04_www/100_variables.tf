variable "subscription_id" {
  type      = string
  sensitive = true
  default   = "99b79efe-ebd6-468c-b39f-5669acb259e1"
}
variable "rgname" {
  type    = string
  default = "www-rg"
}
variable "loca" {
  type    = string
  default = "Korea Central"
}
variable "db_password" {
  type      = string
  sensitive = true
  default   = "It12345!"
}
variable "ssh_allowed_ips" {
  type        = list(string)
  description = "List of allowed IPs for SSH access"
  default     = ["61.108.60.26", "211.252.127.132"]
}
variable "enable_ssl" {
  type        = bool
  description = "Enable SSL for Application Gateway (false for first deployment)"
}