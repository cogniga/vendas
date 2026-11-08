# Plano: Painel (dashboard) do Balcão Revenda

Fonte da verdade: `docs/prototipo/balcao-revenda.html` (`V.painel`, linha ~454; CSS linhas 66-153). Nenhuma migration necessária.

## Achados da exploração (base das decisões)

- `lib/features/painel/presentation/painel_page.dart` é um placeholder. Rota `Rotas.painel = '/'` já aponta para `PainelPage` em `lib/core/router/app_router.dart`; rota do caixa é `Rotas.caixa`. Para navegar use `context.go(Rotas.caixa)` (import `lib/core/router/rotas.dart`).
- `lib/domain/calculos/painel.dart` já tem `KpisPainel`/`kpisPainel` (só `concluido`) e `pontosAtencao`/`PontoAtencao`. `pontosAtencao` NÃO está em uso nem testado (grep em lib e test), então pode ser reescrito. Os textos atuais divergem do protótipo e devem ser trocados.
- `painel.freezed.dart` é gerado: depois de mudar classes `@freezed`, rodar `dart run build_runner build --delete-conflicting-outputs`.
- `Pedido.itens` (`PedidoItem`: `tipo` = produto|produtoVenda, `quantidade`, `produtoId`, `produtoVendaId`, snapshots `custoUnitario`/`abelinhasUnitarias`). Pedido não guarda o nome do item: resolver por `produtosProvider` / `kitsProvider`, com fallback `(produto removido)` / `(kit removido)` (igual ao protótipo `linhaNome`).
- `Produto` NÃO tem `estoqueMin`. Só existe `estoque` e `unidade`. O alerta "Estoque baixo" do protótipo não é implementável sem migration. Decisão D7: omitir esse alerta (registrar em `docs/decisoes.md`). Não criar migration sem pedido do usuário.
- `Destino` tem `nome`, `cor` (hex), `percentual`. Saldo por destino: `saldoDestino(id, saques:, investimentos:, comprasInsumo:, retiradas:)` em `caixa.dart` (campos `entradas`/`saidas`/`saldo`), igual a `destSaldo` do protótipo. Saque tem `.valor` e `.rateio`.
- `calcularPedido(pedido, faixas)` dá `taxaEfetiva`, `liquido`, `custo`, `lucro` = os valores `taxaReal`/`liq`/`custo`/`lucro` de `pedCalc` do protótipo.
- `calcularKit(kit, produtosPorId, plataforma, faixas, faixasAbelinha)` devolve `lucro`, `margem` (= lucro/liquido, igual ao protótipo), `investimento`; `precoMinimo(faixas, investimento)` em `taxas.dart`.
- Dados do painel já existem em providers: `pedidosProvider`, `plataformasComFaixasProvider` (Map<Plataforma, List<FaixaTaxa>>), `produtosProvider`, `kitsProvider`, `faixasAbelinhaProvider` (todos em `pedidos_providers.dart`), `destinosCaixaProvider`, `saquesProvider`, `investimentosCaixaProvider`, `insumosCaixaProvider`, `retiradasProvider` (em `caixa_providers.dart`). `dadosCaixaProvider` já agrega o caixa.
- Para abrir o editor: `showDialog<bool>(context, builder: (_) => PedidoEditor(pedido: null))` e, se retornar true, `ref.invalidate(pedidosProvider)` (padrão de `PedidosPage._abrirEditor`, `lib/features/pedidos/presentation/pedido_editor.dart`).
- Widgets: `PageHeader(title, subtitle, actions)` (empilha ações abaixo de 600px), `KpiCard`/`KpiRow` (largura mínima 170, `Wrap`, gap 12; falta cor `neg` no valor), `Pill(texto, tom: TomPill.bom|atencao|ruim)`, `BotaoPequeno` (OutlinedButton 12.5px), `corDoDestino(context, hex)` em `lib/features/caixa/presentation/cor_destino.dart`, `PlatformPill._parseCor` (privado). Tokens: `context.cores` (bg, surface, surface2, ink, muted, line, accent, accentInk, accentSoft, good/goodSoft, warn/warnSoft, bad/badSoft), `Raios.controle=8`, `Raios.cartao=14`, `Raios.pill=6`, `Espacos`. `Formatos.moedaDecimal`, `Formatos.percentualFracao` (usa 1 casa), `Formatos.data`.
- `AppShell._Corpo` já faz o scroll e o padding da página. A página não pode usar `ListView`.
- O painel de `caixa_page.dart` (`_Painel`, privado) usa padding 16; o protótipo usa header 16/20 e body 20. Criar widget compartilhado em vez de duplicar (ver item 3).

