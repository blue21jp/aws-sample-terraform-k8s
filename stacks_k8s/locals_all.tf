locals {
  common_all = {
    project = "k8s"
    author  = local.global.unit

    ingress_host = {
      argocd    = "argocd.example.local"
      dashboard = "dashboard.example.local"
    }

    git_info = {
      ssh_private_key     = "~/.ssh/id_rsa"
      ssm_ssh_private_key = "/bitbucket/ssh_private_key"
    }

    app1 = {
      repo_name   = "sandbox"
      repository  = "git@bitbucket.org:blue21/tf-sample-k8s.git"
      app_name    = "nginx"
      app_path    = "app"
      app_project = "default"
      fqdn        = "nginx.example.local"
    }
  }
}
