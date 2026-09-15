# Conectar ao Microsoft Graph
Connect-MgGraph -Scopes "Application.Read.All"

# Buscar todas as App Registrations
$apps = Get-MgApplication -All

# Exibir nome e ID no console
$apps | Select-Object DisplayName, AppId, Id, PublisherDomain, CreatedDateTime | Format-Table

# (Opcional) Exportar para CSV
$apps | Select-Object DisplayName, AppId, Id, PublisherDomain, CreatedDateTime `
| Export-Csv -Path "C:\AppRegistrations.csv" -NoTypeInformation -Encoding UTF8

# Se quiser ver apenas os apps que usam certificados, você pode filtrar assim:

$apps | Where-Object { $_.KeyCredentials.Count -gt 0 } | 
Select-Object DisplayName, AppId, @{Name='CertCount';Expression={$_.KeyCredentials.Count}}
