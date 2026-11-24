include "root" { path = find_in_parent_folders("terragrunt.hcl") }
locals { common = read_terragrunt_config(find_in_parent_folders("_common.hcl")) }
terraform { source = "../../../modules/resource-group" }
inputs = {
  name = "rg-ecommerce-prod"
  location = local.common.locals.location
  tags = merge(local.common.locals.tags, { environment = "prod" })
}
