# Conectar ao Microsoft Graph
Connect-MgGraph -Scopes "Places.ReadWrite.All"

# Criar um novo prédio
New-MgPlace -DisplayName "BUILDING_DISPLAY_NAME" -Address "BUILDING_ADDRESS" -City "BUILDING_CITY" -State "BUILDING_STATE" -PostalCode "BUILDING_POSTAL_CODE" -Country "BUILDING_COUNTRY"

# Criar um andar
New-MgPlace -DisplayName "BUILDING_FLOOR_NAME" -ParentLocationId "BUILDING_ID" -Address "FLOOR_ADDRESS" -City "FLOOR_CITY" -State "FLOOR_STATE" -PostalCode "FLOOR_POSTAL_CODE" -Country "FLOOR_COUNTRY"
