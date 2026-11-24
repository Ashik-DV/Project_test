resource "azurerm_kubernetes_cluster" "this" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  sku_tier            = "Free"
  private_cluster_enabled           = false
  role_based_access_control_enabled = true
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true
  identity { type = "SystemAssigned" }
  default_node_pool {
    name            = "system"
    node_count      = var.node_count
    vm_size         = var.node_vm_size
    vnet_subnet_id  = var.subnet_id
    os_disk_size_gb = 30
    type            = "VirtualMachineScaleSets"
  }
  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    pod_cidr            = "10.244.0.0/16"
    service_cidr        = "10.0.0.0/16"
    dns_service_ip      = "10.0.0.10"
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"
  }
  tags = var.tags
}
resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}
variable "aks_name" { type = string }
variable "dns_prefix" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "subnet_id" { type = string }
variable "acr_id" { type = string }
variable "node_count" { type = number default = 1 }
variable "node_vm_size" { type = string default = "Standard_D2s_v3" }
variable "tags" { type = map(string) default = {} }
output "name" { value = azurerm_kubernetes_cluster.this.name }
output "id" { value = azurerm_kubernetes_cluster.this.id }
output "host" { value = azurerm_kubernetes_cluster.this.kube_config[0].host sensitive = true }
output "client_certificate" { value = azurerm_kubernetes_cluster.this.kube_config[0].client_certificate sensitive = true }
output "client_key" { value = azurerm_kubernetes_cluster.this.kube_config[0].client_key sensitive = true }
output "cluster_ca_certificate" { value = azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate sensitive = true }
