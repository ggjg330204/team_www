variable "rgname" {
  description = "The name of the resource group"
  type        = string
}

variable "loca" {
  description = "The location/region where the resources will be created"
  type        = string
}

variable "replica_loca" {
  description = "The location for the read replica"
  type        = string
  default     = "Korea South"
}

variable "db_subnet_id" {
  description = "The ID of the subnet where the database will be connected"
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

# Redis variables
variable "redis_name" {
  description = "The name of the Redis Cache"
  type        = string
  default     = "www-redis-cache"
}

variable "redis_sku" {
  description = "The SKU of Redis to use"
  type        = string
  default     = "Basic"
}

variable "redis_family" {
  description = "The SKU family/pricing group to use"
  type        = string
  default     = "C"
}

variable "redis_capacity" {
  description = "The size of the Redis cache to deploy"
  type        = number
  default     = 0
}

# Data Factory variables
variable "adf_name" {
  description = "The name of the Data Factory"
  type        = string
  default     = "www-data-factory"
}
