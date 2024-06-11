#!/usr/bin/env bash

vault write identity/oidc/config issuer="${ISSUER_URL}"

vault auth enable aws

#vault write -force auth/aws/config/client

vault write auth/aws/config/client \
identity_token_audience="${TOKEN_AUDIENCE}" \
role_arn="${AWS_ROLE_ARN}"

vault write auth/aws/role/dev-role-iam \
auth_type=iam \
bound_iam_principal_arn="arn:aws:iam::${AWS_ACCOUNT_ID}:user/*"