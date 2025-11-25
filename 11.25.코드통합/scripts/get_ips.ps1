# 리소스 그룹 이름 설정
$rg = "04-t1-www-rg"

Write-Host "=== 공인 IP (Public IPs) ===" -ForegroundColor Cyan
# 로드밸런서, Bastion 등의 공인 IP 조회
az network public-ip list --resource-group $rg --query "[].{Name:name, IP:ipAddress}" --output table

Write-Host "`n=== VMSS 내부 IP (VMSS Internal IPs) ===" -ForegroundColor Cyan
# VMSS 인스턴스의 내부 IP 조회 (ipConfigurations 배열 접근 수정됨)
az vmss nic list --resource-group $rg --vmss-name my-vmss --query "[].{InstanceId: virtualMachine.id, PrivateIP: ipConfigurations[0].privateIpAddress}" --output table

Write-Host "`n=== Private Endpoint IP (DB & Storage) ===" -ForegroundColor Cyan
# Private Endpoint는 Private DNS Zone을 사용하는 경우 customDnsConfigs가 비어있을 수 있습니다.
# 따라서 Private Endpoint에 연결된 Network Interface ID를 먼저 조회한 후,
# 해당 NIC의 정보를 다시 조회하여 IP를 가져오는 방식을 사용합니다.

# 1. Private Endpoint 목록 및 NIC ID 조회
$pes = az network private-endpoint list --resource-group $rg --query "[].{Name:name, NicId:networkInterfaces[0].id}" -o json | ConvertFrom-Json

foreach ($pe in $pes) {
    if ($pe.NicId) {
        # 2. NIC ID를 통해 Private IP 조회
        $nic = az network nic show --ids $pe.NicId --query "{PrivateIP:ipConfigurations[0].privateIpAddress}" -o json | ConvertFrom-Json
        [PSCustomObject]@{
            Name = $pe.Name
            PrivateIP = $nic.PrivateIP
        } | Format-Table -AutoSize
    }
}

Write-Host "`n=== 웹 서버(Web VM) 내부 IP ===" -ForegroundColor Cyan
# 단일 Web VM의 내부 IP 조회
az network nic list --resource-group $rg --query "[?contains(name, 'webvm')].{Name:name, PrivateIP:ipConfigurations[0].privateIpAddress}" --output table
