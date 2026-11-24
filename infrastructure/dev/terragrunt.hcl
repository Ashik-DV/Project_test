include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  common = read_terragrunt_config(find_in_parent_folders("_common.hcl"))
}

terraform {
  source = "../modules/platform"
}

inputs = {
  environment          = "dev"
  location             = local.common.locals.location
  tags                 = local.common.locals.tags
  resource_group_name  = "rg-ecommerce-dev"
  aks_name             = "aks-ecommerce-dev"
  dns_prefix           = "ecom-dev"
  node_count           = 1
  node_vm_size         = "Standard_D2s_v3"
  create_shared        = true
  mysql_admin_password = get_env("TF_VAR_mysql_admin_password")
  tfstate_resource_group  = "rg-tfstate"
  tfstate_storage_account = "REPLACE_WITH_STORAGE_ACCOUNT_NAME"
  tfstate_container       = "tfstate"
  shared_state_key        = "dev/terraform.tfstate"
}
