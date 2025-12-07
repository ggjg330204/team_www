resource "azurerm_management_lock" "db_lock" {
  name       = "mysql-delete-lock"
  scope      = var.db_id
  lock_level = "CanNotDelete"
  notes      = "Critical Production Database - Deletion Prevented"
}
