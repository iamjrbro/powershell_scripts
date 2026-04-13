Install-Module MicrosoftPlaces
Import-Module MicrosoftPlaces
Get-Command -Module MicrosoftPlaces *PlaceV3*
Connect-MicrosoftPlaces
Get-PlaceV3 -Type Building