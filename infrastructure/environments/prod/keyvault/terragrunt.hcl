include "root" { path = find_in_parent_folders("terragrunt.hcl") }
locals { common = read_terragrunt_config(find_in_parent_folders("_common.hcl")) }
dependency "rg" { config_path = "../resource-group" }
terraform { source = "../../../modules/keyvault" }
inputs = {
  name_prefix = "ecomprod"
  resource_group_name = dependency.rg.outputs.name
  location = local.common.locals.location
  tags = merge(local.common.locals.tags, { environment = "prod" })
}
