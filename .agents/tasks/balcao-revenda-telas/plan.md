# Plano de implementação — Balcão Revenda: as 10 telas internas

Contexto: app Flutter `sales` (imports `package:sales/...`), Flutter 3.35.7, lint
`very_good_analysis` (linhas <= 80 col). Baseline VERDE: `flutter analyze` sem
issues, 54 testes passando. Camadas prontas (core/domain/data). As 10 telas
internas hoje são placeholders `Em construção` em
`lib/features/<feature>/presentation/<feature>_page.dart` — este plano
substitui o CONTEÚDO de cada uma. Login local provisório (adm/adm) ativo —
NÃO remover nem depender dele. Trabalhar direto no repo, branch `main`, SEM
push.

Fontes da verdade (ler antes de cada tela): `.kiro/specs/balcao-revenda/
requirements.md` (R3..R14), `design.md` (§4 rotas/editores, §5 componentes,
§6 fórmulas já implementadas, §7 tokens/breakpoints §7.4, §8 escrita, §10
estados), `docs/prototipo/balcao-revenda.html` (comportamento/visual),
`docs/telas/*.png` (18 capturas).

Regras transversais (valem para TODOS os itens):
- REUTILIZAR, não reimplementar: cálculos em `lib/domain/calculos`
  (`taxas`, `produto_venda`/`calcularKit`, `pedido`/`calcularPedido`+
  `precoAutomatico`+`itensTaxaFixaAutomatico`, `abelinhas`
  `analisePorFaixa`/`analiseGeral`/`avisoAjusteManual`/`abelinhasProduto`/
  `abelinhasRegra`, `caixa` `rateio`/`saldoDestino`/`saldoTotal`, `painel`
  `kpisPainel`/`pontosAtencao`); formatação `lib/core/format` (`Formatos`
  moeda/percentual/data/abelinhas/parseDecimal; `PadraoEscrita`
  titulo/frase/maius); tokens `context.cores` (CoresApp), `Raios`, `Espacos`.
- Dinheiro sempre `Decimal` (nunca `double`); percentuais em pontos (20 = 20%).
- Componentes de `lib/core/widgets/` (USAR, não recriar): `PageHeader`,
  `KpiCard`/`KpiRow`, `Pill`(TomPill neutro|bom|atencao|ruim|destaque),
  `PlatformPill`, `CodeChip`, `Abelinhas`, `IconAction` (Tooltip+Semantics),
  `ConfirmDeleteButton` (3s), `Ledger`/`LinhaLedger`, `MoneyField`,
  `TextCaseField` (CasoTexto titulo|frase|maius), `ColunaLista`/
  `ResponsiveList` (tabela<->cartões por LayoutBuilder, limiarCartao ~780;
  listas largas ~990).
- Nenhuma rolagem horizontal; botão só-ícone com Tooltip+Semantics; excluir
  sempre com confirmação (`ConfirmDeleteButton` ou diálogo); textos de
  interface só com a 1ª letra maiúscula; idioma pt_BR.
- Estados §10: carregando (skeleton), vazio (mensagem + ação), erro (snackbar
  "Tentar de novo" SEM perder o formulário aberto).
- Sem Supabase dentro de widget: cada feature ganha `application/` com
  providers de estado (`FutureProvider`/`AsyncNotifier`/`StateNotifier`) que
  falam com os repositórios de `lib/data/repositorios/` (todos filtram por
  `empresa_id`; `empresaAtualProvider` dá a empresa ativa). Convenção dos
  repos: `criar/atualizar/salvar` retornam a entidade; novo registro passa
  `id=''`. Tabela de produtos = `produto_online` (D1).
- Editores (design §4): pedido e kit = painel lateral largo (até 1080px em
  desktop; tela cheia < 760px); formulários simples (produto, insumo,
  investimento, saque, retirada) = painel lateral 560px; rodapé fixo com
  Cancelar + ação primária.
- Documentação (regra do projeto): para cada classe/página/controller/widget
  novo, atualizar `docs/classes/` no estilo `documento_core.md` — usar
  `documento_features.md` (já existe) e, se ajudar, um arquivo por feature.
- Verificação a cada bloco: se criar `@riverpod`/`@freezed`, rodar
  `dart run build_runner build --delete-conflicting-outputs`; sempre
  `flutter analyze` (deve ficar limpo) e `flutter test` (manter os 54 +
  novos verdes). SDK Flutter em `/Users/raquel/Documents/sdk/flutter/bin`.

