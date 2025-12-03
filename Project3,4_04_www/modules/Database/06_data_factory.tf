resource "azurerm_data_factory" "www_adf" {
  name                            = "www-adf-${random_string.adf_suffix.result}"
  location                        = var.loca
  resource_group_name             = var.rgname
  public_network_enabled          = true
  managed_virtual_network_enabled = true
  identity {
    type = "SystemAssigned"
  }
  tags = {
    purpose = "MySQL Backup Pipeline"
  }
}
resource "random_string" "adf_suffix" {
  length  = 4
  special = false
  upper   = false
}
resource "azurerm_data_factory_linked_custom_service" "mysql_source" {
  name            = "MySQLSource"
  data_factory_id = azurerm_data_factory.www_adf.id
  type            = "AzureMySql"
  type_properties_json = <<JSON
{
  "connectionString": "Server=${azurerm_mysql_flexible_server.www_mysql.fqdn};Port=3306;Database=${var.db_name};Uid=${var.db_user};Pwd=${var.db_password};SslMode=Required;"
}
JSON
  depends_on = [azurerm_mysql_flexible_server.www_mysql]
}
resource "azurerm_data_factory_linked_service_azure_blob_storage" "blob_dest" {
  name              = "BlobStorageDestination"
  data_factory_id   = azurerm_data_factory.www_adf.id
  connection_string = var.storage_connection_string
}
resource "azurerm_data_factory_pipeline" "mysql_backup" {
  name            = "MySQLDailyBackup"
  data_factory_id = azurerm_data_factory.www_adf.id
  description = "Daily MySQL backup to Blob Storage"
  activities_json = jsonencode([
    {
      name = "CopyMySQLToBlob"
      type = "Copy"
      inputs = [
        {
          referenceName = azurerm_data_factory_dataset_mysql.mysql_dataset.name
          type          = "DatasetReference"
        }
      ]
      outputs = [
        {
          referenceName = azurerm_data_factory_dataset_delimited_text.blob_dataset.name
          type          = "DatasetReference"
        }
      ]
      typeProperties = {
        source = {
          type  = "MySqlSource"
          query = "SELECT * FROM information_schema.tables"
        }
        sink = {
          type = "DelimitedTextSink"
        }
        enableStaging = false
      }
    }
  ])
}
resource "azurerm_data_factory_dataset_mysql" "mysql_dataset" {
  name                = "MySQLDataset"
  data_factory_id     = azurerm_data_factory.www_adf.id
  linked_service_name = azurerm_data_factory_linked_custom_service.mysql_source.name
}
resource "azurerm_data_factory_dataset_delimited_text" "blob_dataset" {
  name                = "BlobBackupDataset"
  data_factory_id     = azurerm_data_factory.www_adf.id
  linked_service_name = azurerm_data_factory_linked_service_azure_blob_storage.blob_dest.name
  azure_blob_storage_location {
    container = "mysql-backups"
    path      = ""
    filename  = "backup.csv"
  }
  column_delimiter    = ","
  row_delimiter       = "\n"
  encoding            = "UTF-8"
  quote_character     = "\""
  escape_character    = "\\"
  first_row_as_header = true
}
resource "azurerm_data_factory_trigger_schedule" "daily_backup_trigger" {
  name            = "DailyBackupTrigger"
  data_factory_id = azurerm_data_factory.www_adf.id
  pipeline_name   = azurerm_data_factory_pipeline.mysql_backup.name
  frequency  = "Day"
  interval   = 1
  start_time = "2025-11-25T02:00:00Z"
  schedule {
    hours   = [2]
    minutes = [0]
  }
}