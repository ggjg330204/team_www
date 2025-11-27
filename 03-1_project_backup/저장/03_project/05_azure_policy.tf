resource "azurerm_resource_group_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations"
  resource_group_id    = azurerm_resource_group.www_rg.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = [
        "koreacentral",
        "koreasouth"
      ]
    }
  })

  display_name = "허용된 리전 - 한국만 허용"
  description  = "이 정책은 리소스를 한국 리전(Central, South)에만 배포하도록 제한합니다."
}

resource "azurerm_resource_group_policy_assignment" "storage_https_only" {
  name                 = "storage-https-only"
  resource_group_id    = azurerm_resource_group.www_rg.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9"

  display_name = "Storage Account - 보안 전송(HTTPS) 필수"
  description  = "Storage Account에 HTTPS를 통해서만 액세스할 수 있도록 강제합니다."
}

resource "azurerm_resource_group_policy_assignment" "vm_managed_disk" {
  name                 = "vm-managed-disk"
  resource_group_id    = azurerm_resource_group.www_rg.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d"

  display_name = "Managed Disk를 사용하지 않는 VM 감사"
  description  = "이 정책은 관리 디스크(Managed Disk)를 사용하지 않는 VM을 감사합니다."
}

resource "azurerm_resource_group_policy_assignment" "subnet_nsg_required" {
  name                 = "subnet-nsg-required"
  resource_group_id    = azurerm_resource_group.www_rg.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e71308d3-144b-4262-b144-efdc3cc90517"

  display_name = "서브넷에 NSG 필수 적용"
  description  = "이 정책은 NSG(네트워크 보안 그룹)가 연결되지 않은 서브넷을 감사합니다."
}
