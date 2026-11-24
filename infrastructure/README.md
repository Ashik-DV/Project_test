# Azure Dev + Prod infrastructure

This Terraform + Terragrunt setup deploys the E-Commerce platform into two environments in Malaysia West.

## Folder structure

```text
infrastructure/
├── terragrunt.hcl
├── _common.hcl
├── README.md
├── modules/
│   ├── platform/             # Root Terraform module composed from the modules below
│   ├── resource-group/
│   ├── networking/
│   ├── acr/
│   ├── aks/
│   ├── mysql/
│   ├── keyvault/
│   └── addons/               # NGINX Ingress + Argo CD
├── dev/
│   └── terragrunt.hcl        # The only Terragrunt entry point for Dev
└── prod/
    └── terragrunt.hcl        # The only Terragrunt entry point for Prod
```

Each environment has one Terragrunt configuration. It calls the composite Terraform root module at modules/platform. That root module calls the smaller reusable Terraform modules. Terraform resources and module blocks belong in Terraform .tf files, not in terragrunt.hcl.

## What gets created

- Two separate AKS clusters, one small node per cluster (Standard_D2s_v3).
- One shared VNet with separate Dev and Prod AKS subnets and a delegated MySQL subnet.
- One shared Basic Azure Container Registry (ACR), with AcrPull granted to both clusters.
- One shared private MySQL Flexible Server with ecommerce_dev and ecommerce_prod databases.
- A separate resource group and Key Vault for each environment.
- NGINX Ingress Controller and Argo CD installed in each cluster.

This is a learning footprint, not production HA. Two AKS clusters still consume VM quota and incur ongoing compute, disk, load balancer, IP and database charges. Azure for Students quotas and SKU availability must be checked before deployment.

## Shared-resource ownership

To preserve exactly two environment states, Dev owns the shared VNet, ACR and MySQL server. Prod reads their outputs from the Dev Terraform state. Deploy Dev first and Prod second. Do not destroy the Dev stack while Prod is using the shared resources. If you need Dev and Prod to have fully independent lifecycles, introduce a third dedicated shared state/unit instead.

## 1. Bootstrap remote state

Create the state resource group, storage account and blob container outside Terraform:

```bash
az group create --name rg-tfstate --location malaysiawest
az storage account create --name <unique_storage_name> --resource-group rg-tfstate --location malaysiawest --sku Standard_LRS --kind StorageV2 --min-tls-version TLS1_2 --allow-blob-public-access false
az storage container create --name tfstate --account-name <unique_storage_name> --auth-mode login
```

Update the storage account placeholder in all three places:
- infrastructure/terragrunt.hcl
- infrastructure/dev/terragrunt.hcl
- infrastructure/prod/terragrunt.hcl

Grant your Azure identity Storage Blob Data Contributor on the storage account, plus permissions to create the infrastructure resources.

## 2. Login and check quota

```bash
az login
az account set --subscription "<YOUR_STUDENT_SUBSCRIPTION_ID>"
az vm list-usage --location malaysiawest -o table
az vm list-skus --location malaysiawest --resource-type virtualMachines --query "[?name=='Standard_D2s_v3']" -o table
```

AzureRM v4 needs the subscription ID in the environment:

Bash:
```bash
export ARM_SUBSCRIPTION_ID="<YOUR_SUBSCRIPTION_ID>"
```

PowerShell:
```powershell
$env:ARM_SUBSCRIPTION_ID="<YOUR_SUBSCRIPTION_ID>"
```

Set a strong MySQL administrator password. Do not put it in Git:

Bash:
```bash
export TF_VAR_mysql_admin_password='Use-A-Strong-Unique-Password!'
```

PowerShell:
```powershell
$env:TF_VAR_mysql_admin_password="Use-A-Strong-Unique-Password!"
```

## 3. Deploy in order

Run these commands from the infrastructure directory:

```bash
cd dev
terragrunt init
terragrunt validate
terragrunt plan
terragrunt apply
```

Wait for Dev to finish successfully. Dev creates the shared resources and stores their outputs in dev/terraform.tfstate.

Then deploy Prod:

```bash
cd ../prod
terragrunt init
terragrunt validate
terragrunt plan
terragrunt apply
```

Run plan and apply separately so you can inspect the changes before confirming them. Do not run prod before dev has successfully created the shared resources.

## 4. Argo CD access

Each cluster receives its own Argo CD and ingress-nginx installation. Argo CD server is configured as ClusterIP. After connecting kubectl to the required cluster:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```

Change the initial password. Configure the Argo CD application manifest and create the backend runtime Kubernetes Secret before syncing the application.

## Notes and remaining application integration

- The existing CI workflows publish Docker Hub images. Update CI to push to the ACR created here, then update Helm image references.
- Key Vaults are created with RBAC, but application identity permissions and secret population are not configured in this starter.
- The AKS API endpoints are public in this learning setup. Restrict authorized IP ranges and harden networking before production use.
- Terraform state contains sensitive infrastructure values. Protect the state storage account and never commit state files or credentials.
- Destroy Prod first. Do not destroy Dev while it owns shared infrastructure. Keep the remote-state storage account until all state is no longer needed.
