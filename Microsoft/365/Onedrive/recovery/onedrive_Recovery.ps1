
# descobrir o tenant .onmicrosoft.com. No PowerShell, rode:

Connect-MgGraph -Scopes "Organization.Read.All"

# se não tiver o módulo

Install-Module Microsoft.Graph -Scope CurrentUser -Force

Get-MgOrganization | Select-Object Id, DisplayName


# Para descobrir o domínio:

(Get-MgOrganization).VerifiedDomains |
    Select-Object Name, IsDefault

# Criar o App Registration pelo próprio PowerShell. Esse comando cria o App Registration necessário para o Connect-PnPOnline. (PNP GitHub), o qual deverá abrir uma autenticação para você
# Importante: sua conta precisa ter permissão para criar App Registrations no Entra ID. Se a empresa bloqueia usuários de criarem aplicações, esse passo vai falhar.

Register-PnPEntraIDAppForInteractiveLogin `
    -ApplicationName "PnP-OneDrive-Recovery" `
    -Tenant "DOMÍNIO_DO_SEU_TENANT"

# Depois descubra o Client ID criado

Get-PnPEntraIDApp


# Se esse cmdlet não estiver disponível na sua versão, use o Microsoft Graph:

Get-MgApplication -Filter "displayName eq 'PnP-OneDrive-Recovery'" |
    Select-Object DisplayName, AppId, Id


# Vai aparecer algo como abaixo. Esse AppId é o Client ID.

DisplayName              AppId
-----------              -----
PnP-OneDrive-Recovery    xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx


# Conectar no OneDrive do user. Vai abrir a autenticação Microsoft, Faça login com a sua conta administrativa

$ClientId = "COLE-O-APP-ID-AQUI"

Connect-PnPOnline `
    -Url "URL_DO_ONE_DRIVE" `
    -Interactive `
    -ClientId $ClientId

# Testar se realmente conectou

Get-PnPWeb | Select-Object Title, Url


Se retornar algo como abaixo, deu certo

Title       Url
-----       ---
OneDrive    https://sistemaseb-my.sharepoint.com/personal/...


#  Primeiro vamos descobrir se os arquivos estão na lixeira

$Recycle1 = Get-PnPRecycleBinItem -FirstStage

$Recycle1 |
    Select-Object LeafName, DirName, DeletedDate, DeletedByName, ItemState |
    Format-Table -AutoSize



$Recycle2 = Get-PnPRecycleBinItem -SecondStage

$Recycle2 |
    Select-Object LeafName, DirName, DeletedDate, DeletedByName, ItemState |
    Format-Table -AutoSize


# Ver quantos arquivos encontramos

"Primeira etapa: $($Recycle1.Count)"
"Segunda etapa: $($Recycle2.Count)"
"Total: $($Recycle1.Count + $Recycle2.Count)"


# Veja quem excluiu

$Recycle2 |
    Group-Object DeletedByName |
    Sort-Object Count -Descending |
    Select-Object Name, Count
```

### 5. Veja as pastas afetadas

$Recycle2 |
    Group-Object DirName |
    Sort-Object Count -Descending |
    Select-Object -First 30 Name, Count

# restaurar os arquivos da lixeira. Se quiser restaurar apenas alguns arquivos, filtre o $Recycle2 antes do foreach.


$Log = @()

foreach ($Item in $Recycle2) {

    try {
        Restore-PnPRecycleBinItem -Identity $Item.Id -Force -ErrorAction Stop

        $Log += [PSCustomObject]@{
            Status       = "RESTAURADO"
            Nome         = $Item.LeafName
            Caminho      = $Item.DirName
            DataExclusao = $Item.DeletedDate
            ExcluidoPor  = $Item.DeletedByName
            Erro         = ""
        }

        Write-Host "[OK] $($Item.LeafName)"
    }
    catch {

        $Log += [PSCustomObject]@{
            Status       = "ERRO"
            Nome         = $Item.LeafName
            Caminho      = $Item.DirName
            DataExclusao = $Item.DeletedDate
            ExcluidoPor  = $Item.DeletedByName
            Erro         = $_.Exception.Message
        }

        Write-Host "[ERRO] $($Item.LeafName) - $($_.Exception.Message)" -ForegroundColor Red
    }
}
