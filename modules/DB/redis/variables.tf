variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location/region where the resources will be created"
  type        = string
}

variable "redis_name" {
  description = "The name of the Redis Cache"
  type        = string
  default     = "www-redis-cache"
}

variable "sku_name" {
  description = "The SKU of Redis to use. Possible values are Basic, Standard and Premium."
  type        = string
  default     = "Basic"
}

variable "family" {
  description = "The SKU family/pricing group to use. Possible values are C (for Basic/Standard) and P (for Premium)."
  type        = string
  default     = "C"
}

variable "capacity" {
  description = "The size of the Redis cache to deploy. Valid values for a SKU family of C (Basic/Standard) are 0, 1, 2, 3, 4, 5, 6."
  type        = number
  default     = 0 # 가장 저렴한 옵션 (250MB)
}

/*
### 학습 포인트 (Redis Variables)
- **SKU (Stock Keeping Unit)**: 상품의 등급입니다. Basic은 개발용, Standard는 운영용(SLA 있음), Premium은 고성능용입니다.
- **Capacity**: 크기입니다. C0(250MB)부터 시작해서 C6(53GB)까지 있습니다.
*/
