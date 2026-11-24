include "root" { path = find_in_parent_folders("terragrunt.hcl") }
dependency "aks" { config_path = "../aks" }
terraform { source = "../../../modules/addons" }
inputs = {
  host = dependency.aks.outputs.host
  client_certificate = dependency.aks.outputs.client_certificate
  client_key = dependency.aks.outputs.client_key
  cluster_ca_certificate = dependency.aks.outputs.cluster_ca_certificate
}
