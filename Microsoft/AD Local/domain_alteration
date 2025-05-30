# instala os modulos do Exchange
Install-Module -Name ExchangeOnlineManagement
Connect-ExchangeOnline -UserPrincipalName "admin@seudominio.com" # conectando o Exchange Online - insira o administrador global aqui

# faça um CSV com os usuários cujos endereços precisam ser alterados, com o seguinte formato
UserPrincipalName
usuario1@seudominio.com
usuario2@seudominio.com

# define o caminho do arquivo CSV
$csvPath = "C:\Caminho\usuarios.csv"

# importa lista de usuários
$usuarios = Import-Csv -Path $csvPath

# loop para alterar SMTP
foreach ($usuario in $usuarios) {
    # Capturar informações do usuário
    $userPrincipalName = $usuario.UserPrincipalName
    $currentSMTP = $usuario.CurrentSMTP

    # obtem o endereço atual do usuário
    $user = Get-Mailbox -Identity $userPrincipalName

    # lista atual de endereços de e-mail do usuário
    $currentEmailAddresses = $mailbox.EmailAddresses
    $newEmailAddresses = @()

    # variáveis para domínios
    $currentDomain = "@dominioatual.com.br"
    $newDomain = "@dominionovo.com.br"

    # processar os endereços de e-mail
    foreach ($email in $currentEmailAddresses) {
        # se o e-mail atual for o principal e terminar com "@dominioatual.com.br"
        if ($email -clike "SMTP:*$currentDomain") {
            # alterar para secundário
            $newEmailAddresses += "smtp:" + ($email -replace "SMTP:", "")
        } else {
            # manter outros endereços inalterados
            $newEmailAddresses += $email
        }
    }

    # adicionar o novo endereço principal com o domínio "@dominionovo.com.br"
    $newPrimaryEmail = ($userPrincipalName -replace "$currentDomain", "$newDomain")
    $newEmailAddresses += "SMTP:$newPrimaryEmail"

    # atualizar os endereços no Exchange Online
    Set-Mailbox -Identity $userPrincipalName -EmailAddresses $newEmailAddresses

    Write-Host "Endereços de e-mail atualizados para o usuário: $userPrincipalName"
}

# desconectar do Exchange Online
Disconnect-ExchangeOnline -Confirm:$false
