# 1. 메인 데이터베이스 서버 (Master)
resource "azurerm_mysql_flexible_server" "main" {
  name                   = "www-mysql-server"
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = "adminuser"
  administrator_password = var.db_password
  sku_name               = "B_Standard_B2s"
  version                = "8.0.21"
  
  # 백업 보관 기간 설정 (일 단위)
  backup_retention_days  = 7 
}

# 2. 데이터베이스 생성
resource "azurerm_mysql_flexible_database" "main" {
  name                = var.db_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = "utf8"
  collation           = "utf8_general_ci"
}

# 3. 읽기 전용 복제본 (Read Replica) - 타 리전 백업용
resource "azurerm_mysql_flexible_server" "replica" {
  name                   = "www-mysql-replica"
  resource_group_name    = var.resource_group_name
  location               = var.replica_location
  sku_name               = "B_Standard_B2s"
  version                = "8.0.21"
  
  # Replica 설정의 핵심
  create_mode            = "Replica"
  source_server_id       = azurerm_mysql_flexible_server.main.id
  
  # Replica는 Master의 계정 정보를 따라가므로 admin 설정을 따로 하지 않습니다.
}

# 5. 보안 설정 (Server Parameters) - 감사 로그 활성화
resource "azurerm_mysql_flexible_server_configuration" "audit" {
  name                = "audit_log_enabled"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  value               = "ON"
}

resource "azurerm_mysql_flexible_server_configuration" "audit_events" {
  name                = "audit_log_events"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  value               = "CONNECTION,DDL,DML_SELECT" # 접속, 테이블 변경, 조회 기록 저장
}

# 6. 보안 연결 (Private Endpoint) - 메인 DB용
resource "azurerm_private_endpoint" "main" {
  name                = "www-mysql-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.db_subnet_id

  private_service_connection {
    name                           = "www-mysql-privatelink"
    private_connection_resource_id = azurerm_mysql_flexible_server.main.id
    is_manual_connection           = false
    subresource_names              = ["mysqlServer"]
  }
}

/*
### 학습 포인트 (Main Resources)
1. **resource "타입" "이름"**: 테라폼에서 실제로 무언가를 만들라는 명령어입니다.
   - `azurerm_mysql_flexible_server`: Azure의 MySQL 서비스를 만듭니다.
   - `azurerm_private_endpoint`: DB를 외부 인터넷이 아닌, 우리만의 사설망(VNet)에 숨겨주는 보안 터널입니다.

2. **참조 (Reference)**: 
   - `var.location`: 변수 파일에서 정의한 값을 가져옵니다.
   - `azurerm_mysql_flexible_server.main.id`: 위에서 만든 메인 DB의 ID를 가져옵니다. (리소스 간 연결)

3. **Replica (복제본)**:
   - `create_mode = "Replica"`: 이 서버는 새것이 아니라, 다른 서버(Master)를 복제해서 만든다는 뜻입니다.
   - `source_server_id`: 누구를 복제할지 지정합니다.
   - 이렇게 하면 Master에 데이터가 쌓일 때마다 자동으로 Replica에도 똑같이 쌓입니다. (재해 복구용)
*/
