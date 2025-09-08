# Conectar ao Microsoft Graph
Connect-MgGraph -Scopes "Places.ReadWrite.All"

# Criar um novo prédio
New-MgPlace -DisplayName "Sede São Paulo" -Address "Av. Paulista, 1000, São Paulo - SP"

# Criar um andar
New-MgPlace -DisplayName "Andar 10" -ParentLocationId "ID_DO_PRÉDIO"
