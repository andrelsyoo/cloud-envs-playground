# Docs: https://terraspace.cloud/docs/config/reference/
Terraspace.configure do |config|
  config.logger.level = :info
  config.layering.show = true
  config.build.copy_modules = true
  config.allow.envs = ["dev", "stg", "prd"]
  config.allow.regions = ["us-east-1", "eu-central-1"]
end