<#
.SYNOPSIS
Identifica objetos do Microsoft Entra ID a partir de seus GUIDs.

.DESCRIPTION
Lê uma lista de IDs de um arquivo TXT, consulta cada objeto no Microsoft Graph e identifica usuários, grupos, dispositivos e service principals. O resultado é exportado para CSV.

.NOTES
Informe um GUID por linha no arquivo de entrada. Ajuste os caminhos dos arquivos conforme o ambiente.
#>

# Instala e importa o Microsoft.Graph, se necessário.
Install-Module Microsoft.Graph -Scope CurrentUser -Force
Import-Module Microsoft.Graph

# Conecta ao Microsoft Graph.
Connect-MgGraph -Scopes Group.Read.All

# Arquivo TXT contendo um GUID por linha.
$ids = Get-Content "C:\Users\juliad.ribeiro\zanshin.txt"

$result = foreach ($id in $ids) {
    try {
        $obj = Get-MgDirectoryObject -DirectoryObjectId $id -ErrorAction Stop
        $type = $obj.AdditionalProperties.'@odata.type'

        switch ($type) {
            '#microsoft.graph.user' {
                $user = Get-MgUser -UserId $id
                [PSCustomObject]@{
                    Id = $id
                    Tipo = "User/Room/Shared Mailbox"
                    Nome = $user.DisplayName
                    Email = $user.Mail
                }
            }
            '#microsoft.graph.group' {
                $group = Get-MgGroup -GroupId $id
                $groupType = if ($group.GroupTypes -contains "Unified") {
                    "Microsoft 365 Group / Team"
                } elseif ($group.SecurityEnabled) {
                    "Security Group"
                } else {
                    "Distribution Group"
                }
                [PSCustomObject]@{
                    Id = $id
                    Tipo = $groupType
                    Nome = $group.DisplayName
                    Email = $group.Mail
                }
            }
            '#microsoft.graph.device' {
                $device = Get-MgDevice -DeviceId $id
                [PSCustomObject]@{
                    Id = $id
                    Tipo = "Device"
                    Nome = $device.DisplayName
                    Email = ""
                }
            }
            '#microsoft.graph.servicePrincipal' {
                $sp = Get-MgServicePrincipal -ServicePrincipalId $id
                [PSCustomObject]@{
                    Id = $id
                    Tipo = "Service Principal"
                    Nome = $sp.DisplayName
                    Email = ""
                }
            }
            default {
                [PSCustomObject]@{
                    Id = $id
                    Tipo = $type
                    Nome = "Objeto encontrado"
                    Email = ""
                }
            }
        }
    }
    catch {
        [PSCustomObject]@{
            Id = $id
            Tipo = "Não encontrado"
            Nome = ""
            Email = ""
        }
    }
}

# Exporta o resultado para CSV.
$result | Export-Csv "C:\Temp\objetos.csv" -NoTypeInformation -Encoding UTF8

Write-Host "Arquivo gerado em C:\Temp\objetos.csv"
