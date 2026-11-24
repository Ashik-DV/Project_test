# E-Commerce Azure Infrastructure

Terraform and Terragrunt configuration for the Dev and Prod environments in Malaysia West.

## Folder structure

```text
infrastructure/
├── terragrunt.hcl
├── _common.hcl
├── main.tf
├── variables.tf
├── outputs.tf
├── README.md
├── .gitignore
│
├── modules/
│   ├── resource-group/
│   ├── networking/
│   ├── acr/
│   ├── aks/
│   ├── mysql/
│   ├── keyvault/
│   └── addons/
│
├── dev/
│   ├── terragrunt.hcl
│   ├── terraform.tfvars
│   └── values.yaml
│
└── prod/
    ├── terragrunt.hcl
    ├── terraform.tfvars
    └── values.yaml
```

There is one Terraform root configuration at the infrastructure level (main.tf, variables.tf and outputs.tf). It calls the reusable modules. Dev and Prod each have exactly one terragrunt.hcl and their own terraform.tfvars. The root infrastructure/terragrunt.hcl owns the Azure remote backend and provider generation. _common.hcl contains only shared local values. Do not add another backend configuration to main.tf or _common.hcl.

## Resources

- One shared resource group containing the shared networking, ACR and MySQL resources.
- One shared VNet with separate Dev and Prod AKS subnets, plus a delegated MySQL subnet.
- One shared Basic Azure Container Registry.
- One shared private MySQL Flexible Server with two databases: ecommerce_dev and ecommerce_prod.
- A separate resource group, AKS cluster and Key Vault for Dev and Prod.
- NGINX Ingress Controller and Argo CD installed into each AKS cluster.

The shared VNet, ACR and MySQL server are created by the Dev state. Prod reads their outputs from the Dev state. Therefore, deploy Dev first and do not destroy Dev while Prod depends on those shared resources.

## 1. Remote state storage

The Azure remote-state storage has been bootstrapped with:

- Resource group: rg-tfstate
- Storage account: ashiktfstate2168
- Blob container: tfstate
- Region: malaysiawest

The root Terragrunt configuration uses the azurerm backend. The state keys are generated from each environment directory:
- Dev: dev/terraform.tfstate
- Prod: prod/terraform.tfstate

Both environments use Azure AD authentication. The signed-in Azure identity needs Storage Blob Data Contributor on the storage account and sufficient permissions to create the Azure resources.

The Terraform remote-state data source in main.tf intentionally reads dev/terraform.tfstate from Prod so Prod can consume the shared network, ACR and MySQL outputs created by Dev. This is separate from the Prod environment's own backend state.

## 2. Set Azure authentication and the MySQL password

For PowerShell:

```powershell
az login
az account set --subscription "<YOUR_SUBSCRIPTION_ID>"
$env:ARM_SUBSCRIPTION_ID="<YOUR_SUBSCRIPTION_ID>"
$env:TF_VAR_mysql_admin_password="<STRONG_UNIQUE_PASSWORD>"
```

Do not commit credentials or passwords to Git.

Check available VM quota and SKU availability before deploying:

```powershell
az vm list-usage --location malaysiawest -o table
az vm list-skus --location malaysiawest --resource-type virtualMachines --query "[?name=='Standard_D2s_v3']" -o table
```

## 3. Deploy Dev first

```powershell
cd infrastructure/dev
terragrunt init
terragrunt validate
terragrunt plan
terragrunt apply
```

Dev creates its AKS cluster and Key Vault, plus the shared VNet, ACR and MySQL server/databases.

## 4. Deploy Prod second

```powershell
cd ../prod
terragrunt init
terragrunt validate
terragrunt plan
terragrunt apply
```

Prod creates its own AKS cluster and Key Vault and reads the shared networking and ACR outputs from Dev's remote state.

Review the plan before applying. The small one-node clusters are intended for a learning environment, not production high availability. Confirm Azure for Students quota and costs before deployment.

## Notes

- The existing CI workflows currently publish Docker Hub images. Update them separately if you want to push images to the ACR created here.
- Key Vaults are created with RBAC enabled; application access policies/role assignments and secret population still need to be configured.
- AKS API endpoints are public in this learning configuration. Restrict authorized IP ranges and harden the cluster before production use.
- The values.yaml files are environment-specific Helm values; Terraform does not automatically consume them.
- Destroy Prod first. Do not destroy Dev while Prod uses the shared VNet, ACR or MySQL resources.
