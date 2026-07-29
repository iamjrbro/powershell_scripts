Connect-MgGraph -Scopes "Application.Read.All"

Get-MgApplication -All |
Where-Object {
    $_.SignInAudience -eq "AzureADMultipleOrgs"
} |
Select-Object DisplayName, AppId