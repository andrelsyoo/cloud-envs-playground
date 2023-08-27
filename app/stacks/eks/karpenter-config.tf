
resource "kubectl_manifest" "karpenter_node_template" {
  depends_on = [module.karpenter]

  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1alpha1
    kind: AWSNodeTemplate
    metadata:
      name: "${module.eks.cluster_name}-default"
    spec:
      amiFamily: Bottlerocket
      subnetSelector:
        aws-ids: "${join(", ", formatlist("%s", concat(data.aws_subnets.private.ids, data.aws_subnets.public.ids)))}"
      securityGroupSelector:
        aws:eks:cluster-name: ${module.eks.cluster_name}
      blockDeviceMappings:
        # Root device
        - deviceName: /dev/xvda
          ebs:
            volumeSize: 10Gi
            volumeType: gp3
            encrypted: true
        # Data device: Container resources such as images and logs
        - deviceName: /dev/xvdb
          ebs:
            volumeSize: 40Gi
            volumeType: gp3
            encrypted: true
      tags:
        karpenter.sh/discovery: ${module.eks.cluster_name}
        ${yamlencode(local.tags)}
  YAML
}

#resource "kubectl_manifest" "karpenter_provisioner" {
#  depends_on = [kubectl_manifest.karpenter_node_template]
#  lifecycle {
#    ignore_changes = [
#      yaml_body,
#    ]
#  }
#
#  yaml_body = <<-YAML
#    apiVersion: karpenter.sh/v1alpha5
#    kind: Provisioner
#    metadata:
#      name: "${module.eks.cluster_name}-default"
#    spec:
#      consolidation:
#        enabled: true
#      ttlSecondsUntilExpired: 604800
#      requirements:
#        - key: "instance-encryption-in-transit-supported"
#          operator: In
#          values: ["true"]
#        - key: "karpenter.k8s.aws/instance-category"
#          operator: In
#          values: ["m"]
#        - key: "karpenter.k8s.aws/instance-cpu"
#          operator: In
#          values: ["2", "4", "8"]
#        - key: "karpenter.k8s.aws/instance-hypervisor"
#          operator: In
#          values: ["nitro"]
#        - key: karpenter.sh/capacity-type
#          operator: In
#          values: ["spot", "on-demand"]
#        - key: kubernetes.io/os
#          operator: In
#          values: ["linux"]
#        - key: kubernetes.io/arch
#          operator: In
#          values:
#            - amd64
#      limits:
#        resources:
#          cpu: '100'
#          memory: 200Gi
#      providerRef:
#        name: "${module.eks.cluster_name}-default"
#  YAML
#}
