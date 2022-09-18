resource "azuredevops_variable_group" "variablegroup" {
  project_id   = "bc064c68-9815-4ae0-9db4-4db6167e6765"
  name         = "terraform-tuesdays"
  description  = "Variable group for pipelines"
  allow_access = true

  variable {
    name  = "service_name"
    value = "key_vault"
  }

  variable {
    name = "key_vault_name"
    value = local.az_key_vault_name
  }

}

# Key Vault setup
## There needs to be a service connection to an Azure sub with the key vault
## https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/serviceendpoint_azurerm

resource "azuredevops_serviceendpoint_azurerm" "key_vault" {
  project_id = "bc064c68-9815-4ae0-9db4-4db6167e6765"
  service_endpoint_name = "key_vault"
  description = "Azure Service Endpoint for Key Vault Access"

  credentials {
    serviceprincipalid = azuread_application.service_connection.application_id
    serviceprincipalkey = random_password.service_connection.result
  }

  azurerm_spn_tenantid = data.azurerm_client_config.current.tenant_id
  azurerm_subscription_id = data.azurerm_client_config.current.subscription_id
  azurerm_subscription_name = data.azurerm_subscription.current.display_name
}
# https://dev.azure.com/gwtrain4d/_apis/projects?api-version=5.0-preview.3
resource "azuredevops_resource_authorization" "kv_auth" {
  project_id  = "bc064c68-9815-4ae0-9db4-4db6167e6765"
  resource_id = azuredevops_serviceendpoint_azurerm.key_vault.id
  authorized  = true
}

# Key Vault task is here: https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/deploy/azure-key-vault?view=azure-devops
