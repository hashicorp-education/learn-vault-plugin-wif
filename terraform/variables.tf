variable "issuer" {
  type        = string
  description = "The issuer to set for Vault identity tokens"

  # Assumes using ngrok for my local setup, you may need to adjust this depending
  # on how you're exposing Vault to AWS. The VAULT_API_ADDR must match this value.
}

variable "thumbprint" {
  type = string
  description = "The thumbprint of the Vault server calculated form its certificate chain"

  # Assumes using ngrok for my local setup, you may need to adjust this depending
  # on how you're exposing Vault to AWS. For details on calculating this see
  # https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html
}