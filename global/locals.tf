locals {
  global = {
    unit = "blue21"
    git  = "/sandbox"
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
