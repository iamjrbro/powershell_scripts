# conect to Security & Compliance Center PowerShell

Connect-IPPSSession -EnableSearchOnlySession

# define the search query to find the emails to delete
New-ComplianceSearch `
  -Name "RemoveEmail" `
  -ExchangeLocation All `
  -ContentMatchQuery 'From:"user.upn@domain.com" AND Subject:"EMAIL SUBJECT"'

# start the search and wait for it to complete
Start-ComplianceSearch -Identity "RemoveEmail"

# define the purge action to delete the emails found by the search
New-ComplianceSearchAction `
  -SearchName "RemoveEmail" `
  -Purge `
  -PurgeType SoftDelete

# check the status of the purge action

Get-ComplianceSearch -Identity "RemoveEmail" | Select Name,Status,Items,Size

# if you prefer to check the status of the purge action every 10 seconds until it is completed, use the following loop:

while ($true) {
    Get-ComplianceSearch -Identity "RemoveEmail" | Select Name,Status,Items,Size
    Start-Sleep -Seconds 10
    Clear-Host
}