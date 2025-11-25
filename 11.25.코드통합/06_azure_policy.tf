resource "azurerm_resource_group_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations"
  resource_group_id    = module.network.rg_id
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
  description  = "???뺤콉? 由ъ냼?ㅻ? ?쒓뎅 由ъ쟾(Central, South)?먮쭔 諛고룷?섎룄濡??쒗븳?⑸땲??"
}

resource "azurerm_resource_group_policy_assignment" "storage_https_only" {
  name                 = "storage-https-only"
  resource_group_id    = module.network.rg_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9"

  display_name = "Storage Accounts - Secure transfer required"
  description  = "Storage Account??HTTPS瑜??듯빐?쒕쭔 ?≪꽭?ㅽ븷 ???덉뼱???⑸땲??"
}

resource "azurerm_resource_group_policy_assignment" "vm_managed_disk" {
  name                 = "vm-managed-disk"
  resource_group_id    = module.network.rg_name
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d"

  display_name = "Audit VMs that do not use managed disks"
  description  = "???뺤콉? 愿由??붿뒪?щ? ?ъ슜?섏? ?딅뒗 VM??媛먯궗?⑸땲??"
}

resource "azurerm_resource_group_policy_assignment" "subnet_nsg_required" {
  name                 = "subnet-nsg-required"
  resource_group_id    = module.network.rg_name
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e71308d3-144b-4262-b144-efdc3cc90517"

  display_name = "Subnets should have a Network Security Group"
  description  = "???뺤콉? NSG媛 ?녿뒗 ?쒕툕?룹쓣 媛먯궗?⑸땲??"
}
