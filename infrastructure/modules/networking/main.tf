resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.20.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "aks_dev" {
  name                 = "snet-aks-dev"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.20.1.0/24"]
}

resource "azurerm_subnet" "aks_prod" {
  name                 = "snet-aks-prod"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.20.2.0/24"]
}

resource "azurerm_subnet" "mysql" {
  name                 = "snet-mysql"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.20.3.0/28"]
  delegation {
    name = "mysql-flexible-server-delegation"
    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}