## Decisões

- D7 (alerta de estoque omitido): o produto não tem `estoque_min`. O alerta fica fora do painel e a omissão é documentada em `docs/decisoes.md`. Se o usuário quiser, uma migration futura adiciona a coluna.
- D8 (período e situação): o filtro "Este mês" compara ano e mês de `pedido.data` com hoje (`yyyy-MM`); "Todo o período" não filtra. Padrão = "Todo o período" (igual ao protótipo `UI.periodo='tudo'`). Pedidos considerados = `situacao == concluido` (spec design §6.5 e `kpisPainel` existente; o protótipo exclui apenas "Cancelado", e `devolvido` não existe lá). Estado do período fica em um `StateProvider<PeriodoPainel>` em `painel_providers.dart` (sobrevive a rebuilds e fica fora do widget).
- D9 (alertas): reescrever `pontosAtencao` para reproduzir exatamente as mensagens e a gravidade do protótipo (campo `gravidade`: `ruim` ou `atencao`). Itens com gravidade `ruim` usam fundo `badSoft`/texto `bad`; os demais `warnSoft`/`warn`.
- D10 (render): `PainelPage` é `ConsumerWidget`; usa `dadosPainelProvider.valueOrNull`; spinner só na primeira carga; erro mostra caixa com "Tentar de novo". Nada de Supabase em widget.

## Lógica exata do protótipo (transcrita para Dart)

Período:
```
now = hoje.yyyy-MM
peds = ativos().filter(o => periodo == 'tudo' || o.data.yyyy-MM == now)
```
Por pedido (c = calcularPedido): `fat += precoVenda`, `tx += c.taxaEfetiva`, `liq += c.liquido`, `cus += c.custo`, `luc += c.lucro`.

Por plataforma: `porPlat[plataformaId] = {fat += precoVenda, liq += c.liquido, n++}` (ordem de inserção = ordem em que aparecem nos pedidos filtrados). `maxF = max(1, max(fat))`. Barra do protótipo: grid `120px | 1fr | 110px` (90 | 1fr | 90 abaixo de 480px), track 8px `surface2` pill, fill `width = fat/maxF`, cor da plataforma, opacidade .9; texto direito: bruto (w600) e abaixo `<líquido> líq.` muted 12px w400.

Atenção (ordem de inserção):
1. se `|Σ percentual dos destinos - 100| > 0.01` → ruim: `Os destinos do caixa somam {soma}% . Ajuste para 100% em Caixa e saques.` (soma sem casas supérfluas: `100` → `100`, `95.5` → `95,5`; formato `Formatos.numero` sem zeros finais; manter sem espaço antes do `%`: `somam 95,5%.`).
2. para cada kit, para cada plataforma `rs = {p, calcularKit}`; `neg = lucro < 0`; `low = lucro >= 0 && margem < 0.15`.
   - se `neg` não vazio → ruim: `“{kit.nome}” dá prejuízo em {Nome (mín. R$ x)}, ….` (aspas curvas “ ”, mínimo = `precoMinimo(faixas, investimento)` em `Formatos.moedaDecimal`, separados por `, `).
   - se `low` não vazio → atencao: `“{kit.nome}” tem margem baixa em {Nome (10,2%)}, ….` (percentual com `Formatos.percentualFracao`).
3. (omitido, D7) estoque baixo.
4. códigos repetidos → atencao: `Códigos repetidos no cadastro: A, B. Cada código deve ser único.`

Badge do painel: `alerts.isNotEmpty ? Pill(count, tom: atencao) : Pill('Tudo certo', tom: bom)`. Vazio: `Nenhum alerta.`

