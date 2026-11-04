# Plano de implementação — Balcão Revenda, três camadas (A · B · C)

Repositório: `/Users/raquel/Documents/projetos/front/private/sales` (branch `main`, SEM worktree, SEM push).
Package Dart `sales` (imports `package:sales/...`). Lint very_good_analysis: linhas ≤ 80 colunas.

Fontes já prontas e verdes (NÃO reimplementar):
- Entidades freezed em `lib/domain/entidades/` (fromJson/toJson snake_case com `DecimalConverter`).
- Cálculos puros em `lib/domain/calculos/` (`taxas.dart`, `produto_venda.dart` → `calcularKit`/`ResultadoKit`, `pedido.dart` → `calcularPedido`/`ResultadoPedido`/`precoAutomatico`/`itensTaxaFixaAutomatico`, `abelinhas.dart`, `caixa.dart` → `rateio`/`saldoDestino`, `painel.dart`).
- Formatação `lib/core/format/formatos.dart` (`Formatos`) e `lib/core/format/padrao_escrita.dart` (`PadraoEscrita`).
- Tema `lib/core/theme/` (`TemaApp`, `temaProvider` ThemeMode, tokens `context.cores`, `Raios`, `Espacos`).
- Config `lib/core/config/supabase_config.dart` (`supabaseClientProvider`, `authStateProvider`), `ambiente.dart`.

Decisão D1 (`docs/decisoes.md`): tabela de produtos = `produto_online`. Toda consulta de produtos usa `client.from('produto_online')`.

Comandos de verificação do projeto:
- `dart run build_runner build --delete-conflicting-outputs` (gera `*.freezed.dart`/`*.g.dart`).
- `flutter analyze` (deve ficar limpo).
- `flutter test` (baseline: 45 testes verdes).

Convenção de documentação: cada classe criada ganha uma seção `## documento_<Classe>` (Arquivo / Responsabilidade) em `docs/classes/` — usar `documento_dados.md` (PARTE A), `documento_core.md` (PARTE B, já existe) e `documento_features.md` (PARTE C). Atualizar a cada alteração.

---

## PARTE A — Repositórios Supabase + providers

- [ ] 1. Criar `RepositorioBase`/erros e o `empresaAtualProvider`.
      Criar `lib/data/repositorios/erros_repositorio.dart` com `ErroRepositorio` (mensagem amigável) e helper para traduzir `PostgrestException` (ex.: código único → mensagem específica). Criar `empresaAtualProvider` em `lib/data/repositorios/empresa_atual_provider.dart` como `FutureProvider<Empresa?>` que lê a primeira empresa do usuário via `EmpresaRepository.listarMinhas()` (preparado para várias; retorna `null` se nenhuma). Documentar ambos em `docs/classes/documento_dados.md`.
      Files: lib/data/repositorios/erros_repositorio.dart, lib/data/repositorios/empresa_atual_provider.dart, docs/classes/documento_dados.md
      Verify: `flutter analyze lib/data` sem erros (depende dos itens seguintes compilarem; rodar ao final de A).

- [ ] 2. `EmpresaRepository` + provider.
      `lib/data/repositorios/empresa_repository.dart`. Construtor `EmpresaRepository(this._client)`. Métodos: `Future<String> criarEmpresa(String nome)` via `_client.rpc('criar_empresa', params: {'p_nome': nome})` (retorna uuid); `Future<List<Empresa>> listarMinhas()` (join em `membros` → `empresas` filtrado por `user_id = auth.currentUser.id`); `Future<Empresa?> obterPorId(String id)`. Provider `empresaRepositoryProvider = Provider((ref) => EmpresaRepository(ref.watch(supabaseClientProvider)))`.
      Files: lib/data/repositorios/empresa_repository.dart
      Verify: incluído na verificação final de A (analyze + test).

- [ ] 3. `ConfiguracoesRepository` + `FaixaAbelinhaRepository` + providers.
      `configuracoes_repository.dart`: `obter(empresaId)` → `Configuracoes` (select em `configuracoes` por `empresa_id`), `atualizar(Configuracoes)`. `faixa_abelinha_repository.dart`: `listar(empresaId)` → `List<FaixaAbelinha>` (order `custo_ate`), `substituir(empresaId, List<FaixaAbelinha>)` (delete por empresa + insert em lote, ordenado por `custo_ate`). Providers correspondentes.
      Files: lib/data/repositorios/configuracoes_repository.dart, lib/data/repositorios/faixa_abelinha_repository.dart
      Verify: verificação final de A.

