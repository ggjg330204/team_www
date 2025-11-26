# Compute 모듈 변수
variable "rgname" {
  description = "리소스 그룹 이름"
  type        = string
}

variable "loca" {
  description = "주 리전"
  type        = string
}

variable "loca_replica" {
  description = "보조 리전 (Korea South)"
  type        = string
}

variable "teamuser" {
  description = "리소스 명명에 사용될 팀 사용자명"
  type        = string
}

variable "subid" {
  description = "Azure 구독 ID"
  type        = string
}

variable "nic_id" {
  description = "네트워크 인터페이스(NIC) ID 맵"
  type        = map(string)
}

variable "vmss_subnet_id" {
  description = "VMSS용 서브넷 ID"
  type        = string
}
