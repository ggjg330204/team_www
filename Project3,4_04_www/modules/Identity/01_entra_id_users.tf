data "azuread_user" "pm_user" {
  user_principal_name = "student421@mscsschool.onmicrosoft.com"
}
data "azuread_user" "network_admin" {
  user_principal_name = "student424@mscsschool.onmicrosoft.com"
}
data "azuread_user" "compute_admin" {
  user_principal_name = "student411@mscsschool.onmicrosoft.com"
}
data "azuread_user" "db_admin" {
  user_principal_name = "student420@mscsschool.onmicrosoft.com"
}
data "azuread_user" "security_admin" {
  user_principal_name = "student426@mscsschool.onmicrosoft.com"
}

data "azuread_user" "student415" {
  user_principal_name = "student415@mscsschool.onmicrosoft.com"
}
