#module "base_addons" {
#  depends_on = [kubectl_manifest.karpenter_provisioner]
#
#  source  = "aws-ia/eks-blueprints-addons/aws"
#  version = "1.0.0"
#
#  cluster_name      = module.eks.cluster_name
#  cluster_endpoint  = module.eks.cluster_endpoint
#  cluster_version   = module.eks.cluster_version
#  oidc_provider_arn = module.eks.oidc_provider_arn
#
#  eks_addons = {
#    aws-ebs-csi-driver = {
#      most_recent   = false
#      addon_version = "v1.19.0-eksbuild.2"
#    }
#  }
#
#  enable_aws_load_balancer_controller = true
#  aws_load_balancer_controller = {
#    chart_version        = "1.5.3"
#    role_name_use_prefix = false
#    role_name            = "AWSLoadBalancerController-IRSA-${module.eks.cluster_name}"
#    create_namespace     = false
#    service_account_name = "aws-loadbalancer-controller"
#    namespace            = "kube-system"
#    values = [
#      <<-EOF
#      topologySpreadConstraints:
#      - maxSkew: 1
#        topologyKey: topology.kubernetes.io/zone
#        whenUnsatisfiable: DoNotSchedule
#    EOF
#    ]
#  }
#
#  enable_metrics_server = true
#  metrics_server = {
#    chart_version        = "3.10.0"
#    role_name_use_prefix = false
#    role_name            = "MetricsServer-IRSA-${module.eks.cluster_name}"
#    create_namespace     = false
#    service_account_name = "metrics-server"
#    namespace            = "kube-system"
#  }
#  enable_external_secrets = true
#  external_secrets = {
#    chart_version        = "0.8.3"
#    role_name_use_prefix = false
#    role_name            = "ExternalSecrets-IRSA-${module.eks.cluster_name}"
#    create_namespace     = false
#    service_account_name = "external-secrets"
#    namespace            = "kube-system"
#    values = [
#      <<-EOF
#      replicaCount: 2
#      podDisruptionBudget: {"enabled":true,"minAvailable":1}
#      topologySpreadConstraints:
#      - maxSkew: 1
#        topologyKey: topology.kubernetes.io/zone
#        whenUnsatisfiable: DoNotSchedule
#    EOF
#    ]
#  }
#
#  enable_external_dns                    = false
#  enable_cluster_proportional_autoscaler = true
#  cluster_proportional_autoscaler = {
#    values = [
#      <<-EOF
#      config:
#        linear:
#          coresPerReplica: 256
#          nodesPerReplica: 16
#          min: 2
#          max: 10
#          preventSinglePointFailure: true
#          includeUnschedulableNodes: true
#      options:
#        namespace: kube-system
#        target: deployment/coredns
#    EOF
#    ]
#  }
#  enable_aws_efs_csi_driver = true
#  aws_efs_csi_driver = {
#    chart_version        = "2.4.4"
#    role_name            = "AWSEFSCSIDriver-IRSA-${module.eks.cluster_name}"
#    role_name_use_prefix = false
#    service_account_name = "efs-csi-driver-controller"
#    namespace            = "kube-system"
#    values = [
#      <<-EOF
#      topologySpreadConstraints:
#      - maxSkew: 1
#        topologyKey: topology.kubernetes.io/zone
#        whenUnsatisfiable: DoNotSchedule
#    EOF
#    ]
#  }
#
#  tags = merge(
#    local.tags,
#    {
#      "kubernetes.io/cluster/${module.eks.cluster_name}" = ""
#    }
#  )
#}
