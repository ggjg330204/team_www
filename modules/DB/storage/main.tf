resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "production"
    team        = "www"
  }
}

resource "azurerm_storage_container" "media" {
  name                  = "media"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "tfstate" {
  name               = "tfstate"
  storage_account_id = azurerm_storage_account.main.id
  # [PM 참고] 테라폼 상태 파일(.tfstate)을 저장하는 아주 중요한 금고입니다. 절대 공개하면 안 됩니다.
}

# 수명주기 관리 (Lifecycle Management) - 비용 절감
resource "azurerm_storage_management_policy" "main" {
  storage_account_id = azurerm_storage_account.main.id

  rule {
    name    = "cleanup-old-files"
    enabled = true
    filters {
      prefix_match = ["media/"] # media 컨테이너에만 적용
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 30  # 30일 지나면 싼 요금제(Cool)로 이동
        tier_to_archive_after_days_since_modification_greater_than = 90  # 90일 지나면 창고(Archive)로 이동
        delete_after_days_since_modification_greater_than          = 365 # 1년 지나면 삭제
      }
    }
  }
}

/*
### 학습 포인트 (Storage)
1. **azurerm_storage_account**: 파일을 저장하는 창고 건물입니다.
2. **azurerm_storage_container**: 창고 안의 방(폴더)입니다.
3. **LRS vs GRS**:
   - **LRS (Locally-redundant storage)**: 데이터 센터 하나 안에서 3번 복제. (싸다, 데이터 센터 불나면 끝)
   - **GRS (Geo-redundant storage)**: 멀리 떨어진 다른 리전에도 복제. (비싸다, 한국이 가라앉아도 데이터는 산다)
*/

/*
### 학습 포인트 (Storage Lifecycle)
- **azurerm_storage_management_policy**: 스토리지의 "자동 청소부"입니다.
- **tier_to_cool**: 자주 안 쓰는 데이터는 Cool Tier로 옮겨서 비용을 아낍니다.
- **delete**: 너무 오래된 데이터는 자동으로 지워서 용량을 확보합니다.

### 관련 문서 (Terraform Registry)
- **Storage Account**: [azurerm_storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)
- **Storage Container**: [azurerm_storage_container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container)
- **Storage Management Policy**: [azurerm_storage_management_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy)
*/
