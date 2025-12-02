variable "rg_name" {
  description = "리소스 그룹의 이름"
  type        = string
}

variable "location" {
  description = "리소스가 생성될 Azure 리전 (예: Korea Central)"
  type        = string
}

variable "db_password" {
  description = "MySQL 관리자 계정 비밀번호"
  type        = string
  sensitive   = true
}

variable "teamuser" {
  description = "리소스 명명에 사용될 팀 사용자명 (예: www)"
  type        = string
  default     = "www"
}
variable "subid" {
  description = "Azure 구독 ID"
  type        = string
  default     = "99b79efe-ebd6-468c-b39f-5669acb259e1"
}
