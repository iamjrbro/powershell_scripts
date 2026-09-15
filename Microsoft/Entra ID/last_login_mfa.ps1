# Instalar módulo (caso necessário)

Install-Module Microsoft.Graph -Scope CurrentUser

Import-Module Microsoft.Graph.Authentication

Connect-MgGraph -Scopes `
"User.Read.All",
"Group.Read.All",
"AuditLog.Read.All",
"UserAuthenticationMethod.Read.All"

$groupName = "ENTRAID_GROUP_NAME"

# Localiza o grupo
$group = Invoke-MgGraphRequest `
    -Method GET `
    -Uri "https://graph.microsoft.com/v1.0/groups?`$filter=displayName eq '$groupName'"

if(!$group.value){
    Write-Host "Grupo não encontrado."
    return
}

$groupId = $group.value[0].id

# Obtém todos os membros (com paginação)
$members = @()

$uri = "https://graph.microsoft.com/v1.0/groups/$groupId/members?`$select=id,displayName,userPrincipalName"

do{

    $page = Invoke-MgGraphRequest `
        -Method GET `
        -Uri $uri

    $members += $page.value

    $uri = $page.'@odata.nextLink'

}while($uri)


# Consulta cada usuário
$result = foreach($member in $members){

    if($member.'@odata.type' -ne "#microsoft.graph.user"){
        continue
    }

    Write-Host "Consultando $($member.displayName)..."

    $user = Invoke-MgGraphRequest `
        -Method GET `
        -Uri "https://graph.microsoft.com/beta/users/$($member.id)?`$select=displayName,userPrincipalName,accountEnabled,signInActivity"

    $methods = Invoke-MgGraphRequest `
        -Method GET `
        -Uri "https://graph.microsoft.com/v1.0/users/$($member.id)/authentication/methods"

    $realMethods = @(
        $methods.value |
        Where-Object{
            $_.'@odata.type' -notmatch 'passwordAuthenticationMethod'
        }
    )

    [PSCustomObject]@{

        Nome = $user.displayName

        UPN = $user.userPrincipalName

        Habilitada = $user.accountEnabled

        UltimoLogin =
            $user.signInActivity.lastSignInDateTime

        PossuiMetodoAutenticacao =
            if($realMethods.Count -gt 0){"Sim"}else{"Não"}

        QuantidadeMetodos =
            $realMethods.Count

        Metodos =
            ($realMethods.'@odata.type' |
                ForEach-Object{
                    $_.Split('.')[-1]
                }) -join ", "
    }
}


# Exibe
$result |
Sort Nome |
Format-Table -AutoSize


# Exporta
$result |
Export-Csv "C:\Temp\UsuariosGrupo.csv" `
-NoTypeInformation `
-Encoding UTF8

Write-Host ""
Write-Host "CSV C:\Temp\UsuariosGrupo.csv"