output "server_name" { value = azurerm_mysql_flexible_server.this.name }
output "fqdn" { value = azurerm_mysql_flexible_server.this.fqdn }
output "dev_database" { value = azurerm_mysql_flexible_database.dev.name }
output "prod_database" { value = azurerm_mysql_flexible_database.prod.name }
