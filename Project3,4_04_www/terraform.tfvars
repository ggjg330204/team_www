subscription_id = "99b79efe-ebd6-468c-b39f-5669acb259e1"
db_password     = "It12345!"
ssh_allowed_ips = ["61.108.60.26", "211.252.127.132", "211.227.107.208"]
enable_ssl      = false
domain_name     = "04www.cloud"
sentinel_service_principal_id = "c4eede39-5c23-4ee7-88ed-5b6ae587e66d"
admin_emails = [
  "1234enrud@gmail.com",
  "gksk2453@naver.com",
  "hyhbit0527@gmail.com",
  "ggjg33@gmail.com",
  "andol2222@gmail.com"
]

azure_ad_tenant_domain = "mscsschool.onmicrosoft.com"

rbac_users = {
  "pm" = {
    account_name = "student421"
    role         = "PM"
    azure_role   = "Owner"
  }
  "arch_reviewer" = {
    account_name = "student424"
    role         = "Architect"
    azure_role   = "Reader"
  }
  "sec_external" = {
    account_name = "student411"
    role         = "External Security"
    azure_role   = "Microsoft Sentinel Contributor"
  }
  "sec_internal1" = {
    account_name = "student420"
    role         = "Internal Security"
    azure_role   = "Security Admin"
  }
  "sec_internal2" = {
    account_name = "student415"
    role         = "Internal Security"
    azure_role   = "Log Analytics Reader"
  }
}
