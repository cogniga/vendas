# Documentação de classes — Camada features

> Regra do projeto: cada classe tem documentação única, atualizada a cada
> alteração. Este arquivo agrupa as classes de `lib/features` entregues na
> PARTE C (autenticação, onboarding e importador do seed). As telas usam os
> tokens `context.cores`/`Raios`/`Espacos` e os componentes de `core/widgets`;
> nenhuma chamada ao Supabase vive em widget — apenas em controllers e
> repositórios.

## documento_AuthController
- **Arquivo:** `lib/features/auth/application/auth_controller.dart`
- **Responsabilidade:** autentica via Supabase Auth (design.md §10).
  `StateNotifier<AsyncValue<void>>` que expõe `loading`/`error`/`data` da
  última operação. Métodos: `entrar(email, senha)` (`signInWithPassword`),
  `criarConta(email, senha)` (`signUp`), `recuperarSenha(email)`
  (`resetPasswordForEmail`) e `sair()` (`signOut`). Traduz `AuthException`
  para mensagens amigáveis em pt_BR (§10). A navegação em si é decidida pelo
  `redirect` do go_router (reage à sessão), não pelo controller.
- **Provider:** `authControllerProvider`
  (`StateNotifierProvider<AuthController, AsyncValue<void>>`).

## documento_LoginPage
- **Arquivo:** `lib/features/auth/presentation/login_page.dart`
- **Responsabilidade:** tela `/login` (substitui o placeholder da FEAT-002).
  Formulário e-mail/senha com validação; alterna entre "Entrar" e "Criar
  conta"; ação "Esqueci a senha" abre diálogo pedindo o e-mail e chama
  `recuperarSenha`. Mostra carregamento no botão (progress) e erro em caixa
  suave (`badSoft`) via `authControllerProvider`. Após autenticar, o redirect
  leva a `/` ou `/onboarding`.

## documento_OnboardingController
- **Arquivo:** `lib/features/onboarding/application/onboarding_controller.dart`
- **Responsabilidade:** fluxo de onboarding em duas etapas.
  `criarEmpresa(nome)` chama `EmpresaRepository.criarEmpresa` e guarda o `id`
  gerado (sem invalidar nada ainda, para o redirect não disparar cedo);
  `concluir({required bool importar})` importa o seed (via
  `ImportadorSeed.importar`) quando pedido e, ao final, invalida
  `empresaAtualProvider`. Estado `AsyncValue<void>` (`loading`/`error`); expõe
  `empresaId` da empresa criada na sessão.
- **Provider:** `onboardingControllerProvider`
  (`StateNotifierProvider<OnboardingController, AsyncValue<void>>`).

## documento_OnboardingPage
- **Arquivo:** `lib/features/onboarding/presentation/onboarding_page.dart`
- **Responsabilidade:** tela `/onboarding` (substitui o placeholder da
  FEAT-002). Passo 1: nome da empresa (normalizado como título com
  `PadraoEscrita.titulo`) → cria a empresa. Passo 2 (após criar): escolha
  "Importar dados da planilha" (`concluir(importar: true)`) ou "Começar vazio"
  (`concluir(importar: false)`); ao concluir sem erro, navega para `/`.
  Estados carregando/erro (§10). Usa `onboardingControllerProvider`.

## documento_ImportadorSeed
- **Arquivo:** `lib/features/onboarding/application/importador_seed.dart`
- **Responsabilidade:** importa `assets/seed/dados-iniciais.json` para a
  empresa (design.md §9). Recebe os repositórios da FEAT-001 por construtor.
  `importar(empresaId)` lê o asset com `rootBundle.loadString` + `json.decode`
  e delega para `importarDados(empresaId, dados)` (separado para teste sem
  `rootBundle`). Ordem: configurações → plataformas/faixas → destinos → regra
  de abelinhas → produtos (`produto_online`) → produtos de venda → compras →
  investimentos → pedidos → saques. Plataformas, destinos e faixas de abelinha
  (já criados pela RPC `criar_empresa`) são **atualizados casando pelo nome**
  sem duplicar; faixas de taxa são substituídas pelas do arquivo. Resolve as
  referências textuais do arquivo (código do produto, nome da plataforma/
  destino, nome do kit) para UUIDs via mapas construídos durante a importação.
