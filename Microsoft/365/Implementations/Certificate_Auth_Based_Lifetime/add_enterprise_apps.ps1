# Instale o módulo do Graph

Install-Module Microsoft.Graph -Scope CurrentUser -Force
Import-Module Microsoft.Graph
Import-Module Microsoft.Graph.Groups

# Conecta ao Microsoft Graph com as permissões necessárias
Connect-MgGraph -Scopes "GroupMember.ReadWrite.All","Application.Read.All","Directory.Read.All"

# Define o ID do grupo (substitua pelo ObjectId do grupo que receberá os apps)
$groupId = "Groups-Object-ID"

# Busca todos os Enterprise Applications (Service Principals)
Write-Host "Coletando todos os Enterprise Applications..."
$servicePrincipals = Get-MgServicePrincipal -All
Write-Host "Total encontrado: $($servicePrincipals.Count)"

# Adiciona cada Service Principal ao grupo
foreach ($sp in $servicePrincipals) {
    try {
        # Monta o corpo da requisição com o link do objeto
        $body = @{
            "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($sp.Id)"
        }

        # Adiciona ao grupo
        New-MgGroupMemberByRef -GroupId $groupId -BodyParameter $body -ErrorAction Stop

        Write-Host "Adicionado: $($sp.DisplayName)"
    }
    catch {
        # Ignora erros de duplicação ou apps restritos
        if ($_.Exception.Message -match "One or more added object references already exist") {
            Write-Host "Já existe no grupo: $($sp.DisplayName)"
        }
        else {
            Write-Host "Falhou em adicionar $($sp.DisplayName): $($_.Exception.Message)"
        }
    }
}

Write-Host "Processo finalizado!"
