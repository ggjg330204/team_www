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
  default     = "wwwstorage04t1" # 전역적으로 고유하도록 팀 식별자 추가
}

variable "cdn_profile_name" {
  description = "The name of the CDN Profile"
  type        = string
  default     = "www-cdn-profile"
}
