include "root" { path = find_in_parent_folders("terragrunt.hcl") }
locals { common = read_terragrunt_config(find_in_parent_folders("_common.hcl")) }
dependency "rg" { config_path = "../resource-group" }
dependency "network" { config_path = "../networking" }
terraform { source = "../../../modules/mysql" }
inputs = {
  resource_group_name = dependency.rg.outputs.name
  mysql_subnet_id = dependency.network.outputs.mysql_subnet_id
  vnet_id = dependency.network.outputs.vnet_id
  admin_login = "ecomadmin"
  admin_password = get_env("TF_VAR_mysql_admin_password")
  location = local.common.locals.location
  tags = local.common.locals.tags
}
