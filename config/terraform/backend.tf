terraform {
  backend "s3" {
    bucket         = "playground-tfstate23"
    key            = "<%= expansion('terraspace/:ENV-:TS_APP-:REGION-:MOD_NAME/terraform.tfstate') %>"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "playground-tfstate23-lock"
  }
}