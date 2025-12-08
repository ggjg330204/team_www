variable "subscription_id" {
  type      = string
  sensitive = true
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
}
variable "ssh_allowed_ips" {
  type        = list(string)
  description = "List of allowed IPs for SSH access"
  default     = ["0.0.0.0/0"]
}
variable "admin_emails" {
  type        = list(string)
  description = "List of admin email addresses for alerts"
}

variable "domain_name" {
  type        = string
  description = "Domain name for the project (e.g. 04www.cloud)"
}
variable "enable_ssl" {
  type        = bool
  description = "Enable SSL for Application Gateway (false for first deployment)"
}

variable "admin_phone" {
  type        = string
  description = "Admin phone number"
  default     = "+821012345678"
}
