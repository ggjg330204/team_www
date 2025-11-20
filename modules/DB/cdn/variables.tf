variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location/region where the resources will be created"
  type        = string
}

variable "cdn_profile_name" {
  description = "The name of the CDN Profile"
  type        = string
  default     = "www-cdn-profile"
}

variable "origin_host_name" {
  description = "The host name of the origin (e.g. storage account blob endpoint)"
  type        = string
  # 예: wwwstorage.blob.core.windows.net
}

/*
### 학습 포인트 (CDN Variables)
- **cdn_profile_name**: CDN 설정 묶음의 이름입니다.
- **origin_host_name**: 원본 데이터가 있는 곳의 주소입니다. 보통 스토리지 주소를 적습니다.
*/
