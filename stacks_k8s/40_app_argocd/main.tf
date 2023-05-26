locals {
  namespace    = "default"
  service_name = "nginx-service"
  ingress_name = "nginx-ingress"
  hpa_name     = "nginx-hpa"
  deploy_name  = "nginx-deploy"
}

resource "kubectl_manifest" "application" {
  yaml_body = templatefile("k8s_app.yaml", {
    name      = local.common_all.app1.app_name
    namespace = "argocd"
    project   = local.common_all.app1.app_project
    repo_url  = local.common_all.app1.repository
    path      = local.common_all.app1.app_path
    rev       = "HEAD"
  })
}

resource "kubectl_manifest" "service" {
  yaml_body = templatefile("k8s_service.yaml", {
    service_name = local.service_name
    pod_name     = local.common_all.app1.app_name
    namespace    = local.namespace
  })
}

resource "kubectl_manifest" "ingress" {
  yaml_body = templatefile("k8s_ingress.yaml", {
    ingress_name = local.ingress_name
    service_name = local.service_name
    namespace    = local.namespace
    fqdn         = local.common_all.app1.fqdn
  })
}

resource "kubectl_manifest" "hpa" {
  yaml_body = templatefile("k8s_hpa.yaml", {
    hpa_name    = local.hpa_name
    deploy_name = local.deploy_name
    namespace   = local.namespace
  })
}
