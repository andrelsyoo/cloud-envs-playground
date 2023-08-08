output "cluster" {
  description = "EKS cluster data"
  value = {
    arn                                = module.eks.cluster_arn
    id                                 = module.eks.cluster_name
    cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
    endpoint                           = module.eks.cluster_endpoint
    version                            = module.eks.cluster_version
    cluster_oidc_issuer_url            = module.eks.cluster_oidc_issuer_url
    kms_key_arn                        = module.eks.kms_key_arn
    kms_key_id                         = module.eks.kms_key_id

  }
}
