variable "rgname" {
  description = "Resource Group Name"
  type        = string
}

variable "frontdoor_endpoint_hostname" {
  description = "Front Door Endpoint Hostname"
  type        = string
}

variable "frontdoor_endpoint_id" {
  description = "Front Door Endpoint Resource ID"
  type        = string
}

variable "www_domain_validation_token" {
  description = "Validation token for www.04www.cloud"
  type        = string
}

variable "apex_domain_validation_token" {
  description = "Validation token for 04www.cloud"
  type        = string
}

variable "mail_server_ip" {
  description = "Public IP of Mail Server"
  type        = string
}

