provider "helm" {
  kubernetes {
    host                   = var.host
    client_certificate     = base64decode(var.client_certificate)
    client_key             = base64decode(var.client_key)
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  }
}

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  wait             = true
  timeout          = 600

  values = [yamlencode({
    controller = {
      replicaCount = 1
      service = {
        type                  = "LoadBalancer"
        externalTrafficPolicy = "Local"
        annotations = {
          "service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path" = "/healthz"
        }
      }
      resources = {
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "512Mi"
        }
      }
    }
  })]
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  wait             = true
  timeout          = 900

  values = [yamlencode({
    dex           = { enabled = false }
    notifications = { enabled = false }
    applicationSet = { enabled = false }
    "redis-ha"    = { enabled = false }
    controller    = { replicas = 1 }
    configs = {
      params = {
        "server.insecure" = true
      }
    }
    repoServer    = { replicas = 1 }
    server = {
      replicas = 1
      service = {
        type = "ClusterIP"
      }
    }
  })]

  depends_on = [helm_release.ingress_nginx]
}
