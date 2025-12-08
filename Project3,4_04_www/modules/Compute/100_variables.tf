variable "rgname" {
  description = "The name of the resource group"
  type        = string
}
variable "loca" {
  description = "The location/region where the resources will be created"
  type        = string
}
variable "vmss_subnet_id" {
  description = "The ID of the subnet where the VMSS will be connected"
  type        = string
}
variable "vm_subnet_id" {
  description = "The ID of the subnet where the VM will be connected"
  type        = string
}
variable "was_subnet_id" {
  description = "The ID of the subnet where the WAS VMSS will be connected"
  type        = string
}
variable "admin_username" {
  description = "The admin username for the VMSS"
  type        = string
}
variable "admin_password" {
  description = "The admin password for the VMSS"
  type        = string
  sensitive   = true
}
variable "lb_backend_pool_id" {
  description = "The ID of the Load Balancer Backend Pool"
  type        = string
}
variable "lb_probe_id" {
  description = "The ID of the Load Balancer Probe"
  type        = string
}
variable "ssh_nat_pool_id" {
  description = "The ID of the SSH NAT Pool"
  type        = string
}
variable "was_lb_backend_pool_id" {
  description = "The ID of the WAS Load Balancer Backend Pool"
  type        = string
}
variable "was_lb_private_ip" {
  description = "The Private IP of the WAS Load Balancer"
  type        = string
}
variable "bastion_nic_id" {
  description = "The ID of the Bastion NIC"
  type        = string
  default     = ""
}
variable "db_host" {
  description = "The Hostname of the Database"
  type        = string
}
variable "db_user" {
  description = "The Username of the Database"
  type        = string
}
variable "db_password" {
  description = "The Password of the Database"
  type        = string
  sensitive   = true
}
variable "db_name" {
  type        = string
  description = "Database name for WordPress"
  default     = "www_sql"
}
variable "redis_hostname" {
  description = "The Hostname of the Redis Instance"
  type        = string
}
variable "redis_port" {
  description = "The SSL Port of the Redis Instance"
  type        = number
  default     = 6380
}
variable "redis_primary_key" {
  description = "The Primary Access Key for the Redis Instance"
  type        = string
  sensitive   = true
}
variable "was_lb_probe_id" {
  description = "The ID of the WAS Load Balancer Health Probe"
  type        = string
}
variable "db_ro_host" {
  description = "The Hostname of the Read Replica Database"
  type        = string
}
variable "app_insights_key" {
  description = "The Instrumentation Key for Application Insights"
  type        = string
  sensitive   = true
}
variable "vmss_identity_id" {
  description = "The ID of the VMSS Managed Identity"
  type        = string
}
variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace"
  type        = string
}

variable "ssh_allowed_ips" {
  description = "List of allowed IPs for SSH access"
  type        = list(string)
}

variable "data_collection_rule_id" {
  description = "The ID of the Data Collection Rule for Azure Monitor Agent"
  type        = string
}

variable "domain_name" {
  type = string
}

variable "key_vault_id" {
  description = "The ID of the Key Vault"
  type        = string
}

variable "key_vault_name" {
  description = "The Name of the Key Vault"
  type        = string
}
