variable "location" {
  description = "Azure region where lab resources are created."
  type        = string
  default     = "malaysiawest"
}

variable "resource_group_name" {
  description = "Name of the resource group for the lab."
  type        = string
  default     = "rg-ecommerce-observability"
}

variable "cluster_name" {
  description = "AKS cluster name."
  type        = string
  default     = "aks-ecommerce-observability"
}

variable "dns_prefix" {
  description = "DNS prefix used by the AKS API server."
  type        = string
  default     = "ecommerce-observability"
}

variable "kubernetes_version" {
  description = "Optional Kubernetes version. Leave empty to use Azure's current default."
  type        = string
  default     = ""
}

variable "node_count" {
  description = "Number of AKS nodes for this lab."
  type        = number
  default     = 1
  validation {
    condition     = var.node_count >= 1 && var.node_count <= 3
    error_message = "For this lab, node_count must be between 1 and 3."
  }
}

variable "node_vm_size" {
  description = "AKS node VM SKU. Confirm regional availability and quota before applying."
  type        = string
  default     = "Standard_D2as_v5"
}

variable "vnet_cidr" {
  description = "Address space for the virtual network."
  type        = string
  default     = "10.20.0.0/16"
}

variable "aks_subnet_cidr" {
  description = "Address prefix for the AKS subnet."
  type        = string
  default     = "10.20.1.0/24"
}

variable "tags" {
  description = "Tags applied to all created resources."
  type        = map(string)
  default = {
    workload   = "ecommerce"
    purpose    = "dynatrace-observability-lab"
    managed_by = "terraform"
  }
}