- **Snapshots e rateio:** nos itens de pedido, para `tipo` "produto"
  `custo_unitario = produto.custo` e `abelinhas_unitarias =
  abelinhasProduto(...)`; para "produto_venda" usa `calcularKit` (investimento
  e abelinhas do kit) — cálculos de `lib/domain/calculos`, não reimplementados.
  O rateio do saque usa os percentuais do arquivo (`valor * percentual / 100`).
- **Provider:** `importadorSeedProvider` (monta o importador a partir dos
  providers de repositório). `kCaminhoSeed` expõe o caminho do asset.

## documento_ProdutosProviders
- **Arquivo:** `lib/features/produtos/application/produtos_providers.dart`
- **Responsabilidade:** providers (todos `autoDispose`) que alimentam a lista
  de Produtos (R3). Lêem `empresaAtualProvider` e devolvem vazio/`null`
  enquanto não há empresa (login provisório adm/adm).
  - `produtosProvider` (`FutureProvider<List<Produto>>`): lista de
    `produto_online` ordenada por nome.
  - `faixasAbelinhaProvider` (`FutureProvider<List<FaixaAbelinha>>`): faixas da
    regra de abelinhas, ordenadas por custo.
  - `configuracoesProvider` (`FutureProvider<Configuracoes?>`): traz
    `valorAbelinha`.
  - `vendidosPorProdutoProvider` (`FutureProvider<Map<String,int>>`): unidades
    vendidas por produto, somando só pedidos `SituacaoPedido.concluido`. Itens
    avulsos somam a quantidade; itens de kit somam a quantidade do
    `ProdutoVendaItem` × a quantidade do kit no pedido. Carrega os itens via
    `PedidoRepository.obterComItens` por pedido e os kits via
    `ProdutoVendaRepository.listar`.
  - `codigosRepetidosProvider` (`FutureProvider<Set<String>>`): códigos que
    aparecem em mais de um produto da lista atual (sinaliza "código repetido").

## documento_ComposicaoProviders
- **Arquivo:** `lib/features/composicao/application/composicao_providers.dart`
- **Responsabilidade:** providers (todos `autoDispose`) da Composição de custo
  (R4). Lêem `empresaAtualProvider` e devolvem vazio/`null` sem empresa
  (login provisório adm/adm).
  - `kitsProvider` (`List<ProdutoVenda>`): kits com itens e preços montados.
  - `plataformasComFaixasProvider` (`Map<Plataforma,List<FaixaTaxa>>`).
  - `produtosProvider` (`List<Produto>`), `faixasAbelinhaProvider`
    (`List<FaixaAbelinha>`), `configuracoesProvider` (`Configuracoes?`),
    `comprasInsumoProvider` (`List<CompraInsumo>`), `pedidosProvider`
    (`List<Pedido>`, para "vendidos").
  - `kitCompletoProvider` (`family<ProdutoVenda?, String>`): kit completo por
    id, via `obterCompleto`, para abrir no editor.
  - `dadosEdicaoKitProvider` (`FutureProvider<DadosEdicaoKit>`): compõe os
    anteriores num único objeto para o editor.
- **DadosEdicaoKit:** agregador com `plataformas`, `produtosPorId`,
  `faixasAbelinha`, `configuracoes`, `compras`, `pedidos`; getter `produtos`
  devolve os produtos ordenados por nome.

## documento_KitFormController
- **Arquivo:** `lib/features/composicao/application/kit_form_controller.dart`
- **Responsabilidade:** mutações de `ProdutoVenda` (R4).
  `StateNotifier<AsyncValue<void>>` com `salvar(ProdutoVenda)`,
  `duplicar(id)` e `excluir(id)` via `produtoVendaRepositoryProvider`; em
  sucesso invalida `kitsProvider` e traduz `ErroRepositorio` para pt_BR.