Padrão sugerido por feature (reduz retrabalho): um provider de dados por
feature (ex.: `produtosProvider` = `FutureProvider.autoDispose` que lê a
empresa via `empresaAtualProvider.future` e chama o repo), um controller de
mutação quando houver escrita (`StateNotifier<AsyncValue<void>>` no estilo de
`OnboardingController`/`AuthController`), e um widget de painel lateral
reutilizável (`PainelLateral`) para abrir formulários/editores com rodapé
fixo. Reaproveitar `estados`/skeletons entre telas via um helper comum em
`lib/core/widgets/` (ex.: `estado_lista.dart`).

---

## Bloco 0 — Helpers compartilhados das telas (base dos demais)

- [ ] 1. Criar os helpers de UI reutilizados por todas as telas.
      `PainelLateral` (Drawer/overlay à direita: largura 560 simples / até
      1080 largo; tela cheia < 760; rodapé fixo Cancelar + ação primária;
      abre via `showGeneralDialog`/`showModalBottomSheet` conforme largura) e
      um helper de estados de lista `EstadoLista` (skeleton/vazio/erro com
      callback "Tentar de novo") + util para erro em snackbar sem perder
      formulário. Documentar em `documento_features.md`.
      Files: `lib/core/widgets/painel_lateral.dart`,
      `lib/core/widgets/estado_lista.dart`, `docs/classes/documento_features.md`
      Verify: `flutter analyze` limpo; `flutter test` mantém 54 verdes.

## Bloco 1 — Produtos (R3)

- [ ] 2. Criar os providers/controllers de produtos em
      `lib/features/produtos/application/`: `produtosProvider`
      (`FutureProvider` que lê empresa + `produtoRepositoryProvider.listar`),
      dados de regra (`faixaAbelinhaRepositoryProvider.listar`) e
      configurações (`valorAbelinha`) necessários para abelinhas em tempo
      real; `ProdutoFormController` (`StateNotifier<AsyncValue<void>>`) com
      `criar/atualizar/excluir` que chamam o repo e invalidam
      `produtosProvider`. Excluir usa `kitsQueUsam` antes de confirmar (R3.9).
      Files: `lib/features/produtos/application/produtos_providers.dart`,
      `lib/features/produtos/application/produto_form_controller.dart`
      Verify: `dart run build_runner build --delete-conflicting-outputs` (se
      usar geradores); `flutter analyze` limpo; `flutter test` verde.

- [ ] 3. Substituir `produtos_page.dart` pela lista real (R3.7/R3.8):
      `ResponsiveList` com busca (código/nome/marca/fornecedor), filtro por
      categoria e contador "N de M"; cada linha: nome (destaque) + código/
      marca/categoria; custo + fornecedor; abelinhas com ✎ e pill "pela
      regra"/"ajustado" (amarela se manual abaixo da regra ou custo acima da
      última faixa, verde se acima); estoque + "N vendido(s)"; ações editar/
      excluir (`IconAction` + `ConfirmDeleteButton`). Estados §10.
      Files: `lib/features/produtos/presentation/produtos_page.dart`,
      `lib/features/produtos/presentation/widgets/*` (linha/cartão)
      Verify: `flutter analyze` limpo; `flutter test` verde.

- [ ] 4. Criar o formulário de produto em painel lateral 560px: campos do
      R3.1 com `TextCaseField` (nome/marca/fornecedor = titulo; código = maius;
      categoria/obs = frase), validação de nome+código, código único (trata
      `ErroRepositorio` do repo); quadro de abelinhas mostrando as calculadas
      pela regra em tempo real ("Calculado pela regra (custo R$ X)"), botão ✎
      que libera valor manual (múltiplos de 0,5) e "Voltar para a regra"; aviso
      de impacto via `avisoAjusteManual` (vermelho/amarelo/verde §6.7) com
      venda antes/depois, lucro/un, ROI antes/depois, mínimo sem prejuízo,
      "vezes mais" e kits afetados (`kitsQueUsam`). Salvar como "pela regra"
      quando manual == regra (R3.6).
      Files: `lib/features/produtos/presentation/produto_form.dart`,
      `lib/features/produtos/presentation/widgets/quadro_abelinhas.dart`
      Verify: `flutter analyze` limpo; `flutter test` verde; documentar as
      classes em `docs/classes/documento_features.md`.

## Bloco 2 — Regra de abelinhas (R9)

