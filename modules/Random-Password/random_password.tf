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

resource "random_password" "password" {
  length           = 30
  special          = true
  min_upper        = 2
  min_lower        = 2
  numeric           = true
  override_special = "!#$%"
  keepers = var.keepers
}