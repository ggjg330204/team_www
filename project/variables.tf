variable "rg_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location/region where the resources will be created"
  type        = string
}

variable "db_password" {
  description = "The password for the MySQL administrator"
  type        = string
  sensitive   = true
}

variable "teamuser" {
  description = "Team username used for naming resources"
  type        = string
  default     = "www"
}
