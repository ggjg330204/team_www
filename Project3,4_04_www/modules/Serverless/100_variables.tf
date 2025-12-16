variable "rgname" {
  type = string
}
variable "loca" {
  type = string
}
variable "storage_account_id" {
  type = string
}
variable "storage_connection_string" {
  type      = string
  sensitive = true
}

variable "key_vault_id" {
  type        = string
  description = "Key Vault Resource ID for Logic App access"
}

variable "nsg_id" {
  type        = string
  description = "NSG ID for Logic App to add block rules"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace ID for Sentinel automation"
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID"
}
