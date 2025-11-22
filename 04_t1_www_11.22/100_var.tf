variable "subscription_id" {
  type      = string
  sensitive = true
  default   = "99b79efe-ebd6-468c-b39f-5669acb259e1"
}

variable "rgname" {
  type    = string
  default = "www-rg"
}

variable "loca" {
  type    = string
  default = "Korea Central"
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = "P@ssw0rd1234!" # 임시 기본값, 실제 운영 시 제거 권장
}
