terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.24.0"
    }
  }
}

provider "aws" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  audience = "vault-aws-secrets-${random_id.random.hex}"
}

resource "random_id" "random" {
  byte_length = 4
}

data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "vault" {
  url = "${var.issuer}/v1/identity/oidc/plugins"
  thumbprint_list = [var.thumbprint]
  client_id_list = [
    local.audience,
  ]
}

resource "aws_iam_role" "config_role" {
  name = "vault-aws-secrets-engine-wif"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.vault.arn
        }
        Condition = {
          StringEquals = {
            "${var.issuer}/v1/identity/oidc/plugins:aud" = local.audience
          }
        }
      }
    ]
  })

  inline_policy {
    name   = "vault-aws-secrets-engine"
    policy = data.aws_iam_policy_document.hashicorp_vault_secrets_policy.json
  }
}

data "aws_iam_policy_document" "hashicorp_vault_secrets_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "iam:GetInstanceProfile",
      "iam:GetUser",
      "iam:GetRole",
      "iam:GetOpenIDConnectProvider",
      "iam:ListRolePolicies",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:DeleteRolePolicy",
      "iam:DeleteRole",
      "iam:DeleteOpenIDConnectProvider",
      "iam:CreateOpenIDConnectProvider",
      "iam:CreateRole",
      "iam:UpdateOpenIDConnectProviderThumbprint",
      "iam:PutRolePolicy",
      "sts:AssumeRole"
    ]
    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [ ## changed this from role to user
      "arn:aws:iam::${local.account_id}:role/*"
    ]
  }

  statement {
    effect  = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [ ## changed this from role to user
      "arn:aws:iam::${local.account_id}:user/*"
    ]
  }

  statement {
    effect  = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:role/vault-aws-secrets-engine-wif"
    ]
  }

  statement {
    effect  = "Allow"
    actions = [
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:GetAccessKeyLastUsed",
      "iam:GetUser",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey",
      "iam:GetOpenIDConnectProvider",
      "iam:ListRolePolicies",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:DeleteRolePolicy",
      "iam:DeleteRole",
      "iam:DeleteOpenIDConnectProvider",
      "iam:CreateOpenIDConnectProvider",
      "iam:CreateRole",
      "iam:UpdateOpenIDConnectProviderThumbprint",
      "iam:PutRolePolicy",
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:user/*"
    ]
  }

}


# merge of both demos
# works except that assumerole error
# data "aws_iam_policy_document" "hashicorp_vault_secrets_policy" {
#   statement {
#     effect = "Allow"
#     actions = [
#       "iam:AttachUserPolicy",
#       "iam:CreateAccessKey",
#       "iam:CreateUser",
#       "iam:DeleteAccessKey",
#       "iam:DeleteUser",
#       "iam:DeleteUserPolicy",
#       "iam:DetachUserPolicy",
#       "iam:GetUser",
#       "iam:ListAccessKeys",
#       "iam:ListAttachedUserPolicies",
#       "iam:ListGroupsForUser",
#       "iam:ListUserPolicies",
#       "iam:PutUserPolicy",
#       "iam:AddUserToGroup",
#       "iam:RemoveUserFromGroup"
#     ]
#     resources = ["arn:aws:iam::${local.account_id}:user/*"]
#   }

#   statement {
#     effect = "Allow"
#     actions = [
#       "ec2:DescribeInstances",
#       "iam:GetInstanceProfile",
#       "iam:GetUser",
#       "iam:GetRole"
#     ]
#     resources = ["*"]
#   }

#   statement {
#     effect  = "Allow"
#     actions = [
#       "sts:AssumeRole"
#     ]
#     resources = [ ## changed this from role to user
#       "arn:aws:iam::${local.account_id}:user/*"
#     ]
#   }

#   statement {
#     effect  = "Allow"
#     actions = [
#       "iam:CreateAccessKey",
#       "iam:DeleteAccessKey",
#       "iam:GetAccessKeyLastUsed",
#       "iam:GetUser",
#       "iam:ListAccessKeys",
#       "iam:UpdateAccessKey"
#     ]
#     resources = [
#       "arn:aws:iam::${local.account_id}:user/*"
#     ]
#   }

# }

resource "local_file" "setup_environment_file" {
  filename = "output.env"
  content  = <<EOF
export AWS_ROLE_ARN=${aws_iam_role.config_role.arn}
export TOKEN_AUDIENCE=${local.audience}
export AWS_ACCOUNT_ID=${data.aws_caller_identity.current.account_id}
export ISSUER_URL=${var.issuer}
EOF
}

output "aws_role_arn" {
  description = "Role ARN to provide to the AWS Secrets Engine config"
  value = aws_iam_role.config_role.arn
}

output "token_audience" {
  description = "Audience to provide to the AWS Secrets Engine config"
  value = local.audience
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}


output "issuer_url" {
  value = var.issuer
}