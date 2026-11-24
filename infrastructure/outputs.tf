output "aks_name" {
  value = module.aks.name
}

output "aks_id" {
  value = module.aks.id
}

output "key_vault_name" {
  value = module.keyvault.name
}

output "key_vault_uri" {
  value = module.keyvault.vault_uri
}

output "acr_id" {
  value = local.shared_acr_id
}

output "network" {
  value = {
    dev_subnet_id  = local.shared_network.dev_subnet_id
    prod_subnet_id = local.shared_network.prod_subnet_id
  }
}

output "mysql_fqdn" {
  value = var.create_shared ? module.mysql[0].fqdn : data.terraform_remote_state.shared[0].outputs.mysql_fqdn
}
