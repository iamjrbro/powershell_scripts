LOGIC APP 

1. Logic Apps  + Criar 

2. Nome, grupo de recursos e localização 

3. Criar 

  

GATILHOS DE RECORRÊNCIA 

1. Dentro do Logic, para definição do intervalo de execução  

2. Configure o intervalo de tempo de execução (por exemplo, uma vez ao mês). 

  

AÇÃO DE AUTENTICAÇÃO (HTTP) 

 - para autenticar com o Microsoft Graph, o Logic App precisa de um Azure AD OAuth Token 

  

1. Adicione uma nova ação chamada HTTP e configure-a para obter um token de acesso: 

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

   - Substitua `{TenantID}`, `{ClientID}`, e `{ClientSecret}` pelos valores da sua Aplicação Registrada no Azure AD com permissões adequadas para o Graph (User.Read.All e GroupMember.ReadWrite.All). 

  

2. Pegue o token de acesso da resposta usando uma expressão `@body('HTTP')['access_token']` e armazene-o numa variável para ser usado em chamadas futuras 

  

OBTER USUÁRIOS DESATIVADOS  

1. Adicione uma ação HTTP para fazer uma chamada GET ao Microsoft Graph e obter todos os usuários desativados: 

   - Método: GET 

   - URL: `https://graph.microsoft.com/v1.0/users?$filter=accountEnabled eq false` 

   - Cabeçalhos:  

     ```json 

     { 

       "Authorization": "Bearer @{variables('access_token')}" 

     } 

     ``` 

  

2. Passe a resposta para iterar nos usuários desativados 

  

  5: Obter e Filtrar Grupos 

1. Adicione uma ação HTTP para obter todos os grupos no Azure AD: 

   - Método: GET 

   - URL: `https://graph.microsoft.com/v1.0/groups` 

   - Cabeçalhos:  

     ```json 

     { 

       "Authorization": "Bearer @{variables('access_token')}" 

     } 

     ``` 

  

> para evitar a remoção de usuários de grupos específicos (os de exceção), use a ação Filtro de Matriz para remover grupos não relevantes do fluxo de trabalho, filtrando pelo nome do grupo ou usando o ID do grupo se já o tiver listado 

  

VERIFICAÇÃO E REMOÇÃO DE USUÁRIOS DE GRUPO  

1. Para cada usuário desativado, adicione uma Ação de Aplicar a cada e configure uma ação de iteração 

2. Dentro de cada iteração de usuário, adicione uma ação HTTP para obter todos os grupos a que o usuário pertence: 

   - Método: GET 

   - URL: `https://graph.microsoft.com/v1.0/users/{UserID}/memberOf` 

   - Cabeçalhos:  

     ```json 

     { 

       "Authorization": "Bearer @{variables('access_token')}" 

     } 

     ``` 

   - Substitua `{UserID}` pela ID do usuário desativado. 

  

3. Para cada grupo do usuário, adicione uma ação para verificar se o grupo não está na lista de exceções. 

  

4. Adicione uma ação HTTP para remover o usuário do grupo se ele não estiver na lista de exceções: 

   - Método: DELETE 

   - URL: `https://graph.microsoft.com/v1.0/groups/{GroupID}/members/{UserID}/$ref` 

   - Cabeçalhos:  

     ```json 

     { 

       "Authorization": "Bearer @{variables('access_token')}" 

     } 

     ``` 

   - Substitua `{GroupID}` pela ID do grupo e `{UserID}` pela ID do usuário. 

  

LOG E MONITORAMENTO 

Adicione ações de log ao longo do fluxo para rastrear usuários removidos e capturar erros, como o  Monitor 

  

 
