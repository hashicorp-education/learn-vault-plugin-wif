# Plugin Identity Tokens - AWS Secrets Engine

Prerequisites:

- An AWS IAM user/role with an appropriate permissions policy to apply the Terraform
- Vault server build using the branch [`plugin-workload-identity`](https://github.com/hashicorp/vault/compare/plugin-workload-identity)
- Vault server running and reachable by AWS to obtain its OpenID config and JWKS
  - Ensure to set the `VAULT_API_ADDR` env var correctly to set the token [`issuer`](https://developer.hashicorp.com/vault/api-docs/secret/identity/tokens#issuer)
  - Ngrok is used for the demo

```
ngrok http 8200 --subdomain=agv
terraform init
terraform apply
source output.env
./demo.sh
```

The AWS secrets engine is now configured without any static IAM user credentials.
When it's STS credentials expire, it will automatically reach out for a new plugin 
identity token over the system view, exchange it for new STS credentials, and continue 
operating.
