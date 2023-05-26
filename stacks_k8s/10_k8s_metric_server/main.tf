locals {
  name = "metric-server"
  set_list = [
    {
      name  = "metrics.enabled"
      value = false
    },
    {
      name  = "args"
      value = "{--cert-dir=/tmp,--secure-port=4443,--v=2,--kubelet-insecure-tls,--kubelet-preferred-address-types=InternalIP}"
    }
  ]
}

resource "helm_release" "metrics-server" {
  name = local.name

  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.8.3"

  dynamic "set" {
    for_each = local.set_list
    content {
      name  = set.value.name
      value = set.value.value
    }
  }
}
