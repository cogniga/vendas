# Documentação de classes — Camada core

> Regra do projeto: cada classe tem documentação única, atualizada a cada alteração.
> Este arquivo agrupa as classes da camada `core`. Classes de domínio, dados e
> features terão seus próprios documentos conforme forem criadas.

## documento_Ambiente
- **Arquivo:** `lib/core/config/ambiente.dart`
- **Responsabilidade:** expõe `SUPABASE_URL` e `SUPABASE_ANON_KEY` lidos via
  `--dart-define`; `supabaseConfigurado` indica se ambas foram informadas.
- **Observações:** nunca armazenar chaves no código.

## documento_SupabaseConfig
- **Arquivo:** `lib/core/config/supabase_config.dart`
- **Conteúdo:** `inicializarSupabase()` (chamado em `main`), `supabaseClientProvider`
  (expõe o `SupabaseClient`) e `authStateProvider` (stream de login/logout).

## documento_TelaConfigAusente
- **Arquivo:** `lib/core/config/tela_config_ausente.dart`
- **Responsabilidade:** tela exibida quando o Supabase não está configurado; orienta
  rodar o app com os `--dart-define`.

## documento_CoresApp
- **Arquivo:** `lib/core/theme/tokens.dart`
- **Responsabilidade:** `ThemeExtension` com os tokens de cor (design §7.1), variantes
  `claro` e `escuro`. Também define `Raios`, `Espacos` e a extensão `context.cores`.

## documento_TemaApp
- **Arquivo:** `lib/core/theme/tema_app.dart`
- **Responsabilidade:** monta `ThemeData` claro/escuro com Plus Jakarta Sans, tipografia
  do §7.2 e `tabularFigures` nos números.

## documento_TemaController
- **Arquivo:** `lib/core/theme/tema_provider.dart`
- **Responsabilidade:** `StateNotifier<ThemeMode>` que persiste a preferência de tema
  (Claro/Escuro/Auto) com `shared_preferences`. Exposto por `temaProvider`.

## documento_Formatos
- **Arquivo:** `lib/core/format/formatos.dart`
- **Responsabilidade:** formatação pt_BR (moeda, percentual, data, abelinhas) e parser
  de número que aceita vírgula. Coberto por `test/core/format/formatos_test.dart`.

## documento_PadraoEscrita
- **Arquivo:** `lib/core/format/padrao_escrita.dart`
- **Responsabilidade:** normalização de texto (§8): `titulo`, `frase`, `maius`.
  Coberto por `test/core/format/padrao_escrita_test.dart`.

## documento_BalcaoRevendaApp
- **Arquivo:** `lib/app.dart`
- **Responsabilidade:** raiz do app. Usa `MaterialApp.router` com
  `goRouterProvider`, mantém tema claro/escuro/auto e locale pt_BR. Quando o
  Supabase não está configurado, cai num `MaterialApp` simples exibindo
  `TelaConfigAusente`.

## documento_PageHeader
- **Arquivo:** `lib/core/widgets/page_header.dart`
- **Responsabilidade:** cabeçalho de página `PageHeader(title, subtitle?, actions)`.
  Título grande (headlineMedium), subtítulo opcional e ações à direita; em telas
  estreitas as ações descem de linha. Reproduz o `.head` do protótipo:
  `margin-bottom:24`, em tela larga título à esquerda e ações à direita na mesma
  linha alinhadas pela base (`align-items:flex-end`); subtítulo `margin-top:6`,
  cor muted, `max-width ~64ch` (≈512px).

## documento_KpiCard
- **Arquivo:** `lib/core/widgets/kpi_card.dart`
- **Responsabilidade:** `KpiCard(label, value, sub?)` — cartão de indicador com
  rótulo, valor em destaque (titleLarge tabular) e subtexto opcional.

## documento_KpiRow
- **Arquivo:** `lib/core/widgets/kpi_card.dart`
- **Responsabilidade:** `KpiRow(cartoes, larguraMinima=170)` — distribui os
  `KpiCard` em um `Wrap` calculando a largura por `LayoutBuilder` (equivalente a
  `flex 1 1 170px` do protótipo).

## documento_Pill
- **Arquivo:** `lib/core/widgets/pill.dart`
- **Responsabilidade:** `Pill(texto, tom)` com `enum TomPill{neutro,bom,atencao,
  ruim,destaque}` mapeando os pares good/goodSoft, warn/warnSoft, bad/badSoft,
  accent/accentSoft e surface2/ink.

## documento_PlatformPill
- **Arquivo:** `lib/core/widgets/platform_pill.dart`
- **Responsabilidade:** `PlatformPill(nome, cor)` — etiqueta com a cor hex da
  plataforma (`#RRGGBB`/`#AARRGGBB`); cai no `accent` do tema se o hex for
  inválido.

## documento_CodeChip
- **Arquivo:** `lib/core/widgets/code_chip.dart`
- **Responsabilidade:** `CodeChip(texto)` — chip de código (SKU, nº do pedido)
  estilo 11,5/600 com dígitos tabulares.

## documento_Abelinhas
- **Arquivo:** `lib/core/widgets/abelinhas.dart`
- **Responsabilidade:** `Abelinhas(qtd)` → `Text(Formatos.abelinhas(qtd))`
  (`1,5 🐝`). Não reimplementa a formatação.

