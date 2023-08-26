################################################################################
# EKS Module
################################################################################

locals {
  cluster_name = "${local.environment}-${local.region}-${var.kubernetes_suffix}"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.15"

  cluster_name                   = local.cluster_name
  cluster_version                = var.kubernetes_version
  cluster_endpoint_public_access = true

  cluster_addons = {
    vpc-cni = {
      most_recent = false
      addon_version     = "v1.13.4-eksbuild.1"
    }
    #coredns = {
    #  most_recent = false
    #  addon_version     = "v1.10.1-eksbuild.3"
    #  configuration_values = jsonencode({
    #    computeType = "fargate"
    #    resources = {
    #      limits = {
    #        cpu    = "0.25"
    #        memory = "256M"
    #      }
    #      requests = {
    #        cpu    = "0.25"
    #        memory = "256M"
    #      }
    #    }
    #  })
    #}
  }

  vpc_id                   = data.aws_vpc.vpc.id
  subnet_ids               = data.aws_subnets.private.ids

  # Fargate profiles use the cluster primary security group so these are not utilized
  create_cluster_security_group = true
  create_node_security_group    = false
  cluster_security_group_additional_rules = {
    allow_vpc_cluster = {
      description = "All VPC to cluster endpoint"
      protocol    = "-1"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = ["10.0.0.0/8"]
    }
  }

  cluster_security_group_tags = {
    "karpenter.sh/discovery" = local.cluster_name
  }

  cluster_enabled_log_types = [
    "audit",
    "api",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  # We'll not be deploying node groups as we'll be using Karpenter for this
  # The fargate profiles are only for hosting the karpenter and core-dns pods
  # Reducing the need for a static node group, hence reducing our costs
  fargate_profiles = {
    karpenter = {
      selectors = [
        {
          namespace = "kube-system"
          labels = {
            "app.kubernetes.io/name" = "karpenter"
          }
        }
      ]
    }
    coredns = {
      selectors = [
        {
          namespace = "kube-system"
          labels = {
            "eks.amazonaws.com/component" = "coredns"
          }
        }
      ]
    }
  }

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

resource "aws_iam_policy" "additional" {
  name = "${local.environment}-additional"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}