- **Provider:** `kitFormControllerProvider`
  (`StateNotifierProvider<KitFormController, AsyncValue<void>>`).

## documento_ComposicaoPage
- **Arquivo:** `lib/features/composicao/presentation/composicao_page.dart`
- **Responsabilidade:** tela da Composição de custo (R4, substitui o
  placeholder). Raiz `Column`. `PageHeader` + "Novo produto de venda"; trata
  carregando/erro/vazio. `ResponsiveList<ProdutoVenda>` com
  `limiarCartao: 990`. Colunas: **Produto de venda** (principal: nome +
  composição `qtd× código`), **Investimento** (compra+embalagem+impressão+
  outros, com `N itens · X 🐝`) e **uma coluna por plataforma** com o lucro
  (`good`/`bad`) e, abaixo, `cliente paga · margem` via `calcularKit`. Ações:
  abrir (`abrirKitEditor`), duplicar e `ConfirmDeleteButton`. Em tela estreita
  vira cartões (sem rolagem horizontal).

## documento_KitEditor
- **Arquivo:** `lib/features/composicao/presentation/kit_editor.dart`
- **Responsabilidade:** editor de produto de venda em painel lateral largo
  (`abrirKitEditor` → `abrirPainelLateral(largo: true)`, até 1080px; tela cheia
  < 760). `ConsumerStatefulWidget` que observa `dadosEdicaoKitProvider` e
  (ao editar) `kitCompletoProvider`. Layout: em ≥860px `Row` [esquerda flex3,
  resumo flex2]; estreito empilha. Coluna esquerda: itens (busca + −/+, 0
  remove), custos adicionais (embalagem por `CompraInsumo` unitário =
  `valorTotal/itens` ou manual, impressão, outros) e preço base/metas
  (margem %, meta de lucro R$, fatia do lucro p/ anúncios). Resumo fixo:
  investimento, abelinhas + valor em R$, lucro por plataforma e "Melhor
  resultado" (quando investimento > 0). Tabela **Resultado por plataforma**:
  campos editáveis preço/desconto/cupom (vazio usa a base como placeholder),
  recalcula ao digitar mantendo o foco (controller por célula), colunas
  calculadas por `calcularKit` + `precoMinimo`; "Sugerido" é um botão
  (`precoParaMargem + desconto + cupom`) que aplica o valor no campo de preço;
  "Meta" como pill `vendidos/metaQtd`. Em tela estreita a tabela vira blocos
  por plataforma. Ao salvar valida nome e ≥1 item, normaliza o nome com
  `PadraoEscrita.titulo`, limpa overrides vazios, preenche `empresaId` e chama
  `kitFormControllerProvider`.

## documento_ProdutosPage
- **Arquivo:** `lib/features/produtos/presentation/produtos_page.dart`
- **Responsabilidade:** tela de Produtos (R3). Raiz `Column` (o `AppShell`
  envolve em scroll). `PageHeader` + "Novo produto", busca por código/nome/
  marca/fornecedor, filtro por categoria e contador. Lista via
  `ResponsiveList<Produto>` (tabela ↔ cartões). Colunas: **Produto**
  (principal: nome + `CodeChip`/marca/categoria e pills `inativo` quando
  `!ativo` e `código repetido` quando o código está em `codigosRepetidosProvider`),
  **Custo un.** (valor + fornecedor), **Abelinhas** (quantidade + pill
  "pela regra/ajustado" + botão ✎ `IconAction` que abre o editor) e
  **Estoque** (`N unidade` + `N vendido(s)` de `vendidosPorProdutoProvider`).
  Ações por linha: editar (✎) e `ConfirmDeleteButton` (R3.9 avisa kits que
  usam o produto antes de excluir). O editor é aberto por `abrirProdutoForm`
  (painel lateral). Widgets internos: `_Filtros`, `_CelulaProduto`,
  `_CelulaCusto`, `_CelulaAbelinhas`, `_CelulaEstoque`.
