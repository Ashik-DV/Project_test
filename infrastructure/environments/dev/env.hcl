locals {
  environment  = "dev"
  aks_name     = "aks-ecommerce-dev"
  dns_prefix   = "ecom-dev"
  node_count   = 1
  node_vm_size = "Standard_D2s_v3"
}
