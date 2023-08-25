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
    kube-proxy = {}
    vpc-cni    = {}
    coredns = {
      configuration_values = jsonencode({
        computeType = "Fargate"
      })
    }
  }

  vpc_id                   = data.aws_vpc.vpc.id
  subnet_ids               = data.aws_subnets.private.ids

  # Fargate profiles use the cluster primary security group so these are not utilized
  create_cluster_security_group = false
  create_node_security_group    = false

  fargate_profile_defaults = {
    iam_role_additional_policies = {
      additional = aws_iam_policy.additional.arn
    }
  }

  fargate_profiles = merge(
    {
      example = {
        name = "example"
        selectors = [
          {
            namespace = "backend"
            labels = {
              Application = "backend"
            }
          },
          {
            namespace = "app-*"
            labels = {
              Application = "app-wildcard"
            }
          }
        ]

        # Using specific subnets instead of the subnets supplied for the cluster itself
        subnet_ids = [module.vpc.private_subnets[1]]

        tags = {
          Owner = "secondary"
        }

        timeouts = {
          create = "20m"
          delete = "20m"
        }
      }
    },
    { for i in range(3) :
    "kube-system-${element(split("-", local.azs[i]), 2)}" => {
      selectors = [
        { namespace = "kube-system" }
      ]
      # We want to create a profile per AZ for high availability
      subnet_ids = [element(module.vpc.private_subnets, i)]
    }
    }
  )

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

resource "aws_iam_policy" "additional" {
  name = "${local.name}-additional"

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