Itens mais vendidos: para cada linha do pedido filtrado `chave = tipo + ref`, `topo[chave] = {nome, q += quantidade}`; ordenar por `q` desc; `take(6)`. Atenção: o protótipo soma `l.qtd`, NÃO multiplica pela quantidade do kit. Em Dart, a chave é `tipo.name + (produtoId ?? produtoVendaId)`; a ordenação deve ser estável (empates mantêm ordem de inserção, `sort` do Dart não é estável: ordenar por (q desc, índice de inserção asc)). Tabela: colunas `Item` | `Unid.` (direita, `n`); vazio `Sem vendas.`

Caixa por destino: para cada destino linha `● {nome} {percentual}%` (percentual muted) e saldo à direita em negrito (`bad` quando < 0); ao final linha total (`Total sacado das plataformas`, Σ saques.valor) sem divisória, `margin-top:6px`, padding `12px 14px`, raio 8, fundo `surface2`, fonte 15 w600. Botão `Abrir caixa` (pequeno, outlined) no header do painel navega para `Rotas.caixa`.

KPIs (R$ com `Formatos.moedaDecimal`):
- Faturamento / `{n} pedido(s)`
- Taxas das plataformas / `{pc(tx/fat)} do faturamento` (fat = 0 → `— do faturamento`)
- Líquido recebido / `vai para a carteira`
- Custo dos pedidos / `produto + embalagem`
- Lucro (valor em `bad` se < 0) / `margem {pc(luc/fat)}` (fat = 0 → `margem —`)

## CSS a reproduzir (tokens já existentes em `tokens.dart`)

- `.head`: margin-bottom 24; h1 26/600, letter-spacing -.02em; p muted, margin-top 6, max 64ch. (Já em `PageHeader`.)
- `.btn`: padding 8x14, raio 8 (`Raios.controle`), borda 1 `line`, fonte 13.5/500. `.btn.primary` fundo `accent`, texto `accentInk`. `.btn.sm`: padding 5x10, fonte 12.5. Usar `FilledButton.icon` com Lucide `plus` como em `PedidosPage` para "Novo pedido" (consistência com o resto do app) e `BotaoPequeno` para "Abrir caixa".
- `.tabs` (segmentado): usar o mesmo estilo de toggle já usado no app. Procurar antes por widget existente (ex.: `grep -rn "aria-pressed\|SegmentedButton\|ToggleButtons" lib`). Se não existir, criar `lib/core/widgets/seletor_segmentado.dart` (ver item 3). Ler `.tabs` do CSS (linhas 150-170 do HTML) antes de implementar e copiar fundo/raio/padding/estado selecionado.
- `.kpis`: flex-wrap gap 12, `margin-bottom:16`, cada `flex:1 1 170px`. `.kpi`: fundo `surface`, borda 1 `line`, raio `Raios.cartao`, padding `16x18`, gap 6, rótulo 12.5 muted w500, valor 22 w600 tabular-nums letter-spacing -.02em, sub 12 muted. Hoje `KpiCard` usa padding 16 e `titleLarge`; ajustar `KpiCard` com parâmetros opcionais (`valorTom`) sem quebrar Caixa/outros usos. Conferir `titleLarge` no tema; se não for 22/600, passar `TextStyle` explícito só se necessário.
- `.grid.g2`: `repeat(auto-fit, minmax(min(100%,340px), 1fr))`, gap 16. Implementar em widget `GradeAutoFit` (item 3): calcula `colunas = max(1, floor((largura + 16) / (340 + 16)))` limitado a 4 painéis; usa `Wrap`/`Row` de `Expanded` por linha, SEM `IntrinsicHeight`. Cada célula tem largura fixa `(largura - 16*(c-1))/c`. Com 4 painéis em 1180px de conteúdo: 3 colunas, e o 4º painel vai para a linha seguinte (igual ao protótipo e ao print `docs/telas/01-painel.png`). Conferir no print.
- `.panel`: fundo `surface`, borda 1 `line`, raio `Raios.cartao`, sombra `0 1px 2px rgba(16,24,40,.04)` (claro) / `rgba(0,0,0,.3)` (escuro), `overflow:hidden`. `header`: padding 16x20, borda inferior 1 `line`, h2 15/600, hint muted. `.body`: padding 20.
- `.note`: fonte 13, padding 10x14, raio 8, fundo `warnSoft`, texto `warn`, line-height 1.45; variante ruim fundo `badSoft`, texto `bad`. Gap entre alertas 8.
- `.empty`: padding 32x16, centralizado, muted.
- `.ledger .row`: padding 8x0, borda inferior 1 `line` (última antes do total sem borda), tabular-nums. `.dot` 8x8 círculo.
- `.pill`: 12/500, padding 2x9, raio 6 (já em `Pill`).
- Tabela de itens: reaproveitar estilo de células das tabelas (padding e cabeçalho) de `responsive_list.dart` / `pedidos_page.dart`; sem rolagem horizontal; em largura estreita a tabela de 2 colunas cabe sem scroll.
- Dark: usar sempre `context.cores`, nada de cor fixa (exceto cor da plataforma/destino vinda do banco). Referências: `docs/telas/01-painel.png`, `15-painel-escuro.png`, `16-celular-menu.png`.

