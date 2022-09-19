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
data "azuread_client_config" "current" {}

data "azurerm_client_config" "current" {}

module "keyvault" {
  source = ".//modules/Key-Vault"
  tenant_id = data.azurerm_client_config.current.tenant_id

  depends_on = [
    azurerm_resource_group.tf_test
  ]
}
## Service Principal for DevOps

# resource "azuread_application" "azdevopssp" {
#   display_name = "TerraformAppforServicePrincipal2"
#   owners       = [data.azuread_client_config.current.object_id]
# }

# module "azuread-service-principal-password" {
#   source = ".//modules/Random-String"
# }

# resource "azuread_service_principal" "azdevopssp" {
#   application_id = azuread_application.azdevopssp.application_id
#   app_role_assignment_required = false
#   owners                       = [data.azuread_client_config.current.object_id]
# }

# resource "azuread_service_principal_password" "azdevopssp" {
#   service_principal_id = azuread_service_principal.azdevopssp.id
#   value                = "sfvvvdv"
#   end_date             = "2024-01-01T00:00:00Z"
# }

# resource "azurerm_role_assignment" "main" {
#   principal_id         = azuread_service_principal.azdevopssp.id
#   scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
#   role_definition_name = "Contributor"
# }
# data "azuread_user" "user" {
#   user_principal_name = "gwtrain4d_gmail.com#EXT#@gwtrain4dgmail.onmicrosoft.com"
# }

resource "azurerm_key_vault_access_policy" "service_principal" { // This is for the Service Principal in the pipeline to be able to make changes to Key Vault. 
  key_vault_id        = module.keyvault.id
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
  secret_permissions  = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set", ]
  key_permissions     = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", ]
  storage_permissions = ["Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update", ]
}

module "common-secrets-key-vault" {
  source       = ".//modules/Key-Vault-Secret"
  key_vault_id = module.keyvault.id
  secrets_map = {
    "scr-3" = {
      name  = "scr-1",
      value = module.secret1-random-password.value
    },
    "scr-4" = {
      name  = "scr-2",
      value = module.secret2-random-password.value
    }
  }
  depends_on = [
    module.keyvault,
    module.secret1-random-password,
    module.secret2-random-password
  ]
}

module "secret1-random-password" {
  source = ".//modules/Random-Password"
}

module "secret2-random-password" {
  source = ".//modules/Random-Password"
}
