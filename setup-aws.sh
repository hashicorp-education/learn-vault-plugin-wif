#!/bin/bash

# ISSUER set without "http://"
# aws acceess and secret id env variables required
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export TOKEN_AUDIENCE="vault-aws-secrets-test-user"

echo "$AWS_ACCOUNT_ID"
echo "$TOKEN_AUDIENCE"

cat <<EOF >> policy/assume-role.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::$AWS_ACCOUNT_ID:oidc-provider/$ISSUER/v1/identity/oidc/plugins"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "$ISSUER_URL/v1/identity/oidc/plugins:aud": "vault-aws-secrets-test-user"
                }
            }
        }
    ]
}
EOF

export AWS_ROLE_ARN=$(aws iam create-role --role-name vault-aws-secrets-engine-wif --assume-role-policy-document file://policy/assume-role.json  | jq ".Role.Arn")

echo "$AWS_ROLE_ARN"

aws iam put-role-policy \
    --role-name vault-aws-secrets-engine-wif \
    --policy-name vault-aws-secrets-engine \
    --policy-document file://policy/config-role.json

# aws iam create-open-id-connect-provider --url https://$ISSUER/v1/identity/oidc/plugins --client-id-list "vault-aws-secrets-test-user"
aws iam create-open-id-connect-provider --url https://$ISSUER/v1/identity/oidc/plugins --thumbprint-list $THUMBPRINT --client-id-list "vault-aws-secrets-test-user"

exit