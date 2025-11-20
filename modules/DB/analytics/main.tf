resource "azurerm_data_factory" "main" {
  name                = var.data_factory_name
  location            = var.location
  resource_group_name = var.resource_group_name

  # Public Network Access를 끄고 Private Endpoint를 쓰는 것이 보안상 좋지만,
  # 실습 편의를 위해 기본값(Enabled)을 유지하거나 필요 시 끕니다.
  public_network_enabled = true

  identity {
    type = "SystemAssigned"
  }
}

/*
### 학습 포인트 (Data Factory)
- **azurerm_data_factory**: 데이터 이동과 변환을 담당하는 공장입니다.
- **ETL (Extract, Transform, Load)**: 데이터를 추출하고, 변환하고, 적재하는 과정을 자동화합니다.
- **Identity**: 이 공장(리소스)에게 신분증을 줍니다. 이 신분증으로 DB나 스토리지에 접근 권한을 얻습니다.

### 관련 문서 (Terraform Registry)
- **Data Factory**: [azurerm_data_factory](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory)
*/
