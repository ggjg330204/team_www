# Network 모듈 변수
variable "subid" {
  description = "Azure 구독 ID"
  type        = string
}

variable "rgname" {
  description = "리소스 그룹 이름"
  type        = string
}

variable "loca" {
  description = "주 리전 (Korea Central)"
  type        = string
}

variable "loca_replica" {
  description = "복제본 리소스가 위치할 보조 리전 (Korea South)"
  type        = string
  default     = "Korea South"
}

variable "teamuser" {
  description = "리소스 명명에 사용될 팀 사용자명"
  type        = string
}
