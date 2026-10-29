output "resource_group_name" {
  description = "Resource group containing the AKS lab."
  value       = azurerm_resource_group.this.name
}

output "aks_cluster_name" {
  description = "AKS cluster name."
  value       = azurerm_kubernetes_cluster.this.name
}

output "aks_cluster_id" {
  description = "AKS resource ID."
  value       = azurerm_kubernetes_cluster.this.id
}

output "aks_node_resource_group" {
  description = "Azure-managed node resource group."
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}

output "aks_kube_config_command" {
  description = "Command to configure kubectl after apply."
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.this.name} --name ${azurerm_kubernetes_cluster.this.name} --overwrite-existing"
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID."
  value       = azurerm_log_analytics_workspace.this.id
}
