resource "azurerm_resource_group_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations"
  resource_group_id    = var.rgid
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  parameters = jsonencode({
    listOfAllowedLocations = {
      value = [
        "koreacentral",
        "koreasouth"
      ]
    }
  })
  display_name = "Allowed Locations - Korea Only"
  description  = "정책은 리소스를 한국 리전(Central, South)에만 배포하도록 제한합니다."
}
resource "azurerm_resource_group_policy_assignment" "storage_https_only" {
  name                 = "storage-https-only"
  resource_group_id    = var.rgid
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9"
  display_name = "Storage Accounts - Secure transfer required"
  description  = "Storage Account는 HTTPS를 통해서만 액세스할 수 있어야 합니다."
}
resource "azurerm_resource_group_policy_assignment" "vm_managed_disk" {
  name                 = "vm-managed-disk"
  resource_group_id    = var.rgid
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d"
  display_name = "Audit VMs that do not use managed disks"
  description  = "정책은 관리 디스크를 사용하지 않는 VM을 감사합니다."
}
resource "azurerm_resource_group_policy_assignment" "subnet_nsg_required" {
  name                 = "subnet-nsg-required"
  resource_group_id    = var.rgid
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e71308d3-144b-4262-b144-efdc3cc90517"
  display_name = "Subnets should have a Network Security Group"
  description  = "정책은 NSG가 없는 서브넷을 감사합니다."
}
resource "azurerm_resource_group_policy_assignment" "require_tag" {
  name                 = "require-tag-env"
  resource_group_id    = var.rgid
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025"
  display_name = "Require a tag on resource groups"
  description  = "리소스 그룹은 특정 태그가 필요합니다."
  parameters = jsonencode({
    tagName = {
      value = "Environment"
    }
  })
}
