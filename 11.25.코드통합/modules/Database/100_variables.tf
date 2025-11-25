variable "rgname" {
  description = "리소스 그룹 이름"
  type        = string
}

variable "loca" {
  description = "리소스가 생성될 리전"
  type        = string
}

variable "replica_loca" {
  description = "읽기 전용 복제본(Read Replica)이 위치할 리전"
  type        = string
  default     = "Korea South"
}

variable "db_subnet_id" {
  description = "데이터베이스가 연결될 서브넷 ID"
  type        = string
}

variable "vnet_id" {
  description = "Private DNS Zone 연결을 위한 메인 VNet ID"
  type        = string
}

variable "vnet_south_id" {
  description = "Private DNS Zone 연결을 위한 South VNet ID"
  type        = string
}

variable "db_password" {
  description = "MySQL 관리자 계정 비밀번호"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "생성할 데이터베이스 이름"
  type        = string
  default     = "www_sql"
}

variable "redis_name" {
  description = "Redis Cache 이름"
  type        = string
  default     = "www-redis-cache"
}

variable "redis_sku" {
  description = "사용할 Redis SKU"
  type        = string
  default     = "Basic"
}

variable "redis_family" {
  description = "사용할 Redis SKU 제품군(Family)"
  type        = string
  default     = "C"
}

variable "redis_capacity" {
  description = "배포할 Redis Cache 용량 크기"
  type        = number
  default     = 0
}

variable "adf_name" {
  description = "Data Factory 이름"
  type        = string
  default     = "www-data-factory"
}

variable "db_user" {
  description = "MySQL 데이터베이스 사용자명"
  type        = string
  default     = "www"
}

variable "storage_connection_string" {
  description = "스토리지 계정 연결 문자열"
  type        = string
  sensitive   = true
}
