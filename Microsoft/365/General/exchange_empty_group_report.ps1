<#!
.SYNOPSIS
Gera um relatório de grupos do Microsoft Entra ID sem membros.

.DESCRIPTION
Conecta ao Microsoft Graph, consulta grupos do diretório e exporta os grupos
sem membros para um arquivo CSV.

.NOTES
Requer Microsoft Graph PowerShell SDK e permissões Group.Read.All e Directory.Read.All.
O caminho de saída pode ser alterado pela variável $OutputPath.
#>

$OutputPath = ".\EmptyGroups.csv"

Connect-MgGraph -Scopes "Group.Read.All", "Directory.Read.All"

Write-Host "Coletando grupos..." -ForegroundColor Cyan
$groups = Get-MgGroup -All -Property Id,DisplayName,GroupTypes

$emptyGroups = foreach ($group in $groups) {
    try {
        $members = Get-MgGroupMember -GroupId $group.Id -All -ErrorAction Stop

        if (-not $members) {
            [PSCustomObject]@{
                DisplayName = $group.DisplayName
                ObjectId    = $group.Id
                GroupTypes  = ($group.GroupTypes -join ',')
            }
        }
    }
    catch {
        Write-Warning "Não foi possível consultar os membros do grupo '$($group.DisplayName)': $($_.Exception.Message)"
    }
}

$emptyGroups | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8

Write-Host "Relatório exportado para: $OutputPath" -ForegroundColor Green
