# -------------------------------------------------------------------------------------
#
# Copyright (c) 2022 WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 Inc. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

resource "azurerm_key_vault_secret" "key_vault_secret" {
  for_each     = var.secrets_map
  key_vault_id = var.key_vault_id
  name         = each.value.name
  value        = each.value.value
}

# output "secret_name" {
#   value = random_password.password
# }

# -----------------------------------------------------------

# resource "azurerm_key_vault_secret" "key_vault_secret" {
#   count        = length(var.secrets_map)
#   key_vault_id = var.key_vault_id
#   name         = values(var.secrets_map)[count.index].name
#   value        = values(var.secrets_map)[count.index].random ? random_password.password[count.index].result : (values(var.secrets_map)[count.index].hash != "" ? sha256([for x in var.secrets_map : x.value if x.hash == values(var.secrets_map)[count.index].hash][0]) : values(var.secrets_map)[count.index].value)
#   depends_on = [
#     random_password.password
#   ]
# }

# resource "random_password" "password" {
#   count            = length(var.secrets_map)
#   length           = 16
#   special          = true
#   override_special = "!#$%&*()-_=+[]{}<>:?"
#   keepers = {
#     "version" = values(var.secrets_map)[count.index].version
#   }
# }

# -----------------------------------------------------------

# resource "azurerm_key_vault_secret" "key_vault_secret" {
#   count        = length(var.secrets_map)
#   key_vault_id = var.key_vault_id
#   name         = var.secrets_map[count.index].name
#   value        = var.secrets_map[count.index].random ? random_password.password[count.index].result : (var.secrets_map[count.index].hash != "" ? sha256([for x in var.secrets_map : x.value if x.hash == var.secrets_map[count.index].hash][0]) : var.secrets_map[count.index].value)
#   depends_on = [
#     random_password.password
#   ]
# }

# resource "random_password" "password" {
#   count            = length(var.secrets_map)
#   length           = 16
#   special          = true
#   override_special = "!#$%&*()-_=+[]{}<>:?"
#   keepers = {
#     "version" = var.secrets_map[count.index].version
#   }
# }

# -----------------------------------------------------------

# resource "azurerm_key_vault_secret" "key_vault_secret" {
#   for_each     = var.secrets_map
#   key_vault_id = var.key_vault_id
#   name         = each.value.name
#   value        = each.value.value
# }

# resource "random_password" "password" {
#   count            = length(var.secrets_map)
#   length           = 16
#   special          = true
#   override_special = "!#$%&*()-_=+[]{}<>:?"
#   keepers = {
#     "version" = values(var.secrets_map)[count.index].version
#   }
# }

# output "secret_name" {
#   value = random_password.password
# }
