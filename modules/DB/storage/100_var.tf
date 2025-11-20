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
  default     = "wwwstorage"
}

variable "cdn_profile_name" {
  description = "The name of the CDN Profile"
  type        = string
  default     = "www-cdn-profile"
}
