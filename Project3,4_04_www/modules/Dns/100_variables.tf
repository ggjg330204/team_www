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
  description = "Validation token for www subdomain"
  type        = string
}

variable "apex_domain_validation_token" {
  description = "Validation token for apex domain"
  type        = string
}

variable "mail_server_ip" {
  description = "Public IP of Mail Server"
  type        = string
}

variable "domain_name" {
  type        = string
  description = "Domain name for the project (e.g. example.com)"
}
