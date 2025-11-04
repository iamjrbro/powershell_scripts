# Script: Inventário de Recursos e Conexão com o Sentinel
# Requisitos: Módulos Az.Accounts, Az.ResourceGraph, Az.OperationalInsights instalados e permissão de Reader no Workspace do Sentinel

# Instale o módulo AZ

Install-Module -Name Az -Repository PSGallery -Force

# 1. Login e assinatura
Connect-AzAccount
Select-AzSubscription -SubscriptionId "<ID_DA_ASSINATURA>"

# 2. Definir Workspace do Sentinel
$workspaceName = "<NOME_DO_WORKSPACE>"
$resourceGroupName = "<RESOURCE_GROUP_DO_WORKSPACE>"
$workspace = Get-AzOperationalInsightsWorkspace -Name $workspaceName -ResourceGroupName $resourceGroupName

# 3. Query no Azure Resource Graph (com paginação)
$query = "Resources | project name, type, resourceGroup, id"
$allResources = @()
$skip = 1
$pageSize = 1000

do {
    $result = Search-AzGraph -Query $query -First $pageSize -Skip $skip
    $allResources += $result
    $skip += $pageSize
} while ($result.Count -eq $pageSize)

Write-Host "Total de recursos encontrados:" $allResources.Count

# 4. Conferir diagnósticos para ver se estão conectados ao Sentinel
$diagnosticSettings = @()
foreach ($res in $allResources) {
    try {
        $diag = Get-AzDiagnosticSetting -ResourceId $res.id -ErrorAction SilentlyContinue
        if ($diag -and ($diag.WorkspaceId -eq $workspace.ResourceId)) {
            $diagnosticSettings += $res.id
        }
    } catch {
        # ignora erros de recursos sem suporte a diagnósticos
    }
}

# 5. Montar relatório final
$report = foreach ($res in $allResources) {
    [PSCustomObject]@{
        Nome                = $res.name
        Tipo                = $res.type
        ResourceGroup       = $res.resourceGroup
        ConectadoAoSentinel = if ($diagnosticSettings -contains $res.id) { "Sim" } else { "Não" }
    }
}

# 6. Exportar relatório para CSV
$report | Export-Csv -Path ".\Relatorio-Sentinel.csv" -NoTypeInformation -Encoding UTF8

Write-Host "Relatório gerado: Relatorio-Sentinel.csv"
