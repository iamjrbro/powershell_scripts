# lista todos os usuários ativos do tipo 'Member' (exclui contas guest e desativadas).

#Identifica usuários que possuem gestor e aqueles que não têm.

#Mapeia gestores que possuem subordinados ativos.

#Coleta dados importantes como nome, UPN, departamento, status da conta e status de licença.

#Gera um arquivo Excel com várias abas para fácil análise:

Usuários com manager

Usuários sem manager

Managers com subordinados

Resumo gráfico e tabelas para insights rápidos

Como o script ajuda seu time?
- Disponibilizar essa ferramenta para seu time é garantir uma auditoria rápida, segura e prática, sem risco de alterar dados no ambiente.

- O arquivo é gerado localmente com timestamp para controle histórico.

====================================================================

Import-Module ImportExcel

Connect-AzureAD



$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"

$excelPath = "AuditoriaUsuarios_$timestamp.xlsx"



# Arrays para armazenar dados

$comManager = @()

$semManager = @()

$managersComSubordinados = @()



$usuarios = Get-AzureADUser -All $true | Where-Object {

    $_.UserType -eq 'Member' -and $_.AccountEnabled -eq $true -and $_.UserPrincipalName -notlike "*#EXT#*"

}



foreach ($user in $usuarios) {

    $manager = Get-AzureADUserManager -ObjectId $user.ObjectId -ErrorAction SilentlyContinue

    $licenciado = (Get-AzureADUserLicenseDetail -ObjectId $user.ObjectId -ErrorAction SilentlyContinue).Count -gt 0

    $statusLicenca = if ($licenciado) { "Licensed" } else { "Unlicensed" }

    $statusConta = if ($user.AccountEnabled) { "Active" } else { "Disabled" }



    if ($manager) {

        $comManager += [PSCustomObject]@{

            Nome            = $user.DisplayName

            UPN             = $user.UserPrincipalName

            Departamento    = $user.Department

            'Manager Nome'  = $manager.DisplayName

            'Manager UPN'   = $manager.UserPrincipalName

            'Status Conta'  = $statusConta

            'Status Licença'= $statusLicenca

        }

    } else {

        $semManager += [PSCustomObject]@{

            Nome            = $user.DisplayName

            UPN             = $user.UserPrincipalName

            Departamento    = $user.Department

            'Manager Nome'  = "N/A"

            'Manager UPN'   = "N/A"

            'Status Conta'  = $statusConta

            'Status Licença'= $statusLicenca

        }

    }



    $subordinados = Get-AzureADUserDirectReport -ObjectId $user.ObjectId -ErrorAction SilentlyContinue

    if ($subordinados.Count -gt 0) {

        $managersComSubordinados += [PSCustomObject]@{

            NomeManager        = $user.DisplayName

            UPNManager         = $user.UserPrincipalName

            Departamento       = $user.Department

            StatusConta        = $statusConta

            StatusLicenca      = $statusLicenca

            QtdSubordinados    = $subordinados.Count

            'Nomes Subordinados' = ($subordinados | Select-Object -ExpandProperty DisplayName) -join ", "

            'UPNs Subordinados'  = ($subordinados | Select-Object -ExpandProperty UserPrincipalName) -join ", "

        }

    }

}
