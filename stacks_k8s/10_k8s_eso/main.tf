locals {
  name = "external-secrets"
  set_list = [
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.eso.arn
    },
    {
      name  = "extraEnv[0].name"
      value = "AWS_SSM_ENDPOINT"
    },
    {
      name  = "extraEnv[0].value"
      value = "http://${data.external.myip.result["ip"]}:4566"
    },
    {
      name  = "extraEnv[1].name"
      value = "AWS_STS_ENDPOINT"
    },
    {
      name  = "extraEnv[1].value"
      value = "http://${data.external.myip.result["ip"]}:4566"
    },
    {
      name  = "extraEnv[2].name"
      value = "AWS_SECRETSMANAGER_ENDPOINT"
    },
    {
      name  = "extraEnv[2].value"
      value = "http://${data.external.myip.result["ip"]}:4566"
    }
  ]
}

resource "kubernetes_namespace" "main" {
  metadata {
    name = local.name
  }
}

resource "helm_release" "main" {
  name          = local.name
  chart         = "external-secrets"
  repository    = "https://charts.external-secrets.io"
  version       = "0.7.0"
  namespace     = kubernetes_namespace.main.id
  wait_for_jobs = true

  dynamic "set" {
    for_each = local.set_list
    content {
      name  = set.value.name
      value = set.value.value
    }
  }
}

resource "kubectl_manifest" "cluster_secret_store" {
  yaml_body = templatefile("k8s_cluster_secret_store.yaml", {
    namespace  = kubernetes_namespace.main.id
    aws_region = data.aws_region.current.name
  })

  depends_on = [
    helm_release.main
  ]
}

## localstack用のウソrole.
## 存在すればOKなので設定内容は出鱈目
resource "aws_iam_role" "eso" {
  name = "eso_dummy_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}