- [ ] 4. `ProdutoRepository` + provider (tabela `produto_online`).
      `produto_repository.dart`. `listar(empresaId)`, `obter(id)`, `criar(Produto)`, `atualizar(Produto)`, `excluir(id)`, `kitsQueUsam(produtoId)` (join em `produtos_venda_itens` → nomes de kits, para o aviso de exclusão R3.9). TODAS as consultas em `_client.from('produto_online')` filtrando `empresa_id`. Tratar violação de código único (PostgrestException code `23505`) lançando `ErroRepositorio('Já existe um produto com o código X')` com o código real.
      Files: lib/data/repositorios/produto_repository.dart
      Verify: verificação final de A.

- [ ] 5. `PlataformaRepository` (+ faixas_taxa) + provider.
      `plataforma_repository.dart`. `listarComFaixas(empresaId)` → `List<(Plataforma, List<FaixaTaxa>)>` ou `Map<Plataforma,List<FaixaTaxa>>` (order `ordem`; faixas por `plataforma_id`); `criar(nome)`, `renomear(id,nome)`, `mudarCor(id,cor)`, `excluir(id)` (bloquear se usada em `pedidos`/`saques` → `ErroRepositorio`), `substituirFaixas(plataformaId, List<FaixaTaxa>)` (delete + insert em lote). Provider.
      Files: lib/data/repositorios/plataforma_repository.dart
      Verify: verificação final de A.

- [ ] 6. `DestinoRepository`, `CompraInsumoRepository`, `InvestimentoRepository`, `RetiradaRepository` + providers.
      Um arquivo por repositório. CRUD padrão (`listar(empresaId)`, `obter`, `criar`, `atualizar`, `excluir`) filtrando `empresa_id`. `CompraInsumoRepository` ordena por `data desc`. Providers correspondentes.
      Files: lib/data/repositorios/destino_repository.dart, lib/data/repositorios/compra_insumo_repository.dart, lib/data/repositorios/investimento_repository.dart, lib/data/repositorios/retirada_repository.dart
      Verify: verificação final de A.

- [ ] 7. `ProdutoVendaRepository` (kit coeso) + provider.
      `produto_venda_repository.dart`. `listar(empresaId)` → kits com itens e preços; `obterCompleto(id)` → `ProdutoVenda` com `itens` (de `produtos_venda_itens`) e `precosPorPlataforma` (de `produtos_venda_precos`, chave `plataforma_id`); `salvar(ProdutoVenda)` grava kit + substitui itens + upsert dos preços de forma coesa (delete-then-insert de itens; upsert de `produtos_venda_precos` por PK composta); `duplicar(id)` cria "<nome> (cópia)" com vendidos iniciais zerados; `excluir(id)`. Todas filtram `empresa_id`.
      Files: lib/data/repositorios/produto_venda_repository.dart
      Verify: verificação final de A.

- [ ] 8. `PedidoRepository` + provider.
      `pedido_repository.dart`. `listar(empresaId)` (order `data desc`); `obterComItens(id)` → `Pedido` com `itens` (de `pedidos_itens`); `salvar(Pedido)` grava pedido + substitui itens gravando os snapshots `custo_unitario`/`abelinhas_unitarias` já presentes em cada `PedidoItem`; `excluir(id)`. Filtra `empresa_id`.
      Files: lib/data/repositorios/pedido_repository.dart
      Verify: verificação final de A.

- [ ] 9. `SaqueRepository` + provider.
      `saque_repository.dart`. `salvar(Saque)` grava saque + rateio (`saques_rateio`) de forma coesa; `listar(empresaId)` (order `data desc`, com rateio); `excluir(id)`. Filtra `empresa_id`.
      Files: lib/data/repositorios/saque_repository.dart
      Verify: `dart run build_runner build --delete-conflicting-outputs` && `flutter analyze` (limpo) && `flutter test` (45 baseline continua verde). Documentar todos os repositórios/providers e o `empresaAtualProvider` em `docs/classes/documento_dados.md`.

## PARTE B — Navegação (go_router) + AppShell + componentes compartilhados

