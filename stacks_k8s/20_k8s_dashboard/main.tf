locals {
  name = "kubernetes-dashboard"
  set_list = [
    {
      name  = "service.externalPort"
      value = "9090"
    },
    {
      name  = "protocolHttp"
      value = true
    },
    {
      name  = "extraArgs"
      value = "{--enable-skip-login,--enable-insecure-login,--disable-settings-authorizer,--insecure-bind-address=0.0.0.0}"
    },
    {
      name  = "rbac.clusterReadOnlyRole"
      value = true
    },
    {
      name  = "metricsScraper.enabled"
      value = true
    }
  ]
}

resource "kubernetes_namespace" "main" {
  metadata {
    name = local.name
  }
}

resource "helm_release" "main" {
  name       = local.name
  chart      = "kubernetes-dashboard"
  repository = "https://kubernetes.github.io/dashboard"
  version    = "6.0.0"
  namespace  = kubernetes_namespace.main.id

  dynamic "set" {
    for_each = local.set_list
    content {
      name  = set.value.name
      value = set.value.value
    }
  }
}

resource "kubernetes_ingress_v1" "main" {
  wait_for_load_balancer = true
  metadata {
    name      = local.name
    namespace = kubernetes_namespace.main.id
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }

  spec {
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "kubernetes-dashboard"
              port {
                number = 9090
              }
            }
          }
        }
      }
      host = local.common_all.ingress_host.dashboard
    }
  }

  depends_on = [
    helm_release.main
  ]
}
