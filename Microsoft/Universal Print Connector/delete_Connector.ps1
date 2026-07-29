
# instale o modulo UniversalPrintManagement se ainda não estiver instalado
Install-Module UniversalPrintManagement

# conecte-se ao serviço Universal Print
Connect-UPService

# get a lista de conectores
Get-UPConnector

# remove o conector especificado pelo ID
Remove-UPConnector -ConnectorId "COLE-O-ID-AQUI"
