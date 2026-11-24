include "root" { path = find_in_parent_folders("terragrunt.hcl") }
locals { common = read_terragrunt_config(find_in_parent_folders("_common.hcl")) }
dependency "rg" { config_path = "../resource-group" }
terraform { source = "../../../modules/acr" }
inputs = {
  resource_group_name = dependency.rg.outputs.name
  name_prefix = "ecomlab"
  location = local.common.locals.location
  tags = local.common.locals.tags
}
