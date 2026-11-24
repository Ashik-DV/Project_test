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

The current GitHub Actions workflows publish images to Docker Hub (`ashikdv/ecommercebackend` and `ashikdv/ecommercefrontend`), and the environment Helm values use those same repositories. The Terraform stack also creates an Azure Container Registry and grants AKS pull access to it, but the workflows do not currently publish to that ACR. This does not prevent the chart from pulling public Docker Hub images; it means ACR is provisioned but not yet used by the current CI pipeline.

## Ingress

The chart uses ingress class `nginx`, matching the NGINX Ingress Controller installed by the Terraform add-ons module. The ingress routes `/api` to the backend Service and all other paths to the frontend Service.
