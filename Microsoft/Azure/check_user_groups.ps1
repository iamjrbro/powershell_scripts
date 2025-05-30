# Script to check which user is enable or disable on a group

# Group's name on Azure AD
$GroupName = "group_name"

# Getting groups ID
$Group = Get-AzureADGroup -SearchString $GroupName

# Getting group's users
$Users = Get-AzureADGroupMember -ObjectId $Group.ObjectId

# Creting an array to store data 
$UserData = @()

foreach ($User in $Users) {
    # Obter detalhes do usuário
    $UserDetails = Get-AzureADUser -ObjectId $User.ObjectId

    # Creating an object with the data
    $UserData += [PSCustomObject]@{
        "Name"         = $UserDetails.DisplayName
        "Email"        = $UserDetails.UserPrincipalName
        "Status"       = if ($UserDetails.AccountEnabled -eq $true) { "Habilitado" } else { "Desabilitado" }
    }
}

# Exporting to CSV
$UserData | Export-Csv -Path "C:\Users\Public\Users.csv" -NoTypeInformation -Encoding UTF8