## Arquivos

Criar:
- `lib/domain/calculos/painel_periodo.dart` (ou estender `painel.dart`; preferir estender `painel.dart` para manter o agrupamento do painel): funções puras
  - `enum PeriodoPainel { mes, tudo }`
  - `List<Pedido> filtrarPedidosPeriodo(List<Pedido>, PeriodoPainel, DateTime hoje)` (concluídos + período).
  - `class VendaPlataforma { plataformaId, bruto, liquido, pedidos }` e `List<VendaPlataforma> vendasPorPlataforma(List<Pedido>, Map<String, List<FaixaTaxa>> faixasPorPlataforma)`.
  - `class ItemVendido { nome, quantidade }` e `List<ItemVendido> itensMaisVendidos(List<Pedido>, {Map<String,String> nomesProdutos, Map<String,String> nomesKits, int limite = 6})`.
  - `class SaldoDestinoPainel` não é necessário: usar `saldoDestino` de `caixa.dart` direto na camada de providers (item 4).
  - Reescrever `pontosAtencao(...)` com a lógica acima; `PontoAtencao` ganha `GravidadeAtencao gravidade` (`ruim|atencao`); manter assinatura de parâmetros + usar `kits`, `plataformas`, `faixasPorPlataforma`, `faixasAbelinha`, `produtosPorId`, `destinos`, `produtos`.
- `lib/features/painel/application/painel_providers.dart`:
  - `periodoPainelProvider = StateProvider<PeriodoPainel>((_) => PeriodoPainel.tudo)`.
  - `class DadosPainel` com tudo que a tela precisa já calculado: `kpis`, `qtdPedidos`, `vendasPlataforma` (+ nome/cor da plataforma resolvidos), `pontos`, `destinosComSaldo` (lista de `(Destino, Decimal saldo)`), `totalSacado`, `topItens`.
  - `dadosPainelProvider = FutureProvider<DadosPainel>`: `await ref.watch(...future)` de `pedidosProvider`, `plataformasComFaixasProvider`, `produtosProvider`, `kitsProvider`, `faixasAbelinhaProvider`, `dadosCaixaProvider` (que já agrega destinos/saques/investimentos/insumos/retiradas) e `ref.watch(periodoPainelProvider)`; `empresaAtualProvider` indiretamente via os providers. Calcular com as funções puras. Empresa nula → providers devolvem listas vazias (sem crash).
  - Nota: `periodoPainelProvider` mudando recalcula; para não piscar spinner, a página usa `valueOrNull` (valor anterior mantido durante o reload do FutureProvider). Alternativa preferida para troca de período instantânea: expor `dadosBrutosPainelProvider` (FutureProvider dos dados) e `dadosPainelProvider = Provider<AsyncValue<DadosPainel>>` derivado de `ref.watch(brutos)` + período, de modo que a troca do toggle seja síncrona. Implementar essa variante.
