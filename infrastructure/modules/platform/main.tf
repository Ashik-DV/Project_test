data "terraform_remote_state" "shared" {
  count   = var.create_shared ? 0 : 1
  backend = "azurerm"

  config = {
    resource_group_name  = var.tfstate_resource_group
    storage_account_name = var.tfstate_storage_account
    container_name       = var.tfstate_container
    key                  = var.shared_state_key
    use_azuread_auth     = true
  }
}

module "shared_resource_group" {
  count  = var.create_shared ? 1 : 0
  source = "../resource-group"

  name     = "rg-ecommerce-shared"
  location = var.location
  tags     = merge(var.tags, { environment = "shared" })
}

module "networking" {
  count  = var.create_shared ? 1 : 0
  source = "../networking"

  resource_group_name = module.shared_resource_group[0].name
  location            = var.location
  vnet_name           = "vnet-ecommerce-shared"
  tags                = merge(var.tags, { environment = "shared" })
}

module "acr" {
  count  = var.create_shared ? 1 : 0
  source = "../acr"

  resource_group_name = module.shared_resource_group[0].name
  location            = var.location
  name_prefix         = "ecomlab"
  tags                = merge(var.tags, { environment = "shared" })
}

module "mysql" {
  count  = var.create_shared ? 1 : 0
  source = "../mysql"

  resource_group_name = module.shared_resource_group[0].name
  location            = var.location
  mysql_subnet_id     = module.networking[0].mysql_subnet_id
  vnet_id             = module.networking[0].vnet_id
  admin_password      = var.mysql_admin_password
  tags                = merge(var.tags, { environment = "shared" })
}

locals {
  shared_network = var.create_shared ? {
    dev_subnet_id  = module.networking[0].aks_dev_subnet_id
    prod_subnet_id = module.networking[0].aks_prod_subnet_id
  } : data.terraform_remote_state.shared[0].outputs.network

  shared_acr_id = var.create_shared ? (
    module.acr[0].id
  ) : data.terraform_remote_state.shared[0].outputs.acr_id
}

module "environment_resource_group" {
  source = "../resource-group"

  name     = var.resource_group_name
  location = var.location
  tags     = merge(var.tags, { environment = var.environment })
}

module "aks" {
  source = "../aks"

  aks_name           = var.aks_name
  dns_prefix         = var.dns_prefix
  location           = var.location
  resource_group_name = module.environment_resource_group.name
  subnet_id          = var.environment == "dev" ? local.shared_network.dev_subnet_id : local.shared_network.prod_subnet_id
  acr_id             = local.shared_acr_id
  node_count         = var.node_count
  node_vm_size       = var.node_vm_size
  tags               = merge(var.tags, { environment = var.environment })
}

module "keyvault" {
  source = "../keyvault"

  name_prefix         = var.environment == "dev" ? "kv-ecom-dev" : "kv-ecom-prod"
  resource_group_name = module.environment_resource_group.name
  location            = var.location
  tags                = merge(var.tags, { environment = var.environment })
}

module "addons" {
  source = "../addons"

  host                   = module.aks.host
  client_certificate     = module.aks.client_certificate
  client_key             = module.aks.client_key
  cluster_ca_certificate = module.aks.cluster_ca_certificate
}
