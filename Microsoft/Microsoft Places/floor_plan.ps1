# instalando e conectando os módulos

Connect-ExchangeOnline
Install-Module MicrosoftPlaces -Force
Import-Module MicrosoftPlaces
Connect-MicrosoftPlaces
Get-Command -Module MicrosoftPlaces *PlaceV3*
Connect-MicrosoftPlaces
Get-PlaceV3 -Type Building

# habilitação de funcionalidades do Places
Set-PlacesSettings -EnablePlacesWebApp $true

# habilita o acesso ao aplicativo web do Places (em Public Preview), permitindo interação com mapas e espaços via navegador

Set-PlacesSettings -EnablePlacesFinder $true
