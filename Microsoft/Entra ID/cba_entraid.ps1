# define the admin 

$admin = "admin@domain.com"

# create self signed certificate
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

# conceive permission to the service on ADSync

$rsaCert = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($cert)
$path = "$env:ALLUSERSPROFILE\Microsoft\Crypto\Keys\$($rsaCert.key.UniqueName)"
$permissions = Get-Acl -Path $path
$serviceAccount = (Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\ADSync -Name ObjectName).ObjectName
$rule = New-Object Security.Accesscontrol.FileSystemAccessRule "$serviceAccount", "read", allow
$permissions.AddAccessRule($rule)
Set-Acl -Path $path -AclObject $permissions

# check permission 

$permissions = Get-Acl -Path $path
$permissions.Access

# configurate Service Principal with the certificate

Set-ADSyncScheduler -SyncCycleEnabled $false
Add-EntraApplicationRegistration –UserPrincipalName $admin -CertificateThumbprint $cert.Thumbprint
Add-ADSyncApplicationRegistration –UserPrincipalName $admin -CertificateThumbprint $cert.Thumbprint

# validate and restart sync 

Get-ADSyncEntraConnectorCredential
Set-ADSyncScheduler -SyncCycleEnabled $true
Rotação de Certificado (Rollover)
Repetir o processo com um novo certificado:

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

$rsaCert = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($cert)
$path = "$env:ALLUSERSPROFILE\Microsoft\Crypto\Keys\$($rsaCert.key.UniqueName)"
$permissions = Get-Acl -Path $path
$serviceAccount = (Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\ADSync -Name ObjectName).ObjectName
$rule = New-Object Security.Accesscontrol.FileSystemAccessRule "$serviceAccount", "read", allow
$permissions.AddAccessRule($rule)
Set-Acl -Path $path -AclObject $permissions

Invoke-ADSyncApplicationCredentialRotation –UserPrincipalName $admin -CertificateThumbprint $cert.Thumbprint
