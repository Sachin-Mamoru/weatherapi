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

variable "name" {
  type        = string
  description = "The name of the Key Vault"
}
variable "location" {
  description = "The location of the Key Vault where the Secret should be created"
  type        = string
}
variable "resource_group_name" {
  description = "The resource_group_name of the Key Vault"
  type        = string
}
variable "tenant_id" {
  description = "The ID of the Key Vault where the Secret should be created"
  type        = string
}