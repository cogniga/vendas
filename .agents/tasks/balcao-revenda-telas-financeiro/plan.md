# Implementation Plan — Telas do grupo FINANCEIRO (Balcão Revenda)

Implementar as 3 telas do grupo FINANCEIRO seguindo fielmente o protótipo
(`docs/prototipo/balcao-revenda.html`): COMPRAS DE INSUMOS (R7),
INVESTIMENTO (R8) e CAIXA E SAQUES (R10). Ordem: Insumos → Investimento →
Caixa (do simples ao complexo).

## Decisões de design (fundamentadas no código lido)

- **Raiz de cada `*_page.dart` = `Column(mainAxisSize: min, crossAxisAlignment:
  stretch)`**, nunca `ListView`/scroll vertical externo — o `AppShell._Corpo`
  (lib/core/widgets/app_shell.dart) já envolve o `child` num
  `SingleChildScrollView`. Confirmado lendo o arquivo. Estados de loading usam
  `Padding(... CircularProgressIndicator())`, não `Center`/`Expanded` soltos.
- **Estado por feature:** criar `features/<feature>/application/*_providers.dart`
  com `FutureProvider`s que leem `empresaAtualProvider` e retornam `[]` quando
  a empresa é `null`, exatamente como `pedidos_providers.dart`. Não tocar em
  `empresaAtualProvider`.
- **Formulários simples (Insumos, Investimento, Saque, Retirada):** painel
  lateral 560px via `abrirPainelLateral` + `CorpoPainelLateral` + `RodapePainel`
  (padrão de `produto_form.dart`). O editor de pedido usa `showDialog`+`Dialog`
  largo porque é complexo; os formulários financeiros são simples, então painel
  lateral é a escolha certa (design §4).
- **Listas:** `ResponsiveList<T>` com `ColunaLista` (vira cartões no estreito,
  sem rolagem horizontal). O Extrato do Caixa tem uma coluna por destino
  (número de colunas dinâmico) — também via `ResponsiveList` com `colunas`
  construídas a partir da lista de destinos.
- **Cálculos:** reutilizar `lib/domain/calculos/caixa.dart` (`rateio`,
  `saldoDestino`, `saldoTotal`, `entradasDestino`, `saidasDestino`) e
  `calcularPedido` para o líquido por plataforma. Não reimplementar.
- **Edição de destinos (percentuais/cor/nome):** vive na própria tela de Caixa
  (confirmado: não existe editor de destinos em `features/configuracoes`).
  Controller próprio com estado local + `destinoRepositoryProvider`.
- **Rateio ao salvar saque:** o `SaqueRepository.salvar` grava o snapshot de
  rateio; montamos `saque.copyWith(rateio: rateio(saque, destinos))` antes de
  salvar.

## Assinaturas confirmadas (lidas no código)

- `PageHeader(title:, subtitle?, actions: <Widget>)`, `KpiCard(label:, value:,
  sub?)`, `KpiRow(cartoes: <KpiCard>, larguraMinima?)`.
- `Pill(String texto, {TomPill tom})` posicional; `TomPill.{neutro,bom,atencao,
  ruim,destaque}`. `PlatformPill(nome:, cor:)`.
- `ResponsiveList<T>(itens:, colunas:, acoes?, limiarCartao=780)`;
  `ColunaLista<T>(label:, builder:, alinhamento?, principal=false)`.
- `IconAction(icon:, tooltip:, onPressed:, danger=false)`;
  `ConfirmDeleteButton(onConfirm:, tooltip?)`.
- `MoneyField(onChanged:(Decimal?), label?, initial?, controller?, prefix?)`;
  `TextCaseField(caso: CasoTexto.{titulo,frase,maius}, controller?, label?,
  initial?, onChanged?)`.
- `abrirPainelLateral<T>(context, titulo:, corpo:(ctx, fechar(T?))=>Widget,
  largura=560, largo=false)`; `CorpoPainelLateral(corpo:, rodape:)`;
  `RodapePainel(rotuloPrimario:, aoConfirmar:, aoCancelar:, carregando=false)`.
- `Formatos.moedaDecimal/moeda/percentual/percentualFracao/data/numero/
  parseDecimal`. `Espacos.{base,g8,g12,g16,g20,paddingPainel}`, `Raios.{cartao,
  controle,pill}`, `context.cores` (CoresApp: surface, surface2, line, ink,
  muted, good, bad, warn, accent + *Soft).
- Entidades: `CompraInsumo{id,empresaId,data,produto,valorTotal,tipo='Embalagem',
  descricao,pacotes=1,itens=1,destinoId?}`;
  `Investimento{id,empresaId,data,distribuidor,valor,nota,destinoId?,obs}`;
  `Saque{id,empresaId,data,plataformaId,valor,obs,rateio}`;
  `SaqueRateio{saqueId,empresaId,destinoId,percentual,valor}`;
  `Retirada{id,empresaId,data,destinoId,valor,descricao}`;
  `Destino{id,empresaId,nome,cor,percentual,ordem}`.
- Repos (todos com `empresa_id`): `compraInsumoRepositoryProvider`,
  `investimentoRepositoryProvider`, `saqueRepositoryProvider`,
  `retiradaRepositoryProvider`, `destinoRepositoryProvider`,
  `plataformaRepositoryProvider.listarComFaixas`, `pedidoRepositoryProvider`.
- Convenção `id=''` em criar/salvar para novo registro.

## Comandos de verificação (reais do projeto)

- `flutter analyze` → "No issues found!" (lint very_good_analysis, linhas ≤80).
- `flutter test` → suíte verde (57 testes hoje).
- `dart run build_runner build --delete-conflicting-outputs` só se criar
  entidade/provider gerado (não é o caso aqui — entidades já existem).

---

## 1. COMPRAS DE INSUMOS (R7)

- [ ] 1.1 Criar providers de dados de insumos.
      Criar `insumosProvider` (FutureProvider<List<CompraInsumo>>) e
      `destinosProvider` (FutureProvider<List<Destino>>), ambos lendo
      `empresaAtualProvider.future` e retornando `[]` quando `null`, no padrão
      de `pedidos_providers.dart`.
      Files: lib/features/compras_insumos/application/insumos_providers.dart
      Verify: `flutter analyze` sem erros.

- [ ] 1.2 Criar o formulário de compra em painel lateral (560px).
      `abrirCompraForm(context, {empresaId, compra?, destinos})` via
      `abrirPainelLateral` + `CorpoPainelLateral`/`RodapePainel`. Campos: data
      (date picker, padrão de `_campoData` do pedido_editor), tipo (Dropdown
      com as 6 opções: Embalagem, Etiqueta, Impressão, Fita / lacre, Brinde,
      Outros), produto (`TextCaseField` titulo), descrição/medida
      (`TextCaseField` frase), valor total (`MoneyField`), pacotes (int),
      total de itens (int), pago com (Dropdown de destinos + opção "— não
      descontar do caixa —" → `destinoId=null`). Exibir "Valor unitário:
      R$ x por item" (valorTotal÷itens) AO VIVO (recalcula em setState).
      Salvar via `compraInsumoRepositoryProvider.criar/atualizar`
      (`id=''` para novo); normalizar textos com `PadraoEscrita`.
      Files: lib/features/compras_insumos/presentation/compra_form.dart
      Verify: `flutter analyze` sem erros.

- [ ] 1.3 Reescrever a página de insumos.
      Substituir o placeholder: raiz `Column(min, stretch)` com `PageHeader`
      (title "Compras de insumos", subtítulo do protótipo, action FilledButton
      "Registrar compra") + KPI "Total em insumos" (Σ valorTotal) com sub
      "N compra(s)" via `KpiRow`/`KpiCard`. Lista via `EstadoLista` +
      `ResponsiveList<CompraInsumo>` (data desc): colunas Compra (principal:
      produto destaque; abaixo data · Pill(tipo) · descrição), Quantidade
      ("N itens"; abaixo "N pacote(s)"), Valor (valorTotal; abaixo
      "R$ x por item"=valorTotal/itens), Pago com (nome do destino ou "—";
      abaixo "sai do caixa"/"fora do caixa"). Ações: `IconAction` editar +
      `ConfirmDeleteButton` excluir. Invalidar `insumosProvider` após
      salvar/excluir.
      Files: lib/features/compras_insumos/presentation/insumos_page.dart
      Verify: `flutter analyze` e `flutter test` verdes.

## 2. INVESTIMENTO (R8)

- [ ] 2.1 Criar providers de dados de investimento.
      `investimentosProvider` (FutureProvider<List<Investimento>>) e reutilizar
      `destinosProvider` (mover para um provider compartilhado em
      `features/caixa/application` ou duplicar o padrão). Decisão: criar
      `destinosProvider` em `lib/features/caixa/application/caixa_providers.dart`
      na feature 3 e, para Investimento/Insumos, cada feature declara seu
      próprio `destinosProvider` local (evita acoplamento entre features; são
      FutureProviders triviais). Aqui criar o de investimento.
      Files: lib/features/investimento/application/investimento_providers.dart
      Verify: `flutter analyze` sem erros.

- [ ] 2.2 Criar o formulário de investimento em painel lateral (560px).
      `abrirInvestimentoForm(...)`. Campos: data, distribuidor (`TextCaseField`
      titulo), valor (`MoneyField`), nota/nº do pedido (`TextCaseField` maius),
      pago com (Dropdown destinos + "— não descontar —"), observação
      (`TextCaseField` frase). Salvar via `investimentoRepositoryProvider`.
      Files: lib/features/investimento/presentation/investimento_form.dart
      Verify: `flutter analyze` sem erros.

- [ ] 2.3 Reescrever a página de investimento.
      Raiz `Column(min, stretch)` + `PageHeader` (action "Registrar
      investimento") + `KpiRow`: KPI "Total investido" (Σ valor, sub "N
      lançamento(s)") e os 3 maiores distribuidores (agrupar por distribuidor,
      ordenar desc, `take(3)`) cada um com valor e sub "pc(v/total) do total".
      Lista `ResponsiveList<Investimento>` (data desc): Distribuidor
      (principal: nome; abaixo data · nota · obs), Valor (valor; abaixo "% do
      total"), Pago com (destino/"—"; "sai do caixa"/"fora do caixa"), ações
      editar/excluir.
      Files: lib/features/investimento/presentation/investimento_page.dart
      Verify: `flutter analyze` e `flutter test` verdes.

## 3. CAIXA E SAQUES (R10)

- [ ] 3.1 Criar o agregador de dados do caixa.
      `caixa_providers.dart` com `destinosProvider`,
      `saquesProvider`, `retiradasProvider` e um `DadosCaixa`
      (FutureProvider) que carrega destinos, saques, investimentos,
      compras_insumo, retiradas, pedidos e plataformasComFaixas juntos (padrão
      `dadosEdicaoPedidoProvider`). Guardar também o Map plataforma→faixas para
      o cálculo de líquido.
      Files: lib/features/caixa/application/caixa_providers.dart
      Verify: `flutter analyze` sem erros.

- [ ] 3.2 Controller de edição de destinos (percentuais/cor/nome).
      `StateNotifier`/`Notifier` com lista editável de `Destino` (adicionar,
      remover, alterar nome/cor/percentual) e `salvar()` que persiste via
      `destinoRepositoryProvider.criar/atualizar/excluir` (diff contra a lista
      original) e invalida `destinosProvider`/`DadosCaixa`. `id=''` para novos.
      Files: lib/features/caixa/application/destinos_controller.dart
      Verify: `flutter analyze` sem erros.

- [ ] 3.3 Formulários de saque e retirada (painel lateral 560px).
      Saque: data, plataforma (Dropdown), valor (`MoneyField`), observação;
      com PREVIEW DE RATEIO ao vivo — para cada destino mostrar bolinha da cor,
      nome, pct e `valor*pct/100` usando `rateio(saqueTemporario, destinos)`;
      aviso quando Σpct ≠ 100%. Ao salvar: `saque.copyWith(rateio: rateio(...))`
      e `saqueRepositoryProvider.salvar`. Retirada: data, destino (Dropdown),
      valor, descrição → `retiradaRepositoryProvider.criar`.
      Files: lib/features/caixa/presentation/saque_form.dart,
      lib/features/caixa/presentation/retirada_form.dart
      Verify: `flutter analyze` sem erros.

- [ ] 3.4 Reescrever a página de caixa (layout de cima para baixo, §7.5).
      Raiz `Column(min, stretch)`. `PageHeader` (actions: "Registrar retirada"
      + "Registrar saque"). `KpiRow`: Sacado das plataformas (Σ saques, sub
      "N saque(s)"), Saídas do caixa (Σ saídas), Saldo em caixa
      (`saldoTotal`, vermelho se <0). Painel "Saldo por destino" com Pill no
      header "Rateio fecha 100%"(bom)/"Rateio soma X%"(ruim) e um cartão por
      destino: nome com bolinha da cor, Pill do %, saldo colorido, barra
      proporcional (largura = saldo/entradas clamp 0–100), "Entrou X / Saiu Y".
      Lado a lado com mesma altura (`IntrinsicHeight`+`Row` de `Expanded` em
      tela larga, empilha no estreito via `LayoutBuilder`): "Destinos e
      percentuais" (editor do 3.2: linha por destino com cor, nome, percentual,
      remover; botão "Adicionar destino"; barra-tira proporcional; salvar) e
      "Por plataforma" (para cada plataforma: líquido dos pedidos concluídos
      via `calcularPedido` × sacado). Extrato via `ResponsiveList` com colunas
      dinâmicas: Movimento (principal), Valor (colorido +/−), UMA COLUNA POR
      DESTINO (valor do rateio ou "—"), ações (excluir só Saque/Retirada).
      Montar a lista de movimentos (saques +, investimentos/insumos/retiradas −
      que têm destino) ordenada por data desc, como `V.caixa` do protótipo.
      Files: lib/features/caixa/presentation/caixa_page.dart
      Verify: `flutter analyze` e `flutter test` verdes; conferir visualmente
      com docs/telas/11-caixa.png e 18-meia-tela-caixa.png.

## 4. Integração e verificação final

- [ ] 4.1 Rodar a suíte completa e garantir verde.
      Files: (nenhum novo)
      Verify: `flutter analyze` → "No issues found!"; `flutter test` → todos
      os testes passam (≥57). Abrir as 3 rotas no app não deve lançar
      "Vertical viewport unbounded height".
