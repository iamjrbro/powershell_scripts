# Microsoft 365 — Remoção de usuários desativados de grupos

# Este arquivo documenta a configuração de uma Logic App para identificar usuários
# desativados no Microsoft Entra ID e removê-los de grupos, respeitando exceções.

## 1. Criar a Logic App

1. No Azure Portal, acesse Logic Apps e crie uma nova Logic App.
2. Defina o nome, grupo de recursos e localização.
3. Conclua a criação do recurso.

## 2. Configurar o gatilho de recorrência

1. Dentro da Logic App, adicione o gatilho de recorrência.
2. Configure o intervalo de execução desejado, por exemplo, uma vez ao mês.

## 3. Obter um token de acesso para o Microsoft Graph

Para autenticar as chamadas ao Microsoft Graph, a Logic App utiliza um token OAuth 2.0.

1. Adicione uma ação HTTP para obter o token de acesso:

   - Método: POST
   - URL: `https://login.microsoftonline.com/{TenantID}/oauth2/v2.0/token`
   - Cabeçalhos:

     ```json
     {
       "Content-Type": "application/x-www-form-urlencoded"
     }
     ```

   - Corpo:

     ```text
     grant_type=client_credentials
     &client_id={ClientID}
     &client_secret={ClientSecret}
     &scope=https://graph.microsoft.com/.default
     ```

   - Substitua `{TenantID}`, `{ClientID}` e `{ClientSecret}` pelos valores da aplicação registrada no Microsoft Entra ID, com as permissões necessárias no Microsoft Graph, como `User.Read.All` e `GroupMember.ReadWrite.All`.

2. Obtenha o token da resposta usando `@body('HTTP')['access_token']` e armazene-o em uma variável para as chamadas seguintes.

## 4. Obter usuários desativados

1. Adicione uma ação HTTP para consultar os usuários desativados no Microsoft Graph:

   - Método: GET
   - URL: `https://graph.microsoft.com/v1.0/users?$filter=accountEnabled eq false`
   - Cabeçalhos:

     ```json
     {
       "Authorization": "Bearer @{variables('access_token')}"
     }
     ```

2. Utilize a resposta para iterar sobre os usuários desativados.

## 5. Obter e filtrar grupos

1. Adicione uma ação HTTP para obter os grupos no Microsoft Graph:

   - Método: GET
   - URL: `https://graph.microsoft.com/v1.0/groups`
   - Cabeçalhos:

     ```json
     {
       "Authorization": "Bearer @{variables('access_token')}"
     }
     ```

2. Para evitar a remoção de usuários de grupos de exceção, utilize a ação Filtro de Matriz para manter somente os grupos que devem ser processados. A filtragem pode ser feita pelo nome ou pelo ID do grupo.

## 6. Verificar e remover usuários dos grupos

1. Para cada usuário desativado, adicione uma ação Aplicar a cada para processar o usuário individualmente.
2. Dentro da iteração, adicione uma ação HTTP para obter os grupos aos quais o usuário pertence:

   - Método: GET
   - URL: `https://graph.microsoft.com/v1.0/users/{UserID}/memberOf`
   - Cabeçalhos:

     ```json
     {
       "Authorization": "Bearer @{variables('access_token')}"
     }
     ```

   - Substitua `{UserID}` pelo ID do usuário desativado.

3. Para cada grupo retornado, verifique se ele não está na lista de exceções.
4. Se o grupo não estiver na lista de exceções, adicione uma ação HTTP para remover o usuário:

   - Método: DELETE
   - URL: `https://graph.microsoft.com/v1.0/groups/{GroupID}/members/{UserID}/$ref`
   - Cabeçalhos:

     ```json
     {
       "Authorization": "Bearer @{variables('access_token')}"
     }
     ```

   - Substitua `{GroupID}` pela ID do grupo e `{UserID}` pela ID do usuário.

## 7. Logs e monitoramento

Adicione ações de log ao longo do fluxo para registrar usuários processados, remoções realizadas e erros. Utilize o monitoramento da Logic App para acompanhar execuções com falha e validar o comportamento da automação.
