# script para auditoria de alterações em grupos do Azure AD com prefixo especificado

Install-Module Microsoft.Graph -Scope CurrentUser
Import-Module Microsoft.Graph.Reports

Connect-MgGraph -Scopes "AuditLog.Read.All", "Group.Read.All"


$Prefixo = "YOUR_GROUP_PREFIX"
$Inicio = (Get-Date).AddDays(-30).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$Fim = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

# Busca eventos de auditoria no período
$Logs = Get-MgAuditLogDirectoryAudit -All `
    -Filter "activityDateTime ge $Inicio and activityDateTime le $Fim"

# Mantém eventos que tenham como alvo um grupo com o prefixo informado
$Resultado = foreach ($Log in $Logs) {
    foreach ($Alvo in $Log.TargetResources) {
        if ($Alvo.Type -eq "Group" -and
            $Alvo.DisplayName -like "$Prefixo*") {

            [PSCustomObject]@{
                Data             = $Log.ActivityDateTime.ToLocalTime()
                Grupo            = $Alvo.DisplayName
                GrupoId          = $Alvo.Id
                Acao             = $Log.ActivityDisplayName
                Operacao         = $Log.OperationType
                Resultado        = $Log.Result
                Responsavel      = if ($Log.InitiatedBy.User) {
                    $Log.InitiatedBy.User.UserPrincipalName
                } else {
                    $Log.InitiatedBy.App.DisplayName
                }
                Propriedades     = (
                    $Alvo.ModifiedProperties | ForEach-Object {
                        "$($_.DisplayName): $($_.OldValue) -> $($_.NewValue)"
                    }
                ) -join " | "
            }
        }
    }
}

$Caminho = Join-Path $env:USERPROFILE "Desktop\Auditoria_YOUR_GROUP_PREFIX.csv"

$Resultado |
    Sort-Object Data -Descending |
    Export-Csv -Path $Caminho -NoTypeInformation -Encoding UTF8

Write-Host "Total de eventos: $($Resultado.Count)"
Write-Host "Arquivo salvo em: $Caminho"
