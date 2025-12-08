variable "rgname" {
  description = "The name of the resource group"
  type        = string
  default     = "Korea Central"
}
variable "loca" {
  description = "The location/region where the resources will be created"
  type        = string
}
variable "db_location" {
  description = "The location for MySQL servers"
  type        = string
  default     = "Korea Central"
}
variable "replica_loca" {
  description = "The location for MySQL read replicas"
  type        = string
  default     = "Korea Central"
}
variable "db_subnet_id" {
  description = "The ID of the subnet where the database will be connected"
  type        = string
}
variable "vnet_id" {
  description = "The ID of the virtual network for Private DNS Zone linking"
  type        = string
}
variable "db_password" {
  description = "The password for the MySQL administrator"
  type        = string
  sensitive   = true
}
variable "db_name" {
  description = "The name of the database to create"
  type        = string
  default     = "www_sql"
}
variable "redis_name" {
  description = "The name of the Redis Cache"
  type        = string
  default     = "www-redis-cache"
}
variable "redis_sku" {
  description = "The SKU of Redis to use"
  type        = string
  default     = "Premium"
}
variable "redis_family" {
  description = "The SKU family/pricing group to use"
  type        = string
  default     = "P"
}
variable "redis_capacity" {
  description = "The size of the Redis cache to deploy"
  type        = number
  default     = 1
}
variable "adf_name" {
  description = "The name of the Data Factory"
  type        = string
  default     = "www-data-factory"
}
variable "db_user" {
  description = "The MySQL database user"
  type        = string
  default     = "www"
}
variable "storage_connection_string" {
  description = "The connection string for the storage account"
  type        = string
  sensitive   = true
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace"
  type        = string
}
