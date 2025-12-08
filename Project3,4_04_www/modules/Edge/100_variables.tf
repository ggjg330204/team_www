variable "rgname" {
  description = "The name of the resource group"
  type        = string
}
variable "loca" {
  description = "The location/region where the resources will be created"
  type        = string
}
variable "cdn_profile_name" {
  description = "The name of the CDN Profile"
  type        = string
  default     = "www-cdn-profile"
}
variable "lb_public_ip" {
  description = "The public IP address of the load balancer"
  type        = string
  default     = ""
}
variable "appgw_public_ip" {
  description = "The public IP address of the Application Gateway"
  type        = string
  default     = ""
}

variable "keyvault_certificate_secret_id" {
  description = "Key Vault certificate secret ID for BYOC"
  type        = string
  default     = ""
}

variable "key_vault_id" {
  description = "The ID of the Key Vault"
  type        = string
}
variable "domain_name" {
  type = string
}
