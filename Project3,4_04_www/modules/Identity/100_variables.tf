variable "rgid" {
  description = "Resource Group ID for RBAC scope"
  type        = string
}

variable "rgname" {
  type = string
}

variable "loca" {
  type = string
}

variable "azure_ad_tenant_domain" {
  type        = string
  description = "Azure AD tenant domain"
}

variable "rbac_users" {
  type = map(object({
    account_name = string
    role         = string
    azure_role   = string
  }))
  description = "RBAC users list"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace ID for Log Analytics Reader scope"
}
