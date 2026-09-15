# Lista App Registrations por domínio, exibindo ObjectId, AppId e DisplayName.

Connect-AzureAD
$domain = "domain"
Get-AzureADApplication | Where-Object { $_.Homepage -like "*$domain*" -or $_.IdentifierUris -like "*$domain*" }

# Lista Enterprise Applications e as URLs associadas.

Connect-AzureAD

# Obtém todas as Enterprise Applications (Service Principals).
$applications = Get-AzureADServicePrincipal

# Exibe Homepage, ReplyUrls e IdentifierUris de cada aplicação.
foreach ($app in $applications) {
   $appUrls = @($app.Homepage, $app.ReplyUrls, $app.IdentifierUris)
   Write-Host "Application: $($app.DisplayName)"
   foreach ($url in $appUrls) {
       if ($url) {
           Write-Host "URL: $url"
       }
   }
   Write-Host "---------------------------------------"
}
