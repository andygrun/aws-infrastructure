terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "eu-west-1"
  profile = "admin"
}

provider "aws" {

  alias   = "sso"
  region  = "eu-north-1"
  profile = "admin"
}

data "aws_ssoadmin_instances" "this" {
  provider = aws.sso
}

output "arn" { value = tolist(data.aws_ssoadmin_instances.this.arns)[0] }

output "identity_store_id" { value = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0] }
