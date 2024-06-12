#!/usr/bin/env bash

# Issuer config
vault write identity/oidc/config issuer="https://${ISSUER}"

# AWS secrets engine config
vault secrets enable aws
vault write aws/config/root \
    identity_token_audience="${TOKEN_AUDIENCE}" \
    role_arn="${AWS_ROLE_ARN}"
# vault write aws/roles/my-role \
#     credential_type=iam_user \
#     policy_document=-<<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": "iam:GetUser",
#       "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:user//${aws:username}"
#     }
#   ]
# }
# EOF

vault write aws/roles/my-role \
   credential_type=iam_user \
   policy_document=@my-role-policy.json

vault read aws/creds/my-role

# OpenID config and JWKS for the plugin issuer
curl -s http://localhost:8200/v1/identity/oidc/plugins/.well-known/openid-configuration | jq
curl -s http://localhost:8200/v1/identity/oidc/plugins/.well-known/keys | jq