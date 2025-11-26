variable "rg_name" {
  type        = string
  description = "리소스 그룹 이름 (루트에서 받아옴)"
}

variable "loca" {
  type        = string
  description = "주 리전 (Korea Central)"
}

variable "loca2" {
  type        = string
  description = "부 리전 (Korea South)"
}

variable "teamuser" {
  type        = string
  description = "팀 사용자명 (리소스 이름 접두사)"
}
