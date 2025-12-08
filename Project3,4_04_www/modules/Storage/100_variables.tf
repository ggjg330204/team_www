variable "rgname" {
  description = "The name of the resource group"
  type        = string
}
variable "loca" {
  description = "The location/region where the resources will be created"
  type        = string
}

variable "storage_subnet_id" {
  description = "The ID of the subnet for Storage Private Endpoint"
  type        = string
}

variable "vnet_id" {
  description = "The ID of the virtual network for Private DNS Zone linking"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace"
  type        = string
}

variable "allowed_ips" {
  description = "List of allowed IPs for Storage Account network rules"
  type        = list(string)
  default     = []
}