- `lib/features/painel/presentation/painel_page.dart` (substituir placeholder) + widgets privados ou separados em `lib/features/painel/presentation/` (`painel_kpis.dart`, `painel_paineis.dart` se o arquivo passar de ~350 linhas).
- `lib/core/widgets/painel_card.dart` (nome da classe `PainelCard`): painel com header (título 15/600, hint/ação à direita) + corpo com padding 20; parâmetros `titulo`, `trailing`, `corpo`, `semPaddingCorpo`. Uso futuro: migrar `_Painel` de `caixa_page.dart` é opcional e fora do escopo.
- `lib/core/widgets/grade_paineis.dart` (`GradePaineis`): grade auto-fit descrita acima.
- `lib/core/widgets/seletor_segmentado.dart` (`SeletorSegmentado<T>`) somente se não houver equivalente; com `Semantics(selected:)` e `Tooltip` desnecessário (tem texto). Altura mínima de toque 40px (acessibilidade).
- Docs: `docs/classes/documento_PainelPage.md`, `documento_DadosPainel.md`, `documento_PainelCard.md`, `documento_GradePaineis.md`, `documento_SeletorSegmentado.md` (se criado), `documento_VendaPlataforma.md`, `documento_ItemVendido.md`, `documento_PontoAtencao.md`. Antes de escrever, ver o formato dos arquivos existentes em `docs/classes/` (hoje agrupados em `documento_core.md`, `documento_dados.md`, `documento_dominio.md`, `documento_features.md`; seguir a regra do usuário de um arquivo por classe `documento_<NomeDaClasse>.md` com o mesmo formato "Arquivo / Responsabilidade / Provider"). Atualizar também `documento_KpiCard` se existir referência (grep) quando `KpiCard` mudar.
- Testes:
  - `test/domain/calculos/painel_test.dart` (estender): período (mês: pedido de outro mês/ano excluído; tudo: inclui; cancelado/devolvido excluídos); `vendasPorPlataforma` (soma bruto e líquido, contagem, ordem de inserção, lista vazia); `itensMaisVendidos` (agrupa produto e kit separados, soma quantidades, ordena desc, limite 6, empate estável, nome removido); `pontosAtencao` (destinos ≠ 100 → ruim e texto; ≈100 dentro de 0.01 → sem alerta; kit com prejuízo → texto com “aspas” e `mín. R$ x,xx`; kit com margem baixa → texto `(10,2%)`; margem exatamente 15% → sem alerta; kit sem plataformas → sem alerta; códigos repetidos → texto exato; tudo ok → lista vazia); KPIs com pedidos vazios (margem zero, sem exceção); vetor §6.5 já coberto.
  - `test/features/painel/painel_providers_test.dart` ou `test/widgets/painel_page_test.dart`: widget test com `ProviderScope(overrides: [...])` dos providers de dados: (a) renderiza título, subtítulo, 5 KPIs, 4 painéis com dados; (b) estado vazio mostra `Nenhum pedido no período.`, `Nenhum alerta.`, `Sem vendas.` e `— do faturamento` / `margem —`; (c) alternar `Este mês`/`Todo o período` muda o KPI de faturamento; (d) tocar `Abrir caixa` navega para a rota do caixa (usar `GoRouter` mínimo de teste); (e) larguras 360, 800 e 1280 sem `RenderFlex overflow` e sem exceção (`tester.view.physicalSize`); (f) tema escuro sem exceção. Seguir o padrão dos testes em `test/widgets` e `test/features` existentes (conferir overrides usados lá com `mocktail`).

Modificar:
- `lib/core/widgets/kpi_card.dart`: padding 16x18, tipografia (rótulo 12.5 w500 muted, valor 22 w600 tabular-nums, sub 12), parâmetro opcional `valorNegativo` (cor `bad`). Garantir que Caixa e demais telas seguem compilando e testes de widget existentes passam.
- `lib/domain/calculos/painel.dart` (acima) e regenerar `painel.freezed.dart`.
- `docs/decisoes.md`: acrescentar D7 (estoque baixo omitido), D8 (período e situações) e D9 (textos dos alertas / gravidade).
- `.kiro/specs/balcao-revenda/tasks.md`: marcar a tarefa do Painel como concluída, se houver item correspondente.

## Itens ordenados

