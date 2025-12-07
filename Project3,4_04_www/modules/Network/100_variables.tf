variable "rgname" {
  type = string
}
variable "loca" {
  type = string
}
variable "vnet_name" {
  type = string
}
variable "address_space" {
  type = list(string)
}
variable "subnets" {
  type        = map(string)
  description = "Map of subnet names to address prefixes"
}
variable "enable_appgw" {
  type        = bool
  default     = false
  description = "Enable Application Gateway with WAF"
}
variable "vmss_backend_pool_id" {
  type        = string
  default     = null
  description = "Backend pool ID for Application Gateway (optional)"
}
variable "enable_nat" {
  type        = bool
  default     = false
  description = "Enable NAT Gateway for outbound connectivity"
}
variable "enable_vpn" {
  type    = bool
  default = false
}
variable "enable_cross_lb" {
  type    = bool
  default = false
}
variable "hub_vnet_id" {
  type        = string
  description = "ID of the Hub VNet for peering"
}
variable "enable_ddos" {
  type    = bool
  default = false
}
variable "enable_ssl" {
  type    = bool
  default = false
}

variable "keyvault_name" {
  type        = string
  description = "The name of the Azure Key Vault to retrieve certificates from."
}
variable "keyvault_id" {
  type    = string
  default = ""
}
variable "appgw_identity_id" {
  type    = string
  default = ""
}
variable "appgw_identity_principal_id" {
  type    = string
  default = ""
}
variable "ddos_protection_plan_id" {
  description = "DDoS Protection Plan ID for VNet"
  type        = string
  default     = ""
}
variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostic settings"
  type        = string
  default     = ""
}

variable "frontdoor_endpoint_hostname" {
  description = "Front Door endpoint hostname for CNAME record"
  type        = string
  default     = ""
}

variable "mysql_private_endpoint_ip" {
  description = "Private IP of MySQL Private Endpoint for DNS record"
  type        = string
  default     = ""
}
