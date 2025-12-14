variable "rgname" {
  type = string
}
variable "loca" {
  type = string
}
variable "subnet_id" {
  type        = string
  description = "Subnet ID to associate the NSG with"
}
variable "wwwuser" {
  type    = string
  default = "www"
}
variable "vnet_name" {
  type = string
}
variable "vmss_id" {
  type        = string
  description = "VMSS Resource ID"
}
variable "mysql_server_id" {
  type        = string
  description = "MySQL Server Resource ID"
}
variable "redis_id" {
  type        = string
  description = "Redis Cache Resource ID"
}
variable "lb_public_ip" {
  type        = string
  description = "Load Balancer Public IP"
}
variable "ssh_allowed_ips" {
  type        = list(string)
  description = "List of allowed IPs for SSH access"
  default     = ["0.0.0.0/0"]
}
variable "allowed_subnet_ids" {
  description = "Key Vault 접근 허용 Subnet ID 목록"
  type        = list(string)
  default     = []
}
variable "admin_ip_rules" {
  description = "Key Vault 접근 허용 관리자 IP 목록"
  type        = list(string)
  default     = []
}
variable "appgw_identity_principal_id" {
  description = "Principal ID of the Application Gateway's User Assigned Managed Identity"
  type        = string
  default     = ""
}
variable "enable_appgw" {
  description = "Boolean indicating if the Application Gateway is enabled"
  type        = bool
  default     = false
}
variable "db_password" {
  description = "Database password for Key Vault secret"
  type        = string
  sensitive   = true
}

variable "vmss_identity_principal_id" {
  description = "Principal ID of the VMSS User Assigned Managed Identity"
  type        = string
}
variable "admin_emails" {
  description = "List of admin email addresses for alerts"
  type        = list(string)
}
variable "admin_phone" {
  type        = string
  description = "Admin phone number for Security Center Contact"
}

variable "domain_name" {
  type        = string
  description = "Domain name for the project"
}

variable "sentinel_service_principal_id" {
  description = "The Object ID of the Azure Security Insights service principal"
  type        = string
}

variable "subscription_id" {
  description = "Azure Subscription ID for data connectors"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID for Defender connectors"
  type        = string
}

variable "enable_activity_logs" {
  description = "Enable Azure Activity logs Diagnostic Setting (set to false if already exists)"
  type        = bool
  default     = false
}

variable "bastion_subnet_prefix" {
  description = "CIDR prefix for the Bastion subnet"
  type        = string
}

variable "was_subnet_prefix" {
  description = "CIDR prefix for the WAS subnet"
  type        = string
}
