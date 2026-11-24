locals {
  environment  = "prod"
  aks_name     = "aks-ecommerce-prod"
  dns_prefix   = "ecom-prod"
  node_count   = 1
  node_vm_size = "Standard_D2s_v3"
}
