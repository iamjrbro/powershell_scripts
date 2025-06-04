# Conectar ao Microsoft Graph
Connect-MgGraph -Scopes "DeviceManagementConfiguration.Read.All", "DeviceManagementRBAC.Read.All"

# Função utilitária para checar se a política está atribuída
function Get-UnassignedPolicies {
    param (
        [string]$PolicyType,
        [string]$GraphEndpoint
    )

    Write-Host "`n🔍 Checando $PolicyType..."
    $policies = Invoke-MgGraphRequest -Method GET -Uri $GraphEndpoint
    foreach ($policy in $policies.value) {
        $assignments = Invoke-MgGraphRequest -Method GET -Uri "$GraphEndpoint/$($policy.id)/assignments"
        if (-not $assignments.value) {
            [PSCustomObject]@{
                Tipo        = $PolicyType
                Nome        = $policy.displayName
                ID          = $policy.id
            }
        }
    }
}

# Lista de políticas órfãs
$unassigned = @()

# Device Configuration Policies - perfis de configuraçõa
$unassigned += Get-UnassignedPolicies -PolicyType "Device Configuration" -GraphEndpoint "https://graph.microsoft.com/v1.0/deviceManagement/deviceConfigurations"

# Compliance Policies - politicas de conformidade
$unassigned += Get-UnassignedPolicies -PolicyType "Compliance" -GraphEndpoint "https://graph.microsoft.com/v1.0/deviceManagement/deviceCompliancePolicies"

# Endpoint Security (Antivirus, Disk Encryption, etc.)
$unassigned += Get-UnassignedPolicies -PolicyType "Endpoint Security (Antivirus)" -GraphEndpoint "https://graph.microsoft.com/beta/deviceManagement/endpointSecurityAntivirusPolicies"
$unassigned += Get-UnassignedPolicies -PolicyType "Endpoint Security (Disk Encryption)" -GraphEndpoint "https://graph.microsoft.com/beta/deviceManagement/endpointSecurityDiskEncryptionPolicies"

# Exibir resultados
if ($unassigned.Count -gt 0) {
    Write-Host "`n🟡 Políticas não atribuídas encontradas:"
    $unassigned | Format-Table Tipo, Nome, ID -AutoSize
} else {
    Write-Host "`n✅ Todas as políticas estão atribuídas a algum grupo."
}


	•	Esse script usa a versão beta do Graph para políticas de segurança de endpoint.
	•	Você pode adicionar mais endpoints, como:
	•	Device Enrollment Restrictions
	•	App Protection Policies
	•	App Configuration Policies
	•	Políticas “não atribuídas” podem ser políticas de teste ou esquecidas — boas candidatas para limpeza.