- [ ] 10. Componentes de apresentação simples em `lib/core/widgets/`.
      Criar, um arquivo por widget, usando `context.cores`, `Raios`, `Espacos`: `PageHeader(title, subtitle?, actions)`; `KpiCard(label, value, sub?)` e `KpiRow` (Wrap, cartões `flex 1 1 170`); `Pill(texto, tom)` com enum `TomPill {neutro,bom,atencao,ruim,destaque}` (cores good/warn/bad/accentSoft/surface2); `PlatformPill(nome, cor)`; `CodeChip(texto)`; `Abelinhas(qtd)` → `Formatos.abelinhas`; `IconAction(icon, tooltip, danger?, onPressed)` com `Tooltip` + `Semantics(label:)`; `ConfirmDeleteButton(onConfirm)` (1º clique vira "Confirmar" vermelho por 3 s via Timer); `Ledger(linhas, total?)`; `MoneyField` (TextField que aceita vírgula, parse via `Formatos.parseDecimal`); `TextCaseField(caso: titulo|frase|maius)` que normaliza ao perder foco via `PadraoEscrita`. Documentar em `docs/classes/documento_core.md`.
      Files: lib/core/widgets/page_header.dart, lib/core/widgets/kpi_card.dart, lib/core/widgets/pill.dart, lib/core/widgets/platform_pill.dart, lib/core/widgets/code_chip.dart, lib/core/widgets/abelinhas.dart, lib/core/widgets/icon_action.dart, lib/core/widgets/confirm_delete_button.dart, lib/core/widgets/ledger.dart, lib/core/widgets/money_field.dart, lib/core/widgets/text_case_field.dart, docs/classes/documento_core.md
      Verify: `flutter analyze lib/core/widgets` limpo.

- [ ] 11. `ResponsiveList<T>` com teste de widget.
      `lib/core/widgets/responsive_list.dart`: classe `ColunaLista<T>(label, builder, alinhamento?, principal?)`; `ResponsiveList<T>({required itens, required colunas, acoes?, limiarCartao=780})` que usa `LayoutBuilder`: se `constraints.maxWidth >= limiar` renderiza tabela (cabeçalho `surface2`, linhas), senão cartões (título = coluna principal, grade de rótulo/valor, ações no topo direito). Sem rolagem horizontal. Documentar.
      Files: lib/core/widgets/responsive_list.dart, docs/classes/documento_core.md
      Verify: ver item 14.

- [ ] 12. `AppShell` com menu lateral/gaveta.
      `lib/core/widgets/app_shell.dart`: `AppShell({required child, required rotaAtual})`. Largura do menu: 264 px (≥1100), 240 px (760–1099), gaveta (<760 via `Scaffold.drawer` + `AppBar` com ☰). Grupos Painel / Operação (Pedidos, Composição de custo, Produtos) / Financeiro (Compras de insumos, Investimento, Caixa e saques) / Configuração (Plataformas e taxas, Regra de abelinhas, Dados e configurações) — ícones lucide. Item ativo: fundo `accentSoft`, texto/ícone `accent`, barra lateral `accent`. Seletor de tema no rodapé (lê/escreve `temaProvider`). Navegação via `context.go(rota)`. Sem overflow horizontal. Documentar.
      Files: lib/core/widgets/app_shell.dart, docs/classes/documento_core.md
      Verify: ver item 14.

