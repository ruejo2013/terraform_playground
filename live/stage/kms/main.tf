terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


resource "aws_kms_key" "cmk"  {
  policy   =  data.aws_iam_policy_document.cmk_admin_policy.json
}

resource "aws_kms_alias" "cmk"  {
  name           =  "alias/kms-cmk-example"
  target_key_id  = aws_kms_key.cmk.id
}

data "aws_caller_identity" "self" {}

data "aws_iam_policy_document" "cmk_admin_policy" {
  statement {
    effect      = "Allow"
    resources   = ["*"]
    actions     = ["kms:*"]
    principals  {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.self.arn]
    }
  }
}