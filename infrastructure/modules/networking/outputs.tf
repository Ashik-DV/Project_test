output "vnet_id" { value = azurerm_virtual_network.this.id }
output "aks_dev_subnet_id" { value = azurerm_subnet.aks_dev.id }
output "aks_prod_subnet_id" { value = azurerm_subnet.aks_prod.id }
output "mysql_subnet_id" { value = azurerm_subnet.mysql.id }
