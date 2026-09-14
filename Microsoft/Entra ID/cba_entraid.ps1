<#
.SYNOPSIS
Configura autenticação baseada em certificado para o Microsoft Entra Connect Sync.

.DESCRIPTION
Cria um certificado autoassinado, concede acesso à chave privada para a conta do serviço ADSync, associa o certificado ao registro de aplicação e demonstra o processo de rotação de credenciais.

.NOTES
Substitua os valores de administrador e DNS pelos valores do ambiente antes da execução. Execute com privilégios administrativos no servidor do Entra Connect Sync.
#>

# Define a conta administrativa utilizada para registrar a aplicação.
$admin = "admin@domain.com"

# Cria um certificado autoassinado para autenticação baseada em certificado.
$params = @{
    DnsName = "sub.domain.com"
    CertStoreLocation = "Cert:\LocalMachine\My"
    KeyAlgorithm = "RSA"
    KeyLength = 2048
    HashAlgorithm = "SHA256"
    NotAfter = (Get-Date).AddYears(1)
    KeyExportPolicy = "NonExportable"
}
$cert = New-SelfSignedCertificate @params

# Concede permissão de leitura da chave privada à conta do serviço ADSync.
$rsaCert = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($cert)
$path = "$env:ALLUSERSPROFILE\Microsoft\Crypto\Keys\$($rsaCert.key.UniqueName)"
$permissions = Get-Acl -Path $path
$serviceAccount = (Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\ADSync -Name ObjectName).ObjectName
$rule = New-Object Security.Accesscontrol.FileSystemAccessRule "$serviceAccount", "read", allow
$permissions.AddAccessRule($rule)
Set-Acl -Path $path -AclObject $permissions

# Valida as permissões aplicadas à chave privada.
$permissions = Get-Acl -Path $path
$permissions.Access

# Configura o Service Principal e o Entra Connect Sync para utilizar o certificado.
Set-ADSyncScheduler -SyncCycleEnabled $false
Add-EntraApplicationRegistration –UserPrincipalName $admin -CertificateThumbprint $cert.Thumbprint
Add-ADSyncApplicationRegistration –UserPrincipalName $admin -CertificateThumbprint $cert.Thumbprint

# Valida a credencial e reativa a sincronização.
Get-ADSyncEntraConnectorCredential
Set-ADSyncScheduler -SyncCycleEnabled $true

# ============================================================================
# ROTAÇÃO DE CERTIFICADO (ROLLOVER)
# ============================================================================

# Repete o processo com um novo certificado para realizar a rotação da credencial.
Set-ADSyncScheduler -SyncCycleEnabled $false

$params = @{
    DnsName = "sub.domain.com"
    CertStoreLocation = "Cert:\LocalMachine\My"
    KeyAlgorithm = "RSA"
    KeyLength = 2048
    HashAlgorithm = "SHA256"
    NotAfter = (Get-Date).AddYears(1)
    KeyExportPolicy = "NonExportable"
}
$cert = New-SelfSignedCertificate @params

# Concede acesso à nova chave privada para a conta do serviço ADSync.
$rsaCert = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($cert)
$path = "$env:ALLUSERSPROFILE\Microsoft\Crypto\Keys\$($rsaCert.key.UniqueName)"
$permissions = Get-Acl -Path $path
$serviceAccount = (Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\ADSync -Name ObjectName).ObjectName
$rule = New-Object Security.Accesscontrol.FileSystemAccessRule "$serviceAccount", "read", allow
$permissions.AddAccessRule($rule)
Set-Acl -Path $path -AclObject $permissions

# Executa a rotação da credencial da aplicação.
Invoke-ADSyncApplicationCredentialRotation –UserPrincipalName $admin -CertificateThumbprint $cert.Thumbprint
