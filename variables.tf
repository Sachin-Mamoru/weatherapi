variable "secret_name" {
  type        = string
  default = "name"
  description = "Key Vault Secret name in Azure"
}

variable "secret_value" {
  type        = string
  default = "value"
  description = "Key Vault Secret value in Azure"
  sensitive   = true
}

variable "imagebuild" {
  type = string
  description = "Latest Image Build"
  default = "value"
}