resource "random_string" "suffix" { length = 5 upper = false special = false numeric = true }
resource "azurerm_private_dns_zone" "mysql" {
  name = "mysql.database.azure.com"
  resource_group_name = var.resource_group_name
  tags = var.tags
}
resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name = "mysql-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  resource_group_name = var.resource_group_name
  virtual_network_id = var.vnet_id
}
resource "azurerm_mysql_flexible_server" "this" {
  name = "${var.server_name_prefix}-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location = var.location
  administrator_login = var.admin_login
  administrator_password = var.admin_password
  version = "8.0.21"
  sku_name = "B_Standard_B1ms"
  backup_retention_days = 7
  delegated_subnet_id = var.mysql_subnet_id
  private_dns_zone_id = azurerm_private_dns_zone.mysql.id
  public_network_access = false
  storage { size_gb = 20 auto_grow_enabled = true }
  depends_on = [azurerm_private_dns_zone_virtual_network_link.mysql]
  tags = var.tags
}
resource "azurerm_mysql_flexible_database" "dev" {
  name = "ecommerce_dev"
  resource_group_name = var.resource_group_name
  server_name = azurerm_mysql_flexible_server.this.name
  charset = "utf8mb4"
  collation = "utf8mb4_unicode_ci"
}
resource "azurerm_mysql_flexible_database" "prod" {
  name = "ecommerce_prod"
  resource_group_name = var.resource_group_name
  server_name = azurerm_mysql_flexible_server.this.name
  charset = "utf8mb4"
  collation = "utf8mb4_unicode_ci"
}
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "server_name_prefix" { type = string default = "mysql-ecommerce" }
variable "admin_login" { type = string default = "ecomadmin" }
variable "admin_password" { type = string sensitive = true }
variable "mysql_subnet_id" { type = string }
variable "vnet_id" { type = string }
variable "tags" { type = map(string) default = {} }
output "server_name" { value = azurerm_mysql_flexible_server.this.name }
output "fqdn" { value = azurerm_mysql_flexible_server.this.fqdn }
output "dev_database" { value = azurerm_mysql_flexible_database.dev.name }
output "prod_database" { value = azurerm_mysql_flexible_database.prod.name }
