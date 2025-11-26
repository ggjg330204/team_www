# modules/Security/variables.tf

# 1. 기본 변수 (Root에서 받아옴)
variable "rg_name" { type = string }
variable "loca" { type = string }
variable "loca2" { type = string }

# 2. Network 모듈에서 받아올 Subnet ID들 (중요!)
variable "sub_bas_id" { type = string }
variable "sub_web1_id" { type = string }
variable "sub_web2_id" { type = string }
variable "sub_db_id" { type = string }
variable "sub_vmss_id" { type = string }

# ★ 오류 났던 부분: South Korea 리전의 Web1 서브넷 ID 변수 선언 추가
variable "sub_web1_v1_id" { type = string }

# 3. NSG 이름 변수들 (기존 코드 유지를 위해 기본값 설정)
# 이렇게 default를 넣어두면 루트(main.tf)에서 따로 안 넘겨줘도 에러가 안 납니다.
variable "www_nsg_ssh" {
  type    = string
  default = "www_nsg_ssh"
}

variable "www_nsg_http" {
  type    = string
  default = "www_nsg_http"
}

variable "www_nsg_db" {
  type    = string
  default = "www_nsg_db"
}

variable "www_v1_nsg_http" {
  type    = string
  default = "www_v1_nsg_http"
}