- [ ] 13. go_router + guardas + substituir `app.dart`.
      `lib/core/router/rotas.dart` (constantes das rotas) e `lib/core/router/app_router.dart`: `goRouterProvider = Provider<GoRouter>` com todas as rotas do design §4 (`/login`, `/onboarding`, `/`, `/pedidos`, `/pedidos/novo`, `/pedidos/:id`, `/composicao`, `/composicao/novo`, `/composicao/:id`, `/produtos`, `/insumos`, `/investimento`, `/caixa`, `/plataformas`, `/abelinhas`, `/configuracoes`). `ShellRoute` envolvendo as rotas internas com `AppShell`. `redirect`: sem sessão (`authStateProvider`/`Supabase.instance.client.auth.currentSession`) → `/login`; autenticado sem empresa (`empresaAtualProvider`) → `/onboarding`; senão libera. Páginas internas podem ser placeholders mínimos nesta etapa (um `PageHeader` + "em construção") para manter build verde — a tarefa foca em A/B/C de infraestrutura, não nos CRUDs completos. Substituir `lib/app.dart`: remover `_PlaceholderInicio`, usar `MaterialApp.router(routerConfig: ref.watch(goRouterProvider))` mantendo tema e locale pt_BR; manter fallback `TelaConfigAusente` quando `!Ambiente.supabaseConfigurado`. Documentar roteador e shell.
      Files: lib/core/router/rotas.dart, lib/core/router/app_router.dart, lib/app.dart, docs/classes/documento_core.md, (placeholders) lib/features/*/presentation/*_page.dart
      Verify: `flutter analyze` limpo; `flutter run -d macos` sobe sem crash (opcional — ver constraints de ambiente).

- [ ] 14. Widget tests da PARTE B.
      `test/widgets/responsive_list_test.dart`: renderizar `ResponsiveList` com itens de teste dentro de `SizedBox` de largura 1440, 1000 e 400 px; em 1440 espera tabela (encontrar cabeçalhos via `find.text`), em 400 espera cartões; em todos, verificar ausência de overflow horizontal (`tester.takeException()` nulo e nenhum `RenderFlex overflow`). `test/widgets/app_shell_test.dart`: montar `AppShell` em `MaterialApp` com largura <760 (via `tester.view.physicalSize`) e verificar que o ☰ aparece e abre o `Drawer`; em largura ≥1100 verificar menu lateral fixo (sem ☰). Usar `ProviderScope` com overrides mínimos (ex.: `temaProvider`).
      Files: test/widgets/responsive_list_test.dart, test/widgets/app_shell_test.dart
      Verify: `flutter test test/widgets` passa; `flutter test` mantém baseline + novos testes verdes.

## PARTE C — Auth + onboarding + importador do seed

- [ ] 15. Controllers/providers de auth.
      `lib/features/auth/application/auth_controller.dart`: `AuthController` (StateNotifier ou AsyncNotifier) usando `Supabase.instance.client.auth`: `entrar(email,senha)` (`signInWithPassword`), `criarConta(email,senha)` (`signUp`), `recuperarSenha(email)` (`resetPasswordForEmail`), `sair()` (`signOut`). Estado `AsyncValue`/enum carregando/erro (§10) com mensagens amigáveis. Provider `authControllerProvider`.
      Files: lib/features/auth/application/auth_controller.dart, docs/classes/documento_features.md
      Verify: incluído na verificação final de C.

- [ ] 16. Tela de Login / criar conta / esqueci a senha (R1).
      `lib/features/auth/presentation/login_page.dart`: formulário e-mail/senha, alternância "Criar conta", link "Esqueci a senha"; estados carregando (botão com spinner) e erro (mensagem via §10). Usa `authControllerProvider`. Ao autenticar, o `redirect` do go_router leva a `/` ou `/onboarding`.
      Files: lib/features/auth/presentation/login_page.dart, docs/classes/documento_features.md
      Verify: verificação final de C.

- [ ] 17. Onboarding (R1).
      `lib/features/onboarding/presentation/onboarding_page.dart` + `lib/features/onboarding/application/onboarding_controller.dart`: pedir nome da empresa → `empresaRepository.criarEmpresa(nome)`; após criar, oferecer "Importar dados da planilha" (chama o importador do item 18) ou "Começar vazio"; invalidar `empresaAtualProvider` e navegar para `/`. Estados carregando/erro.
      Files: lib/features/onboarding/presentation/onboarding_page.dart, lib/features/onboarding/application/onboarding_controller.dart, docs/classes/documento_features.md
      Verify: verificação final de C.

- [ ] 18. Importador do seed (§9).
      `lib/features/onboarding/application/importador_seed.dart`: `ImportadorSeed(this._repos...)` recebe os repositórios de A (ou o `SupabaseClient` + repos). `importar(empresaId)`: lê `assets/seed/dados-iniciais.json` via `rootBundle.loadString`. Ordem: configurações → plataformas/faixas → destinos → produtos (`produto_online`) → produtos de venda → compras → investimentos → pedidos → saques. Como a RPC `criar_empresa` já cria plataformas/faixas/destinos/abelinhas padrão, **atualizar os existentes casando pelo NOME** (não duplicar): buscar plataformas/destinos existentes por nome e atualizar; inserir só os ausentes. Resolver refs textuais (`ref` = código do produto, `plataforma`/`destino` = nome) para UUIDs via mapas construídos durante a importação. Nos itens de pedido, calcular o snapshot `custo_unitario`/`abelinhas_unitarias` com `lib/domain/calculos` (`abelinhasProduto` para produto; investimento do kit via `calcularKit` para produto_venda) a partir do cadastro importado. Rateio do saque gravado com os percentuais do arquivo (via `SaqueRepository.salvar` ou `caixa.rateio`). Documentar.
      Files: lib/features/onboarding/application/importador_seed.dart, docs/classes/documento_features.md
      Verify: verificação final de C.

- [ ] 19. Verificação integrada de C.
      Garantir build e testes verdes com as três partes integradas.
      Files: (nenhum novo)
      Verify: `dart run build_runner build --delete-conflicting-outputs` && `flutter analyze` (limpo) && `flutter test` (baseline 45 + widget tests de B continuam verdes). Conferir manualmente que `app.dart` usa `MaterialApp.router` e que as rotas/guardas compilam.

## Suposições
- As páginas de CRUD por feature (produtos, pedidos, caixa etc.) ficam como placeholders mínimos nesta tarefa; o escopo é as três camadas de infraestrutura (repos A, navegação/componentes B, auth+onboarding+importador C). Telas completas por feature são trabalho subsequente.
- Teste de integração do importador contra um Supabase real não roda no CI local; a verificação do importador é via `flutter analyze` + revisão de lógica. Se um fake/mocktail for viável sem servidor, adicionar teste de unidade da resolução de refs → UUID.