- [ ] 5. Criar `lib/features/abelinhas/application/abelinhas_providers.dart`
      (produtos + faixas + configurações) e `AbelinhasController` para o campo
      "Valor de 1 🐝" com debounce ~300ms (aceita vírgula via
      `Formatos.parseDecimal`) e `substituir` das faixas via
      `faixaAbelinhaRepositoryProvider`. Substituir `abelinhas_page.dart`:
      KPIs (ROI médio com "Como ler" + exemplo real, com lucro, com prejuízo,
      🐝 mínima sem prejuízo) de `analiseGeral`; `ResponsiveList` editável de
      faixas (custo até / abelinhas; adicionar/remover) usando
      `analisePorFaixa`; quadro "Quando dá lucro e quando dá prejuízo". O valor
      da abelinha salvo nas configurações (`configuracoesRepositoryProvider`).
      Recalcular ao digitar sem perder foco.
      Files: `lib/features/abelinhas/application/abelinhas_providers.dart`,
      `lib/features/abelinhas/application/abelinhas_controller.dart`,
      `lib/features/abelinhas/presentation/abelinhas_page.dart`,
      `lib/features/abelinhas/presentation/widgets/*`
      Verify: `flutter analyze` limpo; `flutter test` verde; documentar.

## Bloco 3 — Plataformas e taxas (R6)

- [ ] 6. Criar `lib/features/plataformas/application/plataformas_providers.dart`
      (`listarComFaixas`) e `PlataformasController` (`criar`, `renomear`,
      `atualizarAparencia` (cor), `excluir` (bloqueia se usada em pedidos/
      saques — tratar `ErroRepositorio` do repo), `substituirFaixas`).
      Substituir `plataformas_page.dart`: um cartão por plataforma com faixas
      editáveis (preço até / fixo / %), adicionar/remover faixas, e simulação
      de taxa e líquido para 19,99 / 59,90 / 89,90 / 149,90 / 249,90 (usar
      `taxa` de `calculos/taxas`); ações criar/renomear/cor/excluir
      (`ConfirmDeleteButton`, diálogo explicando bloqueio).
      Files: `lib/features/plataformas/application/plataformas_providers.dart`,
      `lib/features/plataformas/application/plataformas_controller.dart`,
      `lib/features/plataformas/presentation/plataformas_page.dart`,
      `lib/features/plataformas/presentation/widgets/*`
      Verify: `flutter analyze` limpo; `flutter test` verde; documentar.

## Bloco 4 — Compras de insumos (R7) e Investimento (R8)