## documento_IconAction
- **Arquivo:** `lib/core/widgets/icon_action.dart`
- **Responsabilidade:** `IconAction(icon, tooltip, onPressed, danger=false)` —
  botão só com ícone no visual `.iconbtn` do protótipo (quadrado 34x34, borda
  1px line, radius 8, fundo surface, ícone muted; hover → surface-2). Sempre com
  `Tooltip` e `Semantics(label: tooltip)` (acessibilidade obrigatória). `danger`
  pinta o ícone com `bad` e usa hover `bad-soft`.

## documento_ConfirmDeleteButton
- **Arquivo:** `lib/core/widgets/confirm_delete_button.dart`
- **Responsabilidade:** exclusão em duas etapas. Estado normal no visual
  `.iconbtn danger` (34x34, borda 1px line, radius 8, ícone `bad`, hover
  `bad-soft`). 1º clique troca para "Confirmar" (vermelho) por 3s via `Timer`;
  2º clique chama `onConfirm`. Acessível (`Tooltip`+`Semantics`).

## documento_Ledger
- **Arquivo:** `lib/core/widgets/ledger.dart`
- **Responsabilidade:** `Ledger(linhas, total?)` com `LinhaLedger(rotulo, valor,
  destaque?)` — bloco chave/valor com total destacado (cor accent).

## documento_MoneyField
- **Arquivo:** `lib/core/widgets/money_field.dart`
- **Responsabilidade:** `MoneyField(onChanged<Decimal?>)` — campo monetário que
  aceita vírgula e expõe o valor via `Formatos.parseDecimal` (null se inválido).

## documento_TextCaseField
- **Arquivo:** `lib/core/widgets/text_case_field.dart`
- **Responsabilidade:** `TextCaseField(caso)` com `enum CasoTexto{titulo,frase,
  maius}` — ao perder o foco normaliza o texto via `PadraoEscrita`.

## documento_ColunaLista
- **Arquivo:** `lib/core/widgets/responsive_list.dart`
- **Responsabilidade:** `ColunaLista<T>(label, builder, alinhamento?,
  principal=false)` — descreve uma coluna da `ResponsiveList`; `principal` vira
  título do cartão no modo estreito.

## documento_ResponsiveList
- **Arquivo:** `lib/core/widgets/responsive_list.dart`
- **Responsabilidade:** `ResponsiveList<T>(itens, colunas, acoes?,
  limiarCartao=780, semMoldura=false)` — decide por `LayoutBuilder` (largura do
  próprio widget): acima do limiar renderiza tabela (cabeçalho surface2, ações à
  direita), abaixo cartões (título=coluna principal, grade 4/2 colunas). Sem
  rolagem horizontal. Quando `semMoldura=true` a tabela NÃO desenha o próprio
  cartão (borda/fundo/radius) e usa os paddings do protótipo (th 10/14, td
  11/14), para ser usada dentro de um painel externo encostada à toolbar (sem
  borda dupla) — é o caso de Pedidos; as demais telas usam o default `false`.

## documento_AppShell
- **Arquivo:** `lib/core/widgets/app_shell.dart`
- **Responsabilidade:** `AppShell({required Widget child, required String
  rotaAtual})` (`ConsumerWidget`). Menu lateral fixo 264 (≥1100) / 240
  (760–1099); `<760` usa `Scaffold` com `AppBar` (botão ☰) + `Drawer`. Grupos
  Painel/Operação/Financeiro/Configuração, item ativo em accentSoft/accent com
  barra lateral; rodapé com seletor de tema (lê/escreve `temaProvider`).
  Navega com `context.go`. Decisão de largura central (`LayoutBuilder`). O
  conteúdo (`_Corpo`) rola em `SingleChildScrollView` alinhado ao TOPO, com
  padding do protótipo `main`: topo 32 / base 64 e laterais responsivas
  (`4vw`, 16–44) em tela larga; topo 20 / base 60 e laterais 16 no celular.
  Nunca centraliza o conteúdo verticalmente.

## documento_Rotas
- **Arquivo:** `lib/core/router/rotas.dart`
- **Responsabilidade:** constantes de caminho (design §4): `login`, `onboarding`,
  `painel`, `pedidos`/`pedidoNovo`/`pedido(id)`, `composicao`/`composicaoNova`/
  `composicaoItem(id)`, `produtos`, `insumos`, `investimento`, `caixa`,
  `plataformas`, `abelinhas`, `configuracoes`.

## documento_goRouterProvider
- **Arquivo:** `lib/core/router/app_router.dart`
- **Responsabilidade:** `goRouterProvider` (`Provider<GoRouter>`) com todas as
  rotas do §4 e um `ShellRoute` que envolve as rotas internas no `AppShell`.
  `redirect`: sem sessão → `/login`; com sessão e `empresaAtualProvider` sem
  empresa → `/onboarding`; evita loop. Reavalia via `refreshListenable` que
  escuta `authStateProvider` e `empresaAtualProvider`.

## documento_Placeholders_de_pagina
- **Arquivos:** `lib/features/<feature>/presentation/<feature>_page.dart`
- **Responsabilidade:** páginas mínimas (`PageHeader` + "Em construção") por rota
  interna: `PainelPage`, `PedidosPage`, `ComposicaoPage`, `ProdutosPage`,
  `InsumosPage`, `InvestimentoPage`, `CaixaPage`, `PlataformasPage`,
  `AbelinhasPage`, `ConfiguracoesPage`. `LoginPage` e `OnboardingPage` são
  placeholders TEMPORÁRIOS a serem substituídos pela FEAT-003.
