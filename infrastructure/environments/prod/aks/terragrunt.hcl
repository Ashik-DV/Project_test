include "root" { path = find_in_parent_folders("terragrunt.hcl") }
locals {
  common = read_terragrunt_config(find_in_parent_folders("_common.hcl"))
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}
dependency "rg" { config_path = "../resource-group" }
dependency "network" { config_path = "../../shared/networking" }
dependency "acr" { config_path = "../../shared/acr" }
terraform { source = "../../../modules/aks" }
inputs = {
  aks_name = local.env.locals.aks_name
  dns_prefix = local.env.locals.dns_prefix
  resource_group_name = dependency.rg.outputs.name
  subnet_id = dependency.network.outputs.aks_prod_subnet_id
  acr_id = dependency.acr.outputs.id
  node_count = local.env.locals.node_count
  node_vm_size = local.env.locals.node_vm_size
  location = local.common.locals.location
  tags = merge(local.common.locals.tags, { environment = "prod" })
}
