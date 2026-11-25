# Terraform — Azure AKS for E-commerce Observability

This folder provisions a small AKS lab intended for deploying the existing Helm chart and then configuring Dynatrace Operator/DynaKube.

## Resources

- Azure resource group
- Virtual network and AKS subnet
- Log Analytics workspace
- AKS cluster with one system node by default

It does **not** install the application or Dynatrace Operator yet. Those are subsequent steps after infrastructure is validated.

## Prerequisites

- Azure CLI authenticated to the intended subscription: `az login`
- A valid Azure subscription selected: `az account show`
- Terraform 1.6+
- The selected region and VM SKU must be allowed by your subscription policy and have sufficient quota.

The defaults are lab-oriented. They are not a guarantee that the selected region/SKU is available on your current subscription. Adjust them in `terraform.tfvars` before applying.

## Initialize and review

From the repository root:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars to suit your allowed region and quota.
terraform fmt -recursive
terraform init
terraform validate
terraform plan -out=tfplan
```

Review the plan carefully before applying. Creating AKS incurs Azure charges.

```bash
terraform apply tfplan
```

## Connect kubectl

After a successful apply, use the output command or run:

```bash
az aks get-credentials --resource-group rg-ecommerce-observability --name aks-ecommerce-observability --overwrite-existing
kubectl get nodes
```

If you change resource names in `terraform.tfvars`, adjust the command accordingly.

## Cost and cleanup

AKS nodes, load balancers and Log Analytics ingestion may incur charges. Destroy the resources when done with the lab:

```bash
terraform destroy
```

Only run destroy when you intentionally want to remove all Terraform-managed lab resources. Never commit `terraform.tfvars`, state files, credentials, tokens, or application secrets.

## Existing repo follow-up

The repo's Helm chart references an existing Kubernetes Secret named `ecommerce-runtime-secret` for backend runtime credentials. Create that Secret securely before deploying the chart; do not put live credentials into Helm values or Git.

Review the existing Helm chart before install. In particular, the frontend Service template reads `frontend.service.nodePort`, but the current values file does not define that value, and ingress requires an ingress controller to be installed. These should be corrected or explicitly configured before deployment.
