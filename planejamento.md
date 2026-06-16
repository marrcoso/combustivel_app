# Planejamento do App de Combustível

## 1. Visão Geral do Projeto
*   **Objetivo:** Aplicativo mobile para localização de postos e visualização/comparação de preços atualizados de todos os tipos de combustíveis.
*   **Público-alvo:** Motoristas em geral interessados em economia e praticidade.
*   **Custos e Monetização:** Arquitetura desenhada para ser 100% gratuita no uso de ferramentas e serviços de terceiros durante a fase de validação e tração.

## 2. Arquitetura e Tecnologias
*   **Frontend:** Flutter (desenvolvimento multiplataforma).
*   **Backend:** Firebase (Authentication, Cloud Firestore).
*   **Mapas:** OpenStreetMap utilizando o pacote `flutter_map` (sem dependência de chaves pagas do Google Maps).
*   **Recursos Nativos:** Ícones das bandeiras de postos e outros recursos gráficos serão incluídos como arquivos estáticos (assets) locais no aplicativo, visando economizar banda e custos do Firebase.

## 3. Tipos de Usuários e Permissões
O aplicativo contará com dois perfis de usuário, definidos através do banco de dados:

*   **Administrador (`isAdmin: true`):**
    *   Cria e cadastra novos postos no mapa.
    *   Edita informações gerais e atualiza preços dos postos de forma direta e sem moderação.
    *   Possui acesso a uma tela exclusiva de "Aprovações Pendentes" para validar (aprovar ou recusar) sugestões de preços enviadas pela comunidade.
*   **Usuário Comum (`isAdmin: false` ou nulo):**
    *   Visualiza postos, detalhes e os preços atuais.
    *   Não tem permissão para cadastrar novos postos no banco de dados.
    *   Possui a opção exclusiva de *sugerir* uma atualização de preço para um posto já existente no mapa.

## 4. Estrutura de Telas e Fluxos Mobile
*   **Login/Cadastro:** Autenticação simplificada utilizando apenas E-mail e Senha. Não serão exigidos dados extras como Nome, CPF ou Placa do veículo.
*   **Mapa e Lista (Home):**
    *   Visão principal contendo pinos dos postos (OSM) e uma aba/tela para listagem em cards.
    *   A localização do aparelho (GPS) será acessada *apenas com o app em uso (foreground)*.
    *   Comportamento Offline: Não haverá suporte offline. Em caso de ausência de internet, uma mensagem de erro ("Sem Conexão") será exibida bloqueando o uso do app.
*   **Detalhes do Posto:** 
    *   Exibe os preços atualizados para os 6 tipos de combustíveis do sistema (Gasolina Comum, Gasolina Aditivada, Etanol, Diesel Comum, Diesel S10, GNV).
    *   Botão "Como Chegar/Traçar Rota", que fará a integração abrindo nativamente aplicativos de terceiros (Waze, Google Maps).
*   **Painel de Aprovações (Exclusivo Admin):** 
    *   Lista contendo todas as sugestões de preços pendentes para que o admin possa aprovar ou rejeitar.

## 5. Modelo de Dados (Firestore)

Abaixo a estrutura oficial das coleções e documentos no Cloud Firestore:

*   **`users/{uid}`**
    *   `email` (string)
    *   `isAdmin` (boolean)
*   **`stations/{stationId}`**
    *   `name` (string)
    *   `brand` (string - identificador local do asset, ex: "shell", "br", "branca")
    *   `location` (GeoPoint)
    *   `prices` (map): 
        *   `gasolina_comum`: double
        *   `gasolina_aditivada`: double
        *   `etanol`: double
        *   `diesel_comum`: double
        *   `diesel_s10`: double
        *   `gnv`: double
    *   `lastUpdate` (timestamp)
*   **`price_suggestions/{suggestionId}`**
    *   `stationId` (reference)
    *   `suggestedBy` (user reference)
    *   `suggestedPrices` (map)
    *   `status` (string - "pending", "approved", "rejected")
    *   `createdAt` (timestamp)

## 6. Filtros de Pesquisa
O aplicativo possuirá filtros ativos na Lista e no Mapa:
*   Busca pelo **Nome do Posto**.
*   Filtro por **Tipo do Combustível** (exibindo e ordenando os postos de acordo com o combustível selecionado).
