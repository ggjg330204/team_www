# 코드 수정 리포트

## 개요
여러 명이 작성한 Terraform 코드를 통합하면서 발생한 모듈 간 의존성, 변수 불일치, 리소스 중복 문제들을 해결했습니다.

## 발견된 문제점

### 1. 모듈 간 경계 불명확
**문제**: Network 모듈과 Compute 모듈 양쪽에 VM 리소스가 중복 정의되어 있었습니다.
- `modules/Network/10_vm.tf` - VM 리소스 5개
- `modules/Compute/10_vm.tf` - VM 리소스 5개

VM은 Compute의 책임이지만, Compute 모듈의 VM들이 Network 모듈에 정의된 NIC를 직접 참조하여 모듈 경계를 위반했습니다.

**해결**:
- Network 모듈에서 `10_vm.tf` 파일 삭제
- VM은 Compute 모듈에서만 관리

### 2. Compute 모듈 변수 파일 누락
**문제**: `modules/Compute/` 디렉토리에 변수 정의 파일이 전혀 없었습니다.
- `main.tf`에서 12개의 변수를 전달했지만 받을 곳이 없었음

**해결**:
- `modules/Compute/100_var.tf` 파일 생성
- 모든 필요한 변수 정의 추가 (rgname, loca, teamuser, subid, vnet-*, nic_id)

### 3. Compute 모듈의 모듈 경계 위반
**문제**: Compute 모듈이 Network 모듈의 리소스를 직접 참조했습니다.
```hcl
network_interface_ids = [azurerm_network_interface.www_bas_nic.id]
```

**해결**:
- NIC ID를 변수로 받도록 수정
```hcl
network_interface_ids = [var.nic_id["bas_nic"]]
```

### 4. Network 모듈 출력 누락
**문제**: `modules/Network/99_out.tf`에 `bas_pub_ip` 하나만 정의되어 있었습니다.
- 다른 모듈들이 필요로 하는 `rg_name`, `subnet_id`, `nic_id`, `vnet_id` 등이 없었음

**해결**: Network 모듈 출력 보완
- `rg_name` - Resource Group 이름
- `vnet_id` - 메인 VNet ID (vnet0)
- `vnet_south_id` - South VNet ID (vnet1)
- `db_subnet_id` - Database 서브넷 ID
- `storage_subnet_id` - Storage 서브넷 ID
- `nic_id` - NIC ID 맵 (6개 NIC)

### 5. Storage 모듈 변수 누락
**문제**: `main.tf`에서 Storage 모듈에 필수 변수를 전달하지 않았습니다.
- Private Endpoint와 Private DNS Zone에 필요한 `vnet_id`, `storage_subnet_id` 누락

**해결**: `main.tf`의 storage 모듈 호출 수정
```hcl
module "storage" {
  source = "./modules/Storage"
  
  rgname            = module.network.rg_name
  loca              = var.location
  storage_subnet_id = module.network.storage_subnet_id  # 추가
  vnet_id           = module.network.vnet_id            # 추가
}
```

### 6. Database 모듈 변수 누락
**문제**: Database 모듈에 필수 변수가 전달되지 않았습니다.
- `vnet_id`, `vnet_south_id`, `storage_connection_string` 누락
- `db_subnet_id` 참조 오류 (`subnet_id` → `db_subnet_id`)

**해결**: `main.tf`의 db 모듈 호출 수정
```hcl
module "db" {
  source = "./modules/Database"
  
  rgname                    = module.network.rg_name
  loca                      = var.location
  db_subnet_id              = module.network.db_subnet_id  # 수정
  db_password               = var.db_password
  vnet_id                   = module.network.vnet_id           # 추가
  vnet_south_id             = module.network.vnet_south_id     # 추가
  storage_connection_string = module.storage.storage_connection_string  # 추가
}
```

### 7. 순환 참조 문제
**문제**: Database 모듈이 `mysql_fqdn` 변수로 외부에서 값을 받도록 설계되었으나, 이는 자체 MySQL 서버의 FQDN이어야 했습니다.

**해결**:
- `modules/Database/100_var.tf`에서 `mysql_fqdn` 변수 제거
- `modules/Database/07_adf.tf`에서 내부 리소스 직접 참조로 변경
```hcl
connection_string = "Server=${azurerm_mysql_flexible_server.www_mysql.fqdn};..."
```

### 8. 모듈 경로 대소문자 불일치
**문제**: `main.tf`에서 모듈 경로가 소문자로 되어 있었으나, 실제 디렉토리는 대문자였습니다.
- `./modules/storage` vs `modules/Storage/`
- `./modules/database` vs `modules/Database/`

Linux 환경에서 오류 발생 가능성이 있었습니다.

**해결**: 실제 디렉토리명에 맞춰 수정
```hcl
source = "./modules/Storage"
source = "./modules/Database"
```

## 수정 내용 요약

### 삭제된 파일
- `modules/Network/10_vm.tf` - VM 리소스는 Compute 모듈에서만 관리

### 생성된 파일
- `modules/Compute/100_var.tf` - Compute 모듈 변수 정의

### 수정된 파일
1. **modules/Compute/10_vm.tf**
   - NIC 직접 참조 → 변수로 변경 (5개 VM)

2. **modules/Network/99_out.tf**
   - 6개 출력 추가 (rg_name, vnet_id, vnet_south_id, db_subnet_id, storage_subnet_id, nic_id)

3. **main.tf**
   - Storage 모듈: 2개 변수 추가
   - Database 모듈: 3개 변수 추가, 1개 변수명 수정
   - 모듈 경로 대소문자 통일

4. **modules/Database/100_var.tf**
   - `mysql_fqdn` 변수 제거

5. **modules/Database/07_adf.tf**
   - MySQL FQDN을 내부 리소스로 참조하도록 변경

## 모듈 의존성 관계 (수정 후)

```
Network (기반)
├─ Compute (NIC ID 사용)
├─ Storage (vnet_id, storage_subnet_id 사용)
└─ Database (vnet_id, vnet_south_id, db_subnet_id 사용)
       └─ Storage connection string 사용
```

## 검증 필요 사항

1. **Terraform 초기화**
   ```bash
   terraform init -upgrade
   ```

2. **구문 검증**
   ```bash
   terraform validate
   ```

3. **계획 확인**
   ```bash
   terraform plan
   ```

## 남은 주의사항

1. **파일 경로**: Compute 모듈의 VM들이 상대 경로로 파일을 참조하고 있습니다.
   ```hcl
   public_key = file("./id_ed25519.pub")
   user_data  = base64encode(file("web.sh"))
   ```
   실행 위치에 따라 파일을 찾지 못할 수 있으므로 `${path.root}/` 또는 `${path.module}/`  사용을 권장합니다.

2. **Security 모듈**: 아직 main.tf에서 호출되지 않고 있습니다. 필요시 추가 작업이 필요합니다.

3. **loca1 변수**: Network 모듈에 정의되어 있으나 사용되지 않습니다. 하드코딩된 "KoreaSouth" 대신 이 변수를 사용하거나 제거하는 것을 권장합니다.
