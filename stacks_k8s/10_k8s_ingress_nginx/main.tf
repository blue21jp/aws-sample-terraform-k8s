locals {
  name = "ingress-nginx"
  set_list = [
    {
      name  = "controller.extraArgs.enable-ssl-passthrough"
      value = ""
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
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "4.4.0"
  namespace  = kubernetes_namespace.main.id

  dynamic "set" {
    for_each = local.set_list
    content {
      name  = set.value.name
      value = set.value.value
    }
  }
}
