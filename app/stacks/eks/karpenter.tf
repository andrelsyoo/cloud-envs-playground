module "karpenter" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.0.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_karpenter = true

  karpenter_node = {
    iam_role_use_name_prefix = false
    iam_role_name            = "Karpenter-NodeRole-${module.eks.cluster_name}"
    iam_role_additional_policies = [
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
      "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    ]
  }
  karpenter = {
    # Small ugly fix for helm_release only be deployed when fargate_profiles are created
    chart_version = module.eks.fargate_profiles["karpenter"].fargate_profile_status == "ACTIVE" ? "v0.28.0" : "v0.28.0"

    source_policy_documents = [data.aws_iam_policy_document.karpenter.json]
    role_name_use_prefix    = false
    role_name               = "Karpenter-IRSA-${module.eks.cluster_name}"
    service_account_name    = "karpenter"
    namespace               = "kube-system"
    values = [
      <<-EOF
      logLevel: info
      nodeSelector:
        eks.amazonaws.com/compute-type: fargate
      controller:
        resources:
          requests:
            memory: 1792M
          limits:
            memory: 1792M
    EOF
    ]
  }

  karpenter_sqs = {
    kms_master_key_id = module.eks.kms_key_id
  }

  tags = local.tags
}

data "aws_iam_policy_document" "karpenter" {
  statement {
    actions = [
      "ec2:CreateFleet",
      "ec2:CreateLaunchTemplate",
      "ec2:CreateTags",
      "ec2:DeleteLaunchTemplate",
      "ec2:RunInstances"
    ]
    resources = ["*"]
  }
}
