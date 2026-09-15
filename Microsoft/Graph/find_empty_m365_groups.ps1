<#
.SYNOPSIS
Identifica grupos Microsoft 365 (Unified) sem membros.

.DESCRIPTION
Instala/importa o Microsoft Graph PowerShell SDK quando necessário, consulta grupos do tipo Unified e exibe quais estão vazios.

.PREREQUISITES
Requer Microsoft Graph PowerShell SDK e permissão Group.Read.All.
#>

# Instala o módulo Microsoft.Graph caso ainda não esteja disponível.
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Install-Module Microsoft.Graph -Scope CurrentUser -Force
}

# Importa o módulo Microsoft.Graph.
Import-Module Microsoft.Graph

# Conecta ao Microsoft Graph com autenticação interativa.
Connect-MgGraph -Scopes "Group.Read.All"

# Verifica se um grupo está vazio.
function Check-GroupEmpty {
    param (
        [Parameter(Mandatory = $true)]
        [string]$GroupId
    )
    $members = Get-MgGroupMember -GroupId $GroupId -All
    if ($members.Count -eq 0) {
        return "Vazio"
    } else {
        return "Não Vazio"
    }
}

# Obtém todos os grupos do tipo Unified (Microsoft 365 Groups).
$groups = Get-MgGroup -Filter "groupTypes/any(c:c eq 'Unified')" -All

$results = @()

foreach ($group in $groups) {
    Write-Output "Verificando grupo: $($group.DisplayName)"
    $status = Check-GroupEmpty -GroupId $group.Id
    $groupResult = [PSCustomObject]@{
        "Nome do Grupo" = $group.DisplayName
        "ID do Grupo"   = $group.Id
        "Status"        = $status
    }
    $results += $groupResult
}

# Exibe os resultados.
$results | Format-Table -AutoSize
