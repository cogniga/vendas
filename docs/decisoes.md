# Decisões do projeto

Registro de decisões que desviam da spec original do protótipo. Os agentes de
implementação devem seguir estas decisões.

## D1 — Tabela de produtos renomeada para `produto_online`

- **Data:** solicitado pela usuária.
- **O que mudou:** a tabela `produtos` do schema original passou a se chamar
  `produto_online` em `supabase/migrations/0001_schema.sql`.
- **Pontos ajustados no SQL:** definição da tabela, FK em
  `produtos_venda_itens.produto_id`, FK em `pedidos_itens.produto_id`, trigger
  `trg_produto_online_upd`, índice por `empresa_id` e o array da RLS.
- **NÃO confundir:** `produtos_venda`, `produtos_venda_itens`,
  `produtos_venda_precos` e `pedidos_itens.produto_venda_id` são sobre o
  "produto de venda" (kit) — permanecem com o nome original. A coluna
  `compras_insumo.produto` é texto livre (nome do insumo), não FK — inalterada.
- **Impacto no código Dart:**
  - A entidade `Produto` (`lib/domain/entidades/produto.dart`) não fixa o nome
    da tabela em código; só os comentários de doc foram atualizados.
  - **Repositórios (a implementar):** ao consultar o Supabase, usar o nome de
    tabela `produto_online` (ex.: `client.from('produto_online')`), não
    `produtos`.
  - O importador do seed e qualquer consulta de produtos devem usar
    `produto_online`.

## D2 — Credenciais do Supabase com fallback para `env/supabase.json`

- **Data:** solicitado pela usuária (app precisa pegar as chaves sozinho, sem
  passar flag a cada execução).
- **O que mudou:** `lib/core/config/ambiente.dart` resolve as credenciais em duas
  camadas: primeiro os `--dart-define` (se presentes); senão, lê o asset
  `env/supabase.json`. `Ambiente.carregar()` é chamado em `main()` antes de
  inicializar o Supabase.
- **pubspec:** `env/supabase.json` declarado como asset.
- **Consequência:** rodar pelo botão "Run" do editor (sem flag) funciona. Para
  builds de produção/CI, prefira `--dart-define-from-file=env/supabase.json` para
  não embutir a chave no bundle.
- **Segurança:** usar sempre a chave **publishable/anon** (respeita RLS), nunca a
  `service_role`/secret. `env/supabase.json` está no `.gitignore`.
- **Fonte:** Plus Jakarta Sans empacotada como asset local (`assets/fonts/`) em
  vez de baixar via `google_fonts` em runtime (removido). Entitlements do macOS
  ganharam `com.apple.security.network.client` (necessário ao Supabase).

## D3 — Conteúdo ancorado ao topo (AppShell._Corpo)

- **Problema:** em todas as telas o conteúdo aparecia centralizado verticalmente
  quando era menor que a viewport.
- **Correção:** `AppShell._Corpo` envolve o `child` num `ConstrainedBox`
  (minHeight = altura disponível − paddings) + `Column(stretch)` dentro do
  `SingleChildScrollView`, forçando o conteúdo a começar no topo.
- **Fidelidade visual (tela de Pedidos):** painel único (toolbar + tabela, sem
  card duplo), `PageHeader` com título à esquerda e ações à direita,
  `PlatformPill` com bolinha (dot) da cor da plataforma sobre fundo neutro,
  paddings/alinhamentos da tabela conforme o CSS do protótipo.
- **Observação sobre build:** validar mudanças visuais exige build limpo
  (`flutter build macos --debug ...`) e abrir o `.app`, pois `flutter run`
  reusava processos antigos e mostrava a versão em cache.

## D4 — Faixas de taxa: só o "até" é guardado
O "de" de cada faixa é calculado (teto anterior + R$ 0,01; 0 na primeira) por `iniciosDasFaixas` em `lib/domain/calculos/taxas.dart`. "Até" vazio (`preco_ate null`) = "e acima". Sem migration; evita buracos e sobreposição entre faixas.

## D5 — Código do produto gerado pelo sistema
`gerarCodigoProduto` (`lib/domain/calculos/codigo_produto.dart`): 3 letras de até 3 palavras do nome, sem acentos e conectivos ("Batom Matte Vermelho" → `BAT-MAT-VER`); se já existir na empresa, recebe `-2`, `-3`… O campo é somente leitura. Produto novo acompanha o nome; produto existente mantém o código (estável). A unicidade final continua garantida por `unique (empresa_id, codigo)` no banco.

## D6 — Padrão de escrita dos nomes por empresa
`configuracoes.padrao_nome` (`titulo` | `maiusculas` | `minusculas`, migration 0004). Escolhido em Dados e configurações; lido por `padraoNomeProvider` (`lib/data/repositorios/padrao_nome_provider.dart`, padrão `titulo` se a coluna ainda não existir). `TextCaseField(caso: CasoTexto.nome)` aplica o padrão **enquanto digita** (sem mexer em espaços/cursor) e normaliza ao sair do campo; os formulários reaplicam `PadraoEscrita.nome` ao salvar. Vale para produto (nome, marca, fornecedor), insumo, distribuidor e kit. Nomes já cadastrados não são alterados automaticamente.

## D7 — Painel: alerta "Estoque baixo" omitido
O protótipo avisa estoque baixo com `estoqueMin`, mas `Produto` não tem essa coluna. O alerta fica fora do painel; para tê-lo é preciso uma migration adicionando `estoque_min` em `produto_online` (não criada sem pedido).
## D8 — Painel: período e situação dos pedidos
"Este mês" compara ano e mês de `pedido.data` com hoje; "Todo o período" (padrão) não filtra. Só pedidos `concluido` entram (design §6.5); cancelado e devolvido ficam de fora. O período vive em `periodoPainelProvider`; trocar o período recalcula na hora, sem nova consulta.
## D9 — Painel: pontos de atenção
`pontosAtencao` usa os textos do protótipo e uma `GravidadeAtencao` (`ruim` → fundo `badSoft`; `atencao` → `warnSoft`). Destinos fora de 100% (tolerância 0,01) e kit com prejuízo são `ruim`; margem < 15% e códigos repetidos são `atencao`. "Itens mais vendidos" soma a quantidade da linha do pedido (kit não multiplica pelos itens), como o protótipo.

## D10 — Pedido: rótulos de status e itens do editor
O banco guarda `pedidos.situacao` como `concluido | cancelado | devolvido` (check constraint), então o enum `SituacaoPedido` não muda e não há migration. O editor exibe `concluido` = "Pago", `devolvido` = "Devolvido" e `cancelado` = "Cancelado". "Enviado" e "Entregue" do protótipo não são persistíveis: exigiriam uma migration alterando o check de `pedidos.situacao` (e o enum), por isso ficam fora. Ao editar, o editor busca o pedido completo (`pedidoCompletoProvider` → `obterComItens`) e só monta o formulário depois; itens já gravados mantêm o snapshot de custo e abelinhas (inclusive quando o produto/kit não existe mais). `PedidoRepository.listar` agora traz os itens (lista, painel e caixa).
