# Instalar uma única vez
Install-Module ExchangeOnlineManagement -Scope CurrentUser

Import-Module ExchangeOnlineManagement

# Entrar com sua conta administrativa
Connect-ExchangeOnline -UserPrincipalName "admin@empresa.com.br"

# Caixa que será consultada
$caixa = "user@domain.com"

# Consumo total da caixa
Get-EXOMailboxStatistics -Identity $caixa |
    Select-Object DisplayName, ItemCount, TotalItemSize, TotalDeletedItemSize |
    Format-List

# Consumo por pasta
$pastas = Get-EXOMailboxFolderStatistics -Identity $caixa

$relatorio = $pastas | Select-Object `
    FolderPath,
    ItemsInFolder,
    FolderSize,
    ItemsInFolderAndSubfolders,
    FolderAndSubfolderSize

$relatorio | Format-Table -AutoSize -Wrap

# Exportar CSV no diretório atual, para abrir no Excel
$relatorio | Export-Csv -Path ".\Consumo-Outlook.csv" `
    -NoTypeInformation -Encoding UTF8 -Delimiter ";"

Disconnect-ExchangeOnline -Confirm:$false