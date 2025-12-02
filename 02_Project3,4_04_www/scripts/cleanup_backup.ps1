# Recovery Vault 백업 항목 강제 삭제 스크립트
# 
# 사용법:
# .\cleanup_backup.ps1
#
# 이 스크립트는 terraform destroy 전에 실행하여 백업 항목을 미리 제거합니다.

param(
    [string]$ResourceGroupName = "04-t1-www-rg",
    [string]$VaultName = "www-recovery-vault"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Recovery Vault 백업 항목 정리 스크립트" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Azure에 로그인되어 있는지 확인
try {
    $context = Get-AzContext
    if (-not $context) {
        Write-Host "Azure에 로그인되어 있지 않습니다. 로그인을 시작합니다..." -ForegroundColor Yellow
        Connect-AzAccount
    } else {
        Write-Host "현재 구독: $($context.Subscription.Name)" -ForegroundColor Green
    }
} catch {
    Write-Host "Azure PowerShell 모듈이 설치되어 있지 않습니다." -ForegroundColor Red
    Write-Host "다음 명령어로 설치하세요: Install-Module -Name Az -AllowClobber -Scope CurrentUser" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "리소스 그룹: $ResourceGroupName" -ForegroundColor Cyan
Write-Host "Recovery Vault: $VaultName" -ForegroundColor Cyan
Write-Host ""

# Recovery Vault 존재 확인
try {
    $vault = Get-AzRecoveryServicesVault -ResourceGroupName $ResourceGroupName -Name $VaultName -ErrorAction Stop
    Write-Host "✓ Recovery Vault를 찾았습니다." -ForegroundColor Green
} catch {
    Write-Host "✗ Recovery Vault를 찾을 수 없습니다." -ForegroundColor Yellow
    Write-Host "  이미 삭제되었거나 존재하지 않습니다." -ForegroundColor Yellow
    exit 0
}

# Vault 컨텍스트 설정
Set-AzRecoveryServicesVaultContext -Vault $vault

# 백업 항목 조회
Write-Host ""
Write-Host "백업 항목을 조회 중..." -ForegroundColor Cyan

$backupItems = Get-AzRecoveryServicesBackupItem `
    -BackupManagementType AzureVM `
    -WorkloadType AzureVM `
    -VaultId $vault.ID

if ($backupItems.Count -eq 0) {
    Write-Host "✓ 백업 항목이 없습니다." -ForegroundColor Green
    Write-Host ""
    Write-Host "Recovery Vault를 안전하게 삭제할 수 있습니다." -ForegroundColor Green
    exit 0
}

Write-Host "발견된 백업 항목: $($backupItems.Count)개" -ForegroundColor Yellow
Write-Host ""

foreach ($item in $backupItems) {
    Write-Host "----------------------------------------" -ForegroundColor Gray
    Write-Host "VM 이름: $($item.Name)" -ForegroundColor White
    Write-Host "상태: $($item.ProtectionState)" -ForegroundColor White
    Write-Host "마지막 백업 시간: $($item.LastBackupTime)" -ForegroundColor White
    Write-Host ""
    
    # 백업 보호 비활성화 및 데이터 삭제
    Write-Host "백업 보호를 비활성화하고 데이터를 삭제 중..." -ForegroundColor Yellow
    
    try {
        Disable-AzRecoveryServicesBackupProtection `
            -Item $item `
            -VaultId $vault.ID `
            -RemoveRecoveryPoints `
            -Force `
            -ErrorAction Stop
        
        Write-Host "✓ 백업 항목 삭제 시작됨: $($item.Name)" -ForegroundColor Green
    } catch {
        Write-Host "✗ 백업 항목 삭제 실패: $($item.Name)" -ForegroundColor Red
        Write-Host "  오류: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "백업 항목 삭제가 시작되었습니다." -ForegroundColor Green
Write-Host "Azure에서 백업 데이터를 완전히 삭제하는데" -ForegroundColor Yellow
Write-Host "5-10분 정도 걸릴 수 있습니다." -ForegroundColor Yellow
Write-Host ""
Write-Host "잠시 기다린 후 terraform destroy를 실행하세요." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
