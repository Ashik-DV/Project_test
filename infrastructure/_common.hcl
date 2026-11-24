
locals {
  location = "malaysiawest"

  tags = {
    project    = "ecommerce"
    managed_by = "terraform-terragrunt"
    owner      = "student-lab"
  }
}

remote_state {
  backend = "azurerm"

  config = {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "ashiktfstate2168"
    container_name       = "tfstate"
    key                  = "${path_relative_to_include()}/terraform.tfstate"

    use_azuread_auth = true
  }
}