- [ ] 1. Domínio puro: estender `lib/domain/calculos/painel.dart` com `PeriodoPainel`, `filtrarPedidosPeriodo`, `VendaPlataforma`/`vendasPorPlataforma`, `ItemVendido`/`itensMaisVendidos`, e reescrever `pontosAtencao` com a gravidade e os textos do protótipo. Usar `dividir` (zero-safe) em qualquer divisão. Rodar `dart run build_runner build --delete-conflicting-outputs`.
      Files: `lib/domain/calculos/painel.dart`, `lib/domain/calculos/painel.freezed.dart` (gerado)
      Verify: `flutter analyze lib/domain` sem erros.

- [ ] 2. Testes de unidade do domínio (lista em "Testes" acima).
      Files: `test/domain/calculos/painel_test.dart`
      Verify: `flutter test test/domain/calculos/painel_test.dart` passa.

- [ ] 3. Widgets compartilhados: `PainelCard`, `GradePaineis`, `SeletorSegmentado` (se não houver equivalente); ajustar `KpiCard`. Sem `IntrinsicHeight`, sem `ListView`, sem `MediaQuery` espalhado (usar `LayoutBuilder` dentro do widget central).
      Files: `lib/core/widgets/painel_card.dart`, `lib/core/widgets/grade_paineis.dart`, `lib/core/widgets/seletor_segmentado.dart`, `lib/core/widgets/kpi_card.dart`
      Verify: `flutter analyze` e `flutter test` (testes de widget existentes de Caixa/Pedidos continuam passando).

- [ ] 4. Providers: criar `painel_providers.dart` (período, dados brutos assíncronos, `DadosPainel` derivado síncrono ao período).
      Files: `lib/features/painel/application/painel_providers.dart`
      Verify: `flutter analyze lib/features/painel`; teste de provider com overrides (item 6) passa.

- [ ] 5. Página: substituir `painel_page.dart` com cabeçalho (toggle + "Novo pedido" abrindo `PedidoEditor` e invalidando `pedidosProvider`/`dadosBrutosPainelProvider` ao salvar), `KpiRow` com 5 cartões, `GradePaineis` com 4 `PainelCard`s, estados vazios, `valueOrNull` sem spinner flash, erro com "Tentar de novo". Todos os botões só-ícone (se houver) com `Tooltip`+`Semantics`.
      Files: `lib/features/painel/presentation/painel_page.dart` (+ arquivos auxiliares da mesma pasta)
      Verify: `flutter analyze`; `flutter build macos --debug --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...` compila (valores de `env/supabase.json` via `--dart-define-from-file` se existir).

- [ ] 6. Testes de widget/provider do Painel (lista em "Testes" acima).
      Files: `test/widgets/painel_page_test.dart` (ou `test/features/painel/...`, seguindo o padrão existente)
      Verify: `flutter test test/widgets` passa.

- [ ] 7. Documentação: arquivos `docs/classes/documento_<Classe>.md` das classes novas/alteradas, `docs/decisoes.md` (D7-D9), `tasks.md` do spec.
      Files: ver "Arquivos"
      Verify: revisão manual do formato contra um documento existente; `flutter analyze` ainda limpo.

- [ ] 8. Verificação final: `flutter analyze`, `flutter test` (suíte completa), e comparação visual com `docs/telas/01-painel.png`, `15-painel-escuro.png`, `16-celular-menu.png` (rodar o app/macOS se possível; o que não puder ser verificado visualmente deve ser dito).
      Verify: `flutter analyze && flutter test` sem falhas.

## Riscos / pontos de atenção

- Não usar `IntrinsicHeight` em linhas de painéis com `LayoutBuilder` (causa travamento já visto no app; ver `abelinhas_page`). Altura dos painéis na mesma linha é livre (como o `align-items:start` padrão do grid do protótipo: no CSS grid os itens esticam; aceitar alturas diferentes é preferível a risco de crash; se necessário igualar, fazer isso com `Row(crossAxisAlignment: stretch)` apenas SEM `IntrinsicHeight` e sem filhos com `LayoutBuilder` dentro; senão deixar alturas livres).
- `Decimal` nunca vira `double` para cálculo; só na formatação via `Formatos.moedaDecimal`.
- `Formatos.percentualFracao` recebe `num`; converter o `Decimal` margem com `.toDouble()` só para exibir.
- Evitar `ref.watch(...).when(loading)` na tela: usar `valueOrNull`.
- Comandos: `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, `flutter analyze`, `flutter test`.
