variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "server_name_prefix" {
  type    = string
  default = "mysql-ecommerce"
}
variable "admin_login" {
  type    = string
  default = "ecomadmin"
}
variable "admin_password" {
  type      = string
  sensitive = true
}
variable "mysql_subnet_id" { type = string }
variable "vnet_id" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
