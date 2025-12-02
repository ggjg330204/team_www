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
variable "webvm_id" {
  type        = string
  description = "Web VM Resource ID"
}
variable "ssh_allowed_ips" {
  type        = list(string)
  description = "List of allowed IPs for SSH access"
  default     = ["0.0.0.0/0"]
}
variable "allowed_subnet_ids" {
  description = "Key Vault 접근을 허용할 Subnet ID 목록"
  type        = list(string)
  default     = []
}
variable "admin_ip_rules" {
  description = "Key Vault 접근을 허용할 관리자 IP 목록"
  type        = list(string)
  default     = []
}
variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostic settings"
  type        = string
  default     = ""
}