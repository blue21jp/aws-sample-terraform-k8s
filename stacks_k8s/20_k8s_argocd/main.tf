locals {
  name = "argocd"
  set_list = [
    {
      name  = "server.extraArgs"
      value = "{--insecure}"
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
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "5.16.9"
  namespace  = kubernetes_namespace.main.id

  dynamic "set" {
    for_each = local.set_list
    content {
      name  = set.value.name
      value = set.value.value
    }
  }

  depends_on = [
    kubectl_manifest.argocd_external_secret
  ]
}

resource "kubectl_manifest" "argocd_external_secret" {
  yaml_body = templatefile("k8s_argocd_external_secret.yaml", {
    namespace           = kubernetes_namespace.main.id
    git_ssh_private_key = local.common_all.git_info.ssm_ssh_private_key
  })
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
              name = "argocd-server"
              port {
                number = 80
              }
            }
          }
        }
      }
      host = local.common_all.ingress_host.argocd
    }
  }

  depends_on = [
    helm_release.main
  ]

}
