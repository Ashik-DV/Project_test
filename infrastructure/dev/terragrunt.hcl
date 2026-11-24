include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  common = read_terragrunt_config(find_in_parent_folders("_common.hcl"))
  env    = read_tfvars_file("${get_terragrunt_dir()}/terraform.tfvars")
}

terraform {
  source = "../"
}

inputs = merge(local.env, {
  location = local.common.locals.location
  tags     = local.common.locals.tags

  mysql_admin_password   = get_env("TF_VAR_mysql_admin_password")
  tfstate_resource_group  = "rg-tfstate"
  tfstate_storage_account = "ashiktfstate2168"
  tfstate_container       = "tfstate"
  shared_state_key        = "dev/terraform.tfstate"
})
