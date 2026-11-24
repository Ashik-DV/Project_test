variable "name_prefix" {
  type    = string
  default = "ecomlab"
}
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
