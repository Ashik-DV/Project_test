# Azure Dev + Prod infrastructure

This folder adds a quota-conscious Terraform + Terragrunt starter for the E-Commerce app.

## Design
- Region: Malaysia West.
- Two separate AKS clusters, Dev and Prod; one small Standard_D2s_v3 node each.
- One shared VNet with separate Dev/Prod AKS subnets and a delegated MySQL subnet.
- One shared Basic ACR; both AKS kubelet identities receive AcrPull.
- One shared private MySQL Flexible Server with separate ecommerce_dev and ecommerce_prod databases.
- Separate resource groups and Key Vaults for Dev and Prod.
- Only two AKS add-ons per cluster: NGINX Ingress Controller and Argo CD.

This is a learning footprint, not production HA. Two AKS clusters still consume VM quota and incur ongoing compute, disk, load balancer, IP and database charges. SKU/service availability is not guaranteed for Azure for Students. Check quota before applying.

## Bootstrap remote state first
Create a storage account and blob container outside this stack to avoid the backend bootstrap problem:

```bash
az group create --name rg-tfstate --location malaysiawest
az storage account create --name <unique_storage_name> --resource-group rg-tfstate --location malaysiawest --sku Standard_LRS --kind StorageV2 --min-tls-version TLS1_2 --allow-blob-public-access false
az storage container create --name tfstate --account-name <unique_storage_name> --auth-mode login
```

Replace REPLACE_WITH_STORAGE_ACCOUNT_NAME in terragrunt.hcl. Grant your identity Storage Blob Data Contributor on the state account and permissions to create Azure resources.

## Login and quota checks
```bash
az login
az account set --subscription "<YOUR_STUDENT_SUBSCRIPTION_ID>"
az vm list-usage --location malaysiawest -o table
az vm list-skus --location malaysiawest --resource-type virtualMachines --query "[?name=='Standard_D2s_v3']" -o table
```

AzureRM v4 also needs the subscription ID available to the provider. In Bash: `export ARM_SUBSCRIPTION_ID="<YOUR_SUBSCRIPTION_ID>"`; in PowerShell: `$env:ARM_SUBSCRIPTION_ID="<YOUR_SUBSCRIPTION_ID>"`.

Set the MySQL password before applying:
- Bash: `export TF_VAR_mysql_admin_password='Use-A-Strong-Unique-Password!'`
- PowerShell: `$env:TF_VAR_mysql_admin_password = "Use-A-Strong-Unique-Password!"`

Terraform state contains sensitive infrastructure values. Protect the state account and never commit passwords or state files.

## Deploy
From this directory, using Terragrunt 0.63.x:

```bash
terragrunt run-all init
terragrunt run-all validate
terragrunt run-all plan
terragrunt run-all apply
```

Review every plan. If you prefer staged deployment, apply shared resources first, then Dev, then Prod:
```bash
cd environments/shared && terragrunt run-all apply
cd ../dev && terragrunt run-all apply
cd ../prod && terragrunt run-all apply
```

Destroy Dev and Prod before shared resources. Never destroy the state account while state is stored there.

## Argo CD
Each cluster receives its own Argo CD and ingress-nginx installation. Argo CD server is ClusterIP. After getting the cluster credentials, access it with:
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```
Change the initial password. Update ../argocd/ecommerce-application.yaml to the correct repo branch and chart path. Create the backend runtime Kubernetes Secret and environment-specific Helm values before syncing.

## Important integration work
The existing CI workflows publish Docker Hub images. This stack creates ACR with admin access disabled and grants AKS AcrPull. Update CI to authenticate to ACR and push there, then update Helm image references. Key Vaults are provisioned with RBAC, but app identities/secret grants are not configured in this starter. Restrict AKS API access and harden networking before real production use.
