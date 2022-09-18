provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name = "tf_rg_storage"
    storage_account_name = "tffilestorage"
    container_name = "tfstate"
    key = "terraform.tfstate"
  }
}

resource "azurerm_resource_group" "tf_test" {
  name = "tfmainrg"
  location = "eastus"
}

resource "azurerm_container_group" "tfcg_test" {
  name                      = "weatherapi"
  location                  = azurerm_resource_group.tf_test.location
  resource_group_name       = azurerm_resource_group.tf_test.name

  ip_address_type     = "Public"
  dns_name_label      = "sachinmwa"
  os_type             = "Linux"

  container {
      name            = "weatherapi"
      image           = "sachinm4d/wapi:${var.imagebuild}"
        cpu             = "1"
        memory          = "1"

        ports {
            port        = 80
            protocol    = "TCP"
        }
  }
}


data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvault" {
  name                        = "sachinadminkeyvault01"
  location                    = "westus2"
  resource_group_name         = "tfmainrg"
  enabled_for_disk_encryption = false
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  # network_acls {
  #   default_action = "Deny" # "Allow" 
  #   bypass         = "AzureServices" # "None"
  #   ip_rules = ["50.50.50.50/24"]
  # }
  depends_on = [
    azurerm_resource_group.tf_test
  ]
}
## Service Principal for DevOps

resource "azuread_application" "azdevopssp" {
  name = "azdevopsterraform"
}

resource "random_string" "password" {
  length  = 32
  special = true
}

resource "azuread_service_principal" "azdevopssp" {
  application_id = azuread_application.azdevopssp.application_id
}

resource "azuread_service_principal_password" "azdevopssp" {
  service_principal_id = azuread_service_principal.azdevopssp.id
  value                = random_string.password.result
  end_date             = "2024-01-01T00:00:00Z"
}

resource "azurerm_role_assignment" "main" {
  principal_id         = azuread_service_principal.azdevopssp.id
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Contributor"
}

resource "azurerm_key_vault_access_policy" "client" { // This is for AD Users Logged into Azure to give them the right access when creating resources. 
  key_vault_id        = azurerm_key_vault.keyvault.id
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = azuread_service_principal.azdevopssp.object_id
  secret_permissions  = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set", ]
  key_permissions     = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", ]
  storage_permissions = ["Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update", ]
}

resource "azurerm_key_vault_access_policy" "service_principal" { // This is for the Service Principal in the pipeline to be able to make changes to Key Vault. 
  key_vault_id        = azurerm_key_vault.keyvault.id
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
  secret_permissions  = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set", ]
  key_permissions     = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", ]
  storage_permissions = ["Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update", ]
}

module "common-secrets-key-vault" {
  source       = ".//modules/Key-Vault-Secret"
  key_vault_id = azurerm_key_vault.keyvault.id
  secrets_map = {
    "scr-1" = {
      name  = "scr-1",
      value = "module.secret1-random-password.value"
    },
    "scr-2" = {
      name  = "scr-2",
      value = "module.secret2-random-password.value"
    }
  }
  depends_on = [
    azurerm_key_vault.keyvault ,module.secret1-random-password, module.secret2-random-password
  ]
}

module "secret1-random-password" {
  source = ".//modules/Random-Password"
}

module "secret2-random-password" {
  source = ".//modules/Random-Password"
}
