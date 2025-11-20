variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location/region where the resources will be created"
  type        = string
}

variable "data_factory_name" {
  description = "The name of the Data Factory"
  type        = string
  default     = "www-data-factory"
}

/*
### 학습 포인트 (Analytics Variables)
- **data_factory_name**: 데이터 공장의 간판 이름입니다.
*/
