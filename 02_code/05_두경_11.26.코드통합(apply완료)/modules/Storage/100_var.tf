variable "rgname" {
  description = "The name of the resource group"
  type        = string
}

variable "loca" {
  description = "The location/region where the resources will be created"
  type        = string
}

variable "sa_name" {
  description = "The name of the storage account (must be globally unique, lowercase alphanumeric)"
  type        = string
  default     = "wwwstorage04t1"
}

variable "cdn_profile_name" {
  description = "The name of the CDN Profile"
  type        = string
  default     = "www-cdn-profile"
}

variable "storage_subnet_id" {
  description = "The ID of the subnet for Storage Private Endpoint"
  type        = string
}

variable "vnet_id" {
  description = "The ID of the virtual network for Private DNS Zone linking"
  type        = string
}
