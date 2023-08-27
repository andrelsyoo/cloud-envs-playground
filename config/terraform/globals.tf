locals {
  environment_domain = lookup([for acc in local.aws_accounts : acc if acc.name == "${local.environment}"][0], "domain")
  organization       = "Myself"
  region             = "<%= expansion(':REGION') %>"
  region_slug        = format("%s%s", substr(replace(local.region, "-", ""), 0, 3), substr(local.region, -1, 1))
  environment        = "<%= expansion(':ENV') %>"

  tags = {
    Organization = local.organization
    Repository   = "https://github.com/andrelsyoo/cloud-envs-playground/"
    Region       = "<%= expansion(':REGION') %>"
    Environment  = "<%= expansion(':ENV') %>"
    Stack        = "<%= expansion(':MOD_NAME') %>"
    ManagedBy    = "Terraform"
  }

  aws_accounts = [
    {
      name           = "dev"
      id             = "710886127438"
      domain         = ""
      admin_role_arn = "arn:aws:iam::710886127438:role/"
    }
  ]
}