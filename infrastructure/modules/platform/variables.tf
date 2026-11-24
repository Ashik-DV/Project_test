variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "resource_group_name" {
  type = string
}

variable "aks_name" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "node_count" {
  type    = number
  default = 1
}

variable "node_vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "mysql_admin_password" {
  type      = string
  sensitive = true
}

variable "tfstate_resource_group" {
  type = string
}

variable "tfstate_storage_account" {
  type = string
}

variable "tfstate_container" {
  type    = string
  default = "tfstate"
}

variable "shared_state_key" {
  type    = string
  default = "dev/terraform.tfstate"
}

variable "create_shared" {
  type = bool
}
