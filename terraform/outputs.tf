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

output "mysql_server_name" {
  description = "MySQL Flexible Server name."
  value       = azurerm_mysql_flexible_server.this.name
}

output "mysql_database_name" {
  description = "Application MySQL database name."
  value       = azurerm_mysql_flexible_database.ecommerce.name
}

output "mysql_admin_username" {
  description = "MySQL administrator username."
  value       = var.mysql_admin_username
}

output "mysql_admin_password" {
  description = "Generated MySQL administrator password. Stored in Terraform state and marked sensitive."
  value       = random_password.mysql_admin.result
  sensitive   = true
}

output "mysql_connection_host" {
  description = "Private MySQL server hostname for the application."
  value       = azurerm_mysql_flexible_server.this.fqdn
}
