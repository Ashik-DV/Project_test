resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-ecommerce-observability"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.vnet_cidr]
  tags                = var.tags
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.aks_subnet_cidr]
}

resource "azurerm_subnet" "mysql" {
  name                 = "snet-mysql"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.mysql_subnet_cidr]

  delegation {
    name = "mysql-flexible-server-delegation"

    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_private_dns_zone" "mysql" {
  name                = "private.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name                  = "mysql-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = azurerm_virtual_network.this.id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "law-ecommerce-observability"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "random_string" "mysql_suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "random_password" "mysql_admin" {
  length           = 24
  special          = true
  override_special = "!#$%&()*+,-.:;<=>?@[]^_{|}~"
}

resource "azurerm_mysql_flexible_server" "this" {
  name                   = "${var.mysql_server_name}-${random_string.mysql_suffix.result}"
  resource_group_name    = azurerm_resource_group.this.name
  location               = azurerm_resource_group.this.location
  administrator_login    = var.mysql_admin_username
  administrator_password = random_password.mysql_admin.result
  backup_retention_days  = 7
  delegated_subnet_id    = azurerm_subnet.mysql.id
  private_dns_zone_id    = azurerm_private_dns_zone.mysql.id
  sku_name               = var.mysql_sku_name
  storage_mb             = var.mysql_storage_size_gb * 1024
  version                = "8.0.21"

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.mysql,
  ]

  tags = var.tags
}

resource "azurerm_mysql_flexible_database" "ecommerce" {
  name                = var.mysql_database_name
  resource_group_name = azurerm_resource_group.this.name
  server_name         = azurerm_mysql_flexible_server.this.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version != "" ? var.kubernetes_version : null

  role_based_access_control_enabled = true
  local_account_disabled            = false
  sku_tier                          = "Free"

  default_node_pool {
    name                         = "system"
    node_count                   = var.node_count
    vm_size                      = var.node_vm_size
    vnet_subnet_id               = azurerm_subnet.aks.id
    os_disk_size_gb              = 64
    type                         = "VirtualMachineScaleSets"
    only_critical_addons_enabled = false
    temporary_name_for_rotation  = "sysrot"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "azure"
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"
    service_cidr        = "10.30.0.0/16"
    dns_service_ip      = "10.30.0.10"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  }

  tags = var.tags
}
