## it lists objectId, appId and displayName of Enterprise Apps register on an especific domain

Connect-AzureAD
$domain = "domain"
Get-AzureADApplication | Where-Object { $_.Homepage -like "*$domain*" -or $_.IdentifierUris -like "*$domain*" }

---------------------------------------------------------------------------------------------------------------------

## it gets all the Enterprise Applications and it's associate URLs
Connect-AzureAD
# gets all Enterprise Application
$applications = Get-AzureADServicePrincipal
# run then and show it's URLs 
foreach ($app in $applications) {
   # checks if the app got an Homepage, ReplyUrls or IdentifierUris
   $appUrls = @($app.Homepage, $app.ReplyUrls, $app.IdentifierUris)
   # shows all the Enterprise Applications and it's associate URLs
   Write-Host "Application: $($app.DisplayName)"
   foreach ($url in $appUrls) {
       if ($url) {
           Write-Host "URL: $url"
       }
   }
   Write-Host "---------------------------------------"
}
