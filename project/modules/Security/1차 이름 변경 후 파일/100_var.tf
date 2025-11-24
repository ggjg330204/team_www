#source\100_var.tf
variable "subid" { 
    type = string 
    default = "99b79efe-ebd6-468c-b39f-5669acb259e1"
}

variable "rgname" { 
    type = string
    default = "04-1team" 
}

variable "loca" { 
    type = string 
    default = "KoreaCentral"
}

### 서브넷 이름 변수
#bastion
variable "sub_bas" {
  type = string
  default = "www_sub_bas"
}

#web
variable "sub_web" {
  type = string
  default = "www_sub_web"
}

#db
variable "sub_db" {
  type = string
  default = "www_sub_db"
}


###네트워크 시큐리티 그룹 아이디


#####

variable "teamuser" { 
    type = string
    default = "www" 
}



#다른 팀원들의 var
variable "replica_loca" {
  description = "The location for the read replica"
  type        = string
  default     = "Korea South"
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

# Redis variables
variable "redis_name" {
  description = "The name of the Redis Cache"
  type        = string
  default     = "www-redis-cache"
}

variable "redis_sku" {
  description = "The SKU of Redis to use"
  type        = string
  default     = "Basic"
}

variable "redis_family" {
  description = "The SKU family/pricing group to use"
  type        = string
  default     = "C"
}

variable "redis_capacity" {
  description = "The size of the Redis cache to deploy"
  type        = number
  default     = 0
}

# Data Factory variables
variable "adf_name" {
  description = "The name of the Data Factory"
  type        = string
  default     = "www-data-factory"
}

# variable "vnet" {
#   type = string
#   default = "www-vnet"
# }

/*
variable "vnet-bas" { 
    type = string 
}

variable "vnet-nat" { 
    type = string 
}

variable "vnet-load" { 
    type = string 
}

variable "vnet-web1" { 
    type = string 
}

variable "vnet-web2" { 
    type = string 
}

variable "vnet-db" { 
    type = string 
}

variable "vnet-vmss" { 
    type = string 
} 
*/