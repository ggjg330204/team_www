variable "subid" {
  description = "Azure 구독 ID (사용되지 않음)"
  type        = string
  default     = "unused"
  sensitive   = true
}

variable "rgname" {
  description = "리소스 그룹 이름"
  type        = string
}

variable "loca" {
  description = "리소스가 생성될 리전"
  type        = string
}

variable "teamuser" {
  description = "리소스 명명에 사용될 팀 사용자명"
  type        = string
}

variable "bas_subnet_id" {
  description = "Bastion 서브넷 ID"
  type        = string
}

variable "web1_subnet_id" {
  description = "Web1 서브넷 ID"
  type        = string
}

variable "web2_subnet_id" {
  description = "Web2 서브넷 ID"
  type        = string
}

variable "db_subnet_id" {
  description = "데이터베이스 서브넷 ID"
  type        = string
}

variable "web1_v1_subnet_id" {
  description = "Web1 V1 (South) 서브넷 ID"
  type        = string
}

variable "vmss_subnet_id" {
  description = "VMSS 서브넷 ID"
  type        = string
}

variable "www_nsg_ssh" {
  description = "SSH 접속용 NSG 이름"
  type        = string
  default     = "www_nsg_ssh"
}

variable "www_nsg_http" {
  description = "HTTP 접속용 NSG 이름"
  type        = string
  default     = "www_nsg_http"
}

variable "www_nsg_db" {
  description = "DB 접속용 NSG 이름"
  type        = string
  default     = "www_nsg_db"
}

variable "www_v1_nsg_http" {
  description = "South 리전 HTTP 접속용 NSG 이름"
  type        = string
  default     = "www_v1_nsg_http"
}
