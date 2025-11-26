variable "rgname" {
  description = "리소스 그룹 이름"
  type        = string
}

variable "loca" {
  description = "리소스가 생성될 리전"
  type        = string
}

variable "sa_name" {
  description = "스토리지 계정 이름 (전역적으로 고유해야 하며, 소문자 및 숫자만 가능)"
  type        = string
  default     = "wwwstorage04t1"
}

variable "cdn_profile_name" {
  description = "CDN 프로필 이름"
  type        = string
  default     = "www-cdn-profile"
}

variable "storage_subnet_id" {
  description = "스토리지 Private Endpoint용 서브넷 ID"
  type        = string
}

variable "vnet_id" {
  description = "Private DNS Zone 연결을 위한 가상 네트워크 ID"
  type        = string
}
