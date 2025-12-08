variable "rgname" {
  type = string
}
variable "loca" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "allowed_ip_ranges" {
  type        = list(string)
  description = "List of allowed IPs for Container Registry"
}
