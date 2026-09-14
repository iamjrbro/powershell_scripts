# Instalar os módulos necessários. Se já tiver instalado, pode pular essa etapa

Install-Module PnP.PowerShell -Scope CurrentUser -Force #PNP PowerShell, para conectar no OneDrive do usuário e restaurar arquivos da lixeira
Import-Module PnP.PowerShell # importe o módulo PnP PowerShell para usar os cmdlets do PnP

Install-Module Microsoft.Graph -Scope CurrentUser -Force #módulo Microsoft Graph, para descobrir o tenant e o domínio do tenant

Get-MgOrganization | Select-Object Id, DisplayName


# descobrir o tenant .onmicrosoft.com. No PowerShell, rode:

Connect-MgGraph -Scopes "Organization.Read.All"



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


$TodosItens = @($Recycle1) + @($Recycle2)

Write-Host "Total de itens para restaurar: $($TodosItens.Count)" -ForegroundColor Cyan

$Log = foreach ($Item in $TodosItens) {

    try {

        Restore-PnPRecycleBinItem `
            -Identity $Item.Id `
            -Force `
            -ErrorAction Stop

        Write-Host "[OK] $($Item.LeafName)" -ForegroundColor Green

        [PSCustomObject]@{
            Status       = "RESTAURADO"
            Nome         = $Item.LeafName
            Caminho      = $Item.DirName
            DataExclusao = $Item.DeletedDate
            ExcluidoPor  = $Item.DeletedByName
            Erro         = ""
        }

    }
    catch {

        Write-Host "[ERRO] $($Item.LeafName) - $($_.Exception.Message)" -ForegroundColor Red

        [PSCustomObject]@{
            Status       = "ERRO"
            Nome         = $Item.LeafName
            Caminho      = $Item.DirName
            DataExclusao = $Item.DeletedDate
            ExcluidoPor  = $Item.DeletedByName
            Erro         = $_.Exception.Message
        }
    }
}

# verificar se os arquivos foram restaurados em ambas lixeira

$FirstAfter = Get-PnPRecycleBinItem -FirstStage
$SecondAfter = Get-PnPRecycleBinItem -SecondStage

"Primeira etapa agora: $($FirstAfter.Count)"
"Segunda etapa agora: $($SecondAfter.Count)"
"Total agora: $($FirstAfter.Count + $SecondAfter.Count)"