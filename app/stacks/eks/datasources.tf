data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}
#------------------------------------------------
# Get data from existant VPCs / Subnets
#------------------------------------------------
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Environment"
    values = ["${local.environment}"]
  }
  filter {
    name   = "tag:Region"
    values = ["${local.region}"]
  }
  filter {
    name   = "tag:Purpose"
    values = ["${var.vpc_purpose_tag}"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:kubernetes.io/role/internal-elb"
    values = ["1"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:kubernetes.io/role/elb"
    values = ["1"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}
data "aws_iam_roles" "admin_roles" {
  name_regex = ".*AdministratorAccess.*"
}

data "aws_iam_users" "admin_service_accounts" {
  path_prefix = "/operations"
}
