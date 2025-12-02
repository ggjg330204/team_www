variable "rgname" {
  type = string
}
variable "loca" {
  type = string
}
variable "storage_account_id" {
  type = string
}
variable "storage_connection_string" {
  type      = string
  sensitive = true
}
