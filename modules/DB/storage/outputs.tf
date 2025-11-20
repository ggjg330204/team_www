output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "primary_access_key" {
  description = "The primary access key for the storage account"
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}

/*
### 학습 포인트 (Outputs & Security)
- **sensitive = true**: 테라폼이 화면에 출력할 때 값을 `(sensitive value)`라고 가려줍니다.
- 하지만 `terraform.tfstate` 파일 열어보면 다 보입니다. 그래서 State 파일 관리가 보안의 핵심입니다.
*/
