<#
.SYNOPSIS
Identifica políticas do Intune que não possuem atribuições.

.DESCRIPTION
Consulta políticas de configuração, conformidade e Endpoint Security no Microsoft Graph e retorna aquelas que não possuem assignments.

.NOTES
Alguns endpoints de Endpoint Security utilizam Microsoft Graph beta. Políticas não atribuídas podem ser intencionais; valide o uso antes de removê-las.
#>

# Conecta ao Microsoft Graph com as permissões necessárias.
Connect-MgGraph -Scopes "DeviceManagementConfiguration.Read.All", "DeviceManagementRBAC.Read.All"

# Função utilitária para identificar políticas sem atribuições.
function Get-UnassignedPolicies {
    param (
        [string]$PolicyType,
        [string]$GraphEndpoint
    )

    Write-Host "`nVerificando $PolicyType..."
    $policies = Invoke-MgGraphRequest -Method GET -Uri $GraphEndpoint
    foreach ($policy in $policies.value) {
        $assignments = Invoke-MgGraphRequest -Method GET -Uri "$GraphEndpoint/$($policy.id)/assignments"
        if (-not $assignments.value) {
            [PSCustomObject]@{
                Tipo = $PolicyType
                Nome = $policy.displayName
                ID = $policy.id
            }
        }
    }
}

# Inicializa a lista de políticas sem atribuição.
$unassigned = @()

# Device Configuration Policies — perfis de configuração.
$unassigned += Get-UnassignedPolicies -PolicyType "Device Configuration" -GraphEndpoint "https://graph.microsoft.com/v1.0/deviceManagement/deviceConfigurations"

# Compliance Policies — políticas de conformidade.
$unassigned += Get-UnassignedPolicies -PolicyType "Compliance" -GraphEndpoint "https://graph.microsoft.com/v1.0/deviceManagement/deviceCompliancePolicies"

# Endpoint Security — políticas de Antivirus e Disk Encryption.
$unassigned += Get-UnassignedPolicies -PolicyType "Endpoint Security (Antivirus)" -GraphEndpoint "https://graph.microsoft.com/beta/deviceManagement/endpointSecurityAntivirusPolicies"
$unassigned += Get-UnassignedPolicies -PolicyType "Endpoint Security (Disk Encryption)" -GraphEndpoint "https://graph.microsoft.com/beta/deviceManagement/endpointSecurityDiskEncryptionPolicies"

# Exibe os resultados.
if ($unassigned.Count -gt 0) {
    Write-Host "`nPolíticas não atribuídas encontradas:"
    $unassigned | Format-Table Tipo, Nome, ID -AutoSize
} else {
    Write-Host "`nTodas as políticas consultadas possuem alguma atribuição."
}

# Possíveis extensões: Device Enrollment Restrictions, App Protection Policies e App Configuration Policies.
