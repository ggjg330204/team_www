variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location/region where the resources will be created"
  type        = string
}

variable "storage_account_name" {
  description = "The name of the storage account (must be globally unique, lowercase alphanumeric)"
  type        = string
  default     = "wwwstorage" 
}

/*
### 학습 포인트 (Variables)
- 스토리지 계정 이름은 특이하게도 **전 세계 유일(Globally Unique)**해야 합니다. 
- Azure의 모든 사용자를 통틀어서 겹치면 안 되기 때문에, 보통 팀 이름이나 날짜, 난수를 섞어서 짓습니다.
- 소문자와 숫자만 사용할 수 있습니다. (특수문자, 대문자 불가)
*/
