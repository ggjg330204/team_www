# 1. PM (프로젝트 매니저) - 이기훈
data "azuread_user" "pm_user" {
  user_principal_name = "student420@mscsschool.onmicrosoft.com"
}

# 2. Network 관리자 - 이하연
data "azuread_user" "network_admin" {
  user_principal_name = "student424@mscsschool.onmicrosoft.com"
}

# 3. Compute 관리자 - 배하영
data "azuread_user" "compute_admin" {
  user_principal_name = "student411@mscsschool.onmicrosoft.com"
}

# 4. DB & Storage 관리자 - 이두경
data "azuread_user" "db_admin" {
  user_principal_name = "student421@mscsschool.onmicrosoft.com"
}

# 5. Security 관리자 - 정현지
data "azuread_user" "security_admin" {
  user_principal_name = "student426@mscsschool.onmicrosoft.com"
}
