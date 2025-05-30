# Instalar o módulo Microsoft.Graph, se não estiver instalado
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Install-Module Microsoft.Graph -Scope CurrentUser -Force
}

# Importar o módulo Microsoft.Graph
Import-Module Microsoft.Graph

# Conectar ao Microsoft Graph com autenticação interativa
Connect-MgGraph -Scopes "Group.Read.All"

# Função para verificar se um grupo está vazio
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

# Obter todos os grupos do tipo Unified
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

# Opcional: mostrar os resultados
$results | Format-Table -AutoSize
