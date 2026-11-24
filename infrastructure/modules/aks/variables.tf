variable "aks_name" { type = string }
variable "dns_prefix" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "subnet_id" { type = string }
variable "acr_id" { type = string }
variable "node_count" {
  type    = number
  default = 1
}
variable "node_vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}
variable "tags" {
  type    = map(string)
  default = {}
}
