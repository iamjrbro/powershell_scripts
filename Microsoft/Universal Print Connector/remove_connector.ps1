<#
.SYNOPSIS
Lista e remove conectores do Microsoft Universal Print.

.DESCRIPTION
Instala o módulo UniversalPrintManagement, conecta ao serviço, lista os conectores disponíveis e remove o conector informado pelo ID.

.NOTES
Substitua COLE-O-ID-AQUI pelo ID do conector que deve ser removido.
#>

# Instala o módulo UniversalPrintManagement, caso ainda não esteja instalado.
Install-Module UniversalPrintManagement

# Conecta ao serviço Universal Print.
Connect-UPService

# Lista os conectores disponíveis.
Get-UPConnector

# Remove o conector especificado pelo ID.
Remove-UPConnector -ConnectorId "COLE-O-ID-AQUI"
