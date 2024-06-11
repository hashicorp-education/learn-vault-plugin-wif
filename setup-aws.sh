#!/bin/bash

# ISSUER set without "http://"
# aws acceess and secret id env variables required
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export TOKEN_AUDIENCE="vault-aws-secrets-test-user"

echo "$AWS_ACCOUNT_ID"
echo "$TOKEN_AUDIENCE"

export AWS_ROLE_ARN=$(aws iam create-role --role-name vault-aws-secrets-engine-wif --assume-role-policy-document file://policy/assume-role.json  | jq ".Role.Arn")

echo "$AWS_ROLE_ARN"

aws iam put-role-policy \
    --role-name vault-aws-secrets-engine-wif \
    --policy-name vault-aws-secrets-engine \
    --policy-document file://policy/config-role.json

aws iam create-open-id-connect-provider --url https://$ISSUER/v1/identity/oidc/plugins --client-id-list "vault-aws-secrets-test-user"

exit