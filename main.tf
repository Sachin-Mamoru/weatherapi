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
  name = var.rg_name
  location = var.rg_location
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

module "keyvault" {
  source = ".//modules/Key-Vault"
  name = var.keyvault_name
  location = azurerm_resource_group.tf_test.location
  resource_group_name = azurerm_resource_group.tf_test.name
  tenant_id = data.azurerm_client_config.current.tenant_id

  depends_on = [
    azurerm_resource_group.tf_test
  ]
}
resource "azurerm_key_vault_access_policy" "service_principal" { // This is for the Service Principal in the pipeline to be able to make changes to Key Vault. 
  key_vault_id        = module.keyvault.id
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
  secret_permissions  = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set", ]
  key_permissions     = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", ]
  storage_permissions = ["Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update", ]
}
# "7e101e9b-3b0a-4b0a-920d-ba3ba0809027"
module "common-secrets-key-vault" {
  source       = ".//modules/Key-Vault-Secret"
  key_vault_id = module.keyvault.id
  secrets_map = {
    "scr-001" = {
      name  = var.secret1_name,
      value = module.secret1-random-password.value
    },
    "scr-002" = {
      name  = var.secret2_name,
      value = module.secret2-random-password.value
    }
  }
  depends_on = [
    module.secret1-random-password,
    module.secret2-random-password,
    azurerm_key_vault_access_policy.service_principal
  ]
}

module "secret1-random-password" {
  source = ".//modules/Random-Password"
}

module "secret2-random-password" {
  source = ".//modules/Random-Password"
}
