data "azuread_user" "pm" {
  user_principal_name = "${var.rbac_users["pm"].account_name}@${var.azure_ad_tenant_domain}"
}

data "azuread_user" "arch_reviewer" {
  user_principal_name = "${var.rbac_users["arch_reviewer"].account_name}@${var.azure_ad_tenant_domain}"
}

data "azuread_user" "sec_external" {
  user_principal_name = "${var.rbac_users["sec_external"].account_name}@${var.azure_ad_tenant_domain}"
}

data "azuread_user" "sec_internal1" {
  user_principal_name = "${var.rbac_users["sec_internal1"].account_name}@${var.azure_ad_tenant_domain}"
}

data "azuread_user" "sec_internal2" {
  user_principal_name = "${var.rbac_users["sec_internal2"].account_name}@${var.azure_ad_tenant_domain}"
}
