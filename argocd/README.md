# Argo CD deployment

This repository has one Argo CD Application manifest per AKS environment:

- `ecommerce-application.yaml` deploys the Dev overrides from `infrastructure/dev/values.yaml`.
- `ecommerce-prod-application.yaml` deploys the Prod overrides from `infrastructure/prod/values.yaml`.

Both manifests use Argo CD multi-source Applications. The values source is referenced as `$values`, so the environment values files can remain outside the Helm chart directory without duplicating the chart.

## Apply to each cluster

After Terraform/Terragrunt has created the cluster and installed Argo CD, connect kubectl to the Dev cluster and run:

```bash
kubectl apply -f argocd/ecommerce-application.yaml
```

Then connect kubectl to the Prod cluster and run:

```bash
kubectl apply -f argocd/ecommerce-prod-application.yaml
```

Each manifest targets the local cluster (`https://kubernetes.default.svc`), so apply each one to its matching AKS cluster.

## Required backend Secret

The backend chart references an existing Kubernetes Secret named `ecommerce-runtime-secret`. Create it separately in the `ecommerce` namespace in BOTH clusters before the backend can become Ready. Required keys:

- `jwt-key`
- `mysql-connection`
- `email-username`
- `email-password`
- `email-from-address`

The Dev MySQL connection string must select database `ecommerce_dev`; the Prod connection string must select `ecommerce_prod`. Do not commit secret values to Git. The current Terraform creates a Key Vault but does not yet configure Key Vault-to-Kubernetes secret synchronization, so this Secret must currently be provisioned out-of-band or through a separately configured secret integration.

## Container image registry

The Frontend CI and Backend CI workflows publish immutable Git-SHA-tagged Docker images to `ecomlabuou1fc.azurecr.io`. Pull requests only build and test the application and do not authenticate to or push to ACR.

Configure these GitHub Actions repository secrets for OIDC authentication:

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

The Azure application/client identity must have `AcrPush` access to the ACR and must be configured as a federated credential for the repository and `main` environment. The workflow also needs repository permission to write contents so it can update `infrastructure/dev/values.yaml` and `infrastructure/prod/values.yaml`; the `[skip ci]` commit prevents image workflows from retriggering themselves.

On every main-branch application push, CI builds and pushes the image, then updates the frontend or backend Helm tag in both environment values files. Argo CD detects the Git change and reconciles the matching environment.

## Ingress

The chart uses ingress class `nginx`, matching the NGINX Ingress Controller installed by the Terraform add-ons module. The ingress routes `/api` to the backend Service and all other paths to the frontend Service.