- [ ] 7. Insumos (R7): providers + controller + tela.
      `lib/features/compras_insumos/application/*`
      (`compraInsumoRepositoryProvider`, `destinoRepositoryProvider` para "pago
      com"); `insumos_page.dart` com KPI "Total em insumos", `ResponsiveList`
      (compra em destaque: data·tipo·descrição; quantidade+pacotes; valor+valor
      por item; pago com; ações) e formulário em painel 560px com valor
      unitário (valor ÷ itens) ao vivo. Normalização: produto = titulo,
      descrição = frase. Estados §10.
      Files: `lib/features/compras_insumos/application/insumos_providers.dart`,
      `lib/features/compras_insumos/application/insumo_form_controller.dart`,
      `lib/features/compras_insumos/presentation/insumos_page.dart` (+ widgets)
      Verify: `flutter analyze` limpo; `flutter test` verde; documentar.

- [ ] 8. Investimento (R8): providers + controller + tela.
      `investimentoRepositoryProvider` + destinos; `investimento_page.dart` com
      KPIs (total investido; 3 maiores distribuidores com % do total — calcular
      no provider/controller a partir da lista), `ResponsiveList` (distribuidor:
      data·nota·obs; valor + % do total; pago com; ações) e formulário painel
      560px (distribuidor = titulo, nota = maius, obs = frase). Estados §10.
      Files: `lib/features/investimento/application/investimento_providers.dart`,
      `lib/features/investimento/application/investimento_form_controller.dart`,
      `lib/features/investimento/presentation/investimento_page.dart` (+ widgets)
      Verify: `flutter analyze` limpo; `flutter test` verde; documentar.

## Bloco 5 — Composição de custo / kits (R4) [editor largo]

- [ ] 9. Providers/controller de composição em
      `lib/features/composicao/application/`: lista de kits
      (`produtoVendaRepositoryProvider.listar`), produtos (para busca de itens),
      plataformas+faixas (`listarComFaixas`), faixas de abelinha, compras de
      insumo (para embalagem), pedidos (para "vendidos"), configurações (para
      valores iniciais); `KitEditorController` (estado local do kit em edição;
      recalcula via `calcularKit` por plataforma; `salvar`/`duplicar`/`excluir`
      via repo). Vendidos por plataforma = vendidos iniciais + kit em pedidos
      não cancelados (R4.7) — já coberto por `calcularKit(pedidos:)`.
      Files: `lib/features/composicao/application/composicao_providers.dart`,
      `lib/features/composicao/application/kit_editor_controller.dart`
      Verify: `flutter analyze` limpo; `flutter test` verde.

- [ ] 10. Substituir `composicao_page.dart` pela lista (R4.8): nome +
      composição ("5× SACHER"); investimento "N itens · X 🐝"; uma coluna por
      plataforma com lucro (verde/vermelho) e "cliente paga · margem"; ações
      abrir/duplicar/excluir. Rota larga: cartões já em 1200–1379 (§7.4).
      Files: `lib/features/composicao/presentation/composicao_page.dart`
      (+ widgets)
      Verify: `flutter analyze` limpo; `flutter test` verde.

- [ ] 11. Criar o editor de kit (painel lateral largo até 1080px; tela cheia
      < 760): itens (busca por código/nome, −/+ quantidade, qtd 0 remove,
      abelinhas por unidade/total, subtotal); custos adicionais (embalagem =
      escolher compra de insumo [usa valor unitário] ou manual; impressão;
      outros; iniciais vêm das configurações); preço base e metas (preço,
      desconto, cupom, concorrente, margem desejada %, meta de lucro, fatia
      ROAS); RESUMO fixo à direita (compra, embalagem, impressão, outros,
      investimento por venda, abelinhas + R$, lucro por plataforma com margem,
      "Melhor resultado: <plataforma>"); tabela "Resultado por plataforma" com
      overrides (preço/desconto/cupom; vazio = base como placeholder) e botão
      de preço sugerido que aplica o valor (`precoParaMargem`/`precoMinimo`).
      Recalcular ao digitar SEM perder foco (controllers estáveis). Duplicar e
      excluir. Tudo via `calcularKit`.
      Files: `lib/features/composicao/presentation/kit_editor.dart`
      (+ widgets: itens, custos, resumo, tabela por plataforma)
      Verify: `flutter analyze` limpo; `flutter test` verde; documentar as
      classes de composição em `docs/classes/documento_features.md` (ou
      `documento_composicao.md`).

## Bloco 6 — Pedidos (R5) [editor largo]

- [ ] 12. Providers/controller de pedidos em `lib/features/pedidos/
      application/`: lista (`pedidoRepositoryProvider.listar`, ordenar data
      desc), plataformas+faixas, produtos e kits (para itens e preço
      automático), faixas de abelinha, configurações; `PedidoEditorController`
      (estado local; `calcularPedido` em tempo real; `precoAutomatico`+
      `itensTaxaFixaAutomatico` quando novo e só kits; `salvar` grava snapshot
      por item [custo unitário + abelinhas unitárias]; "Atualizar custos pelo
      cadastro atual"; `excluir`).
      Files: `lib/features/pedidos/application/pedidos_providers.dart`,
      `lib/features/pedidos/application/pedido_editor_controller.dart`
      Verify: `dart run build_runner build --delete-conflicting-outputs` (se
      geradores); `flutter analyze` limpo; `flutter test` verde.

- [ ] 13. Substituir `pedidos_page.dart` pela lista (R5.7): colunas Pedido
      (cliente destaque; data·plataforma; pill se cancelado/devolvido), Itens
      (N itens; abelinhas), Venda (taxa), Líquido (custo; pill "est." se
      estimado), Lucro (margem), Ações (abrir/excluir); busca por cliente e
      filtro por plataforma; data desc. Estados §10.
      Files: `lib/features/pedidos/presentation/pedidos_page.dart` (+ widgets)
      Verify: `flutter analyze` limpo; `flutter test` verde.

- [ ] 14. Criar o editor de pedido (painel lateral largo até 1080px; tela
      cheia < 760): data (hoje)/cliente (maius)/plataforma/situação; itens
      (produtos e kits com quantidade); preço automático por plataforma e
      custos de envio automáticos quando só há kits (embalagem/impressão 0; se
      houver produto avulso voltam aos padrões — R5.2/R5.3); quando o usuário
      editar preço/itens cobrados, para o automático; líquido informado
      opcional; resumo (mercadoria, custos, custo total; abelinhas; venda; taxa
      estimada [% e fixo]; líquido estimado; líquido considerado pill
      informado/estimado; taxa efetiva; lucro; margem) via `calcularPedido`;
      aviso se líquido informado difere > R$0,50 da estimativa (R5.5); snapshot
      ao salvar; botão "Atualizar custos pelo cadastro atual".
      Files: `lib/features/pedidos/presentation/pedido_editor.dart`
      (+ widgets: itens, envio, venda, resumo)
      Verify: `flutter analyze` limpo; `flutter test` verde; documentar.

## Bloco 7 — Caixa e saques (R10)

- [ ] 15. Providers/controllers em `lib/features/caixa/application/`: destinos,
      saques (com rateio), retiradas, investimentos, compras de insumo,
      plataformas, pedidos (para "por plataforma"). `CaixaController`:
      editar destinos (nome/cor/%), validar soma 100%, salvar saque (gravando
      rateio do momento via `caixa.rateio`), salvar retirada, excluir saque/
      retirada. Substituir `caixa_page.dart`: KPIs (sacado/saídas/saldo via
      `saldoTotal`); cartões por destino (nome, %, saldo via `saldoDestino`,
      barra do que resta, entrou/saiu); "Destinos e percentuais" (editor) e
      "Por plataforma" lado a lado com MESMA altura; extrato (uma coluna por
      destino; só saques e retiradas excluem). Formulários saque (rateio ao
      vivo) e retirada em painel 560px. Avisar "Rateio soma X%" em vermelho se
      != 100%.
      Files: `lib/features/caixa/application/caixa_providers.dart`,
      `lib/features/caixa/application/caixa_controller.dart`,
      `lib/features/caixa/presentation/caixa_page.dart` (+ widgets)
      Verify: `flutter analyze` limpo; `flutter test` verde; documentar.

## Bloco 8 — Painel (R11)

- [ ] 16. Providers em `lib/features/painel/application/` (pedidos, plataformas
      +faixas, produtos, kits, destinos, saques) e filtro de período (este mês
      / todo o período). Substituir `painel_page.dart`: KPIs (faturamento (n
      pedidos), taxas (% do faturamento), líquido, custo, lucro (margem)) via
      `kpisPainel`; vendas por plataforma (barra bruto/líquido); pontos de
      atenção via `pontosAtencao`; caixa por destino com total sacado; itens
      mais vendidos (6). Grade 2 colunas de painéis (§7.5).
      Files: `lib/features/painel/application/painel_providers.dart`,
      `lib/features/painel/presentation/painel_page.dart` (+ widgets)
      Verify: `flutter analyze` limpo; `flutter test` verde; documentar.

## Bloco 9 — Configurações (R14, R12)

- [ ] 17. Providers/controller em `lib/features/configuracoes/application/`
      (`configuracoesRepositoryProvider`, tema, export/import). Substituir
      `configuracoes_page.dart`: padrões de custo (embalagem/impressão), valor
      da abelinha, seletor de tema (reusa `temaProvider`); exportar/importar
      JSON da empresa (coletar via repos → `json.encode`; importar lê e grava);
      quadro "Padrão de escrita" com regras e exemplos (§8); botão Sair
      (`authControllerProvider.notifier.sair`); "Importar dados da planilha" só
      quando a empresa estiver vazia (reusa `importadorSeedProvider`; checar
      vazio contando produtos/pedidos).
      Files: `lib/features/configuracoes/application/configuracoes_providers.dart`,
      `lib/features/configuracoes/application/configuracoes_controller.dart`,
      `lib/features/configuracoes/presentation/configuracoes_page.dart`
      (+ widgets)
      Verify: `flutter analyze` limpo; `flutter test` verde; documentar.

## Bloco 10 — Integração e testes de widget

- [ ] 18. Verificação cruzada e testes de widget: garantir que nenhuma tela
      tem overflow horizontal em 1440/1000/400px (no estilo de
      `test/widgets/responsive_list_test.dart`); testar ao menos um fluxo por
      tela pesada (editor de kit recalcula sem perder foco; editor de pedido
      com preço automático; aviso de ajuste manual de abelinhas). Rodar o
      conjunto completo.
      Files: `test/widgets/*_page_test.dart` (novos)
      Verify: `dart run build_runner build --delete-conflicting-outputs`;
      `flutter analyze` limpo; `flutter test` — 54 baseline + novos verdes.

---

Observações / suposições:
- Navegação já existe (go_router + AppShell); apenas o conteúdo das páginas
  muda. Os editores de pedido/kit abrem como painel lateral largo a partir das
  rotas `/pedidos/novo|:id` e `/composicao/novo|:id` (já mapeadas) OU como
  overlay a partir da lista — escolher overlay/painel lateral para manter o
  AppShell visível, conforme protótipo; manter as rotas funcionando.
- "Por plataforma" no caixa (R10.5): líquido dos pedidos por plataforma × o
  sacado por plataforma, colunas alinhadas; derivar no provider a partir de
  pedidos e saques.
- Export/import JSON (R14.2): reaproveitar o formato/leitura do seed quando
  fizer sentido; o import de JSON da empresa é adicional ao import do seed.
