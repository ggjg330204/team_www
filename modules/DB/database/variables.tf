variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location/region where the resources will be created"
  type        = string
}

variable "replica_location" {
  description = "The location for the read replica"
  type        = string
  default     = "koreasouth"
}

variable "db_subnet_id" {
  description = "The ID of the subnet where the database will be connected"
  type        = string
}

variable "db_password" {
  description = "The password for the MySQL administrator"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "The name of the database to create"
  type        = string
  default     = "www_sql"
}

/*
### 학습 포인트 (Variables)
1. **variable**: 테라폼 모듈의 '입력 구멍'입니다. 함수로 치면 파라미터(매개변수)와 같습니다.
2. **type**: 변수의 자료형을 지정합니다. string(문자열), number(숫자), bool(참/거짓) 등이 있습니다.
3. **default**: 값을 입력하지 않았을 때 기본으로 사용할 값입니다. 이게 없으면 실행 시 반드시 값을 넣어야 합니다.
4. **sensitive = true**: 비밀번호 같은 민감한 정보가 터미널 로그에 그대로 찍히지 않게 가려주는 보안 설정입니다.
*/
