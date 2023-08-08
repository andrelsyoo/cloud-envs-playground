variable "kubernetes_version" {
  description = "Kubernetes version to be deployed"
  type        = string
}

variable "kubernetes_suffix" {
  description = "Suffix to be added to the cluster name"
  type        = string
}

variable "vpc_purpose_tag" {
  description = "The tag used to identify the VPCs to be used by the cluster"
  type        = string
  default     = "workloads"
}