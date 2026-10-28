# Documentação de classes — Camada domínio

> Regra do projeto: cada classe tem documentação única, atualizada a cada
> alteração. Este arquivo agrupa as entidades de domínio (`lib/domain/entidades/`)
> e os conversores. Espelham o schema `supabase/migrations/0001_schema.sql` e o
> design.md §2/§3. Dinheiro, percentual e abelinhas são sempre `Decimal`.

## documento_DecimalConverter
- **Arquivo:** `lib/domain/entidades/conversores.dart`
- **Responsabilidade:** `JsonConverter<Decimal, Object>` para colunas `numeric`.
  `fromJson` aceita `String`, `num` e `int`; `toJson` grava `String` (via
  `Decimal.toString`) preservando a precisão sem passar por `double`.

## documento_DecimalNullableConverter
- **Arquivo:** `lib/domain/entidades/conversores.dart`
- **Responsabilidade:** versão anulável de `DecimalConverter`; mantém `null` nos
  dois sentidos (ex.: `preco_ate`, `abelinhas_manual`, `preco_concorrente`).

## documento_Empresa
- **Arquivo:** `lib/domain/entidades/empresa.dart`
- **Responsabilidade:** tenant dono dos dados (tabela `empresas`). Campos: `id`,
  `nome`, `criadoEm` (`criado_em`).

## documento_Configuracoes
- **Arquivo:** `lib/domain/entidades/configuracoes.dart`
- **Responsabilidade:** configurações da empresa (tabela `configuracoes`, 1 por
  empresa). `empresaId`, `embalagemPadrao`, `impressaoPadrao`, `valorAbelinha`
  (todos `Decimal`).

## documento_FaixaAbelinha
- **Arquivo:** `lib/domain/entidades/faixa_abelinha.dart`
- **Responsabilidade:** faixa custo → abelinhas (tabela `faixas_abelinha`).
  `id`, `empresaId`, `custoAte` (`Decimal`), `abelinhas` (`Decimal`).

## documento_Produto
- **Arquivo:** `lib/domain/entidades/produto.dart`
- **Responsabilidade:** produto comprado para revenda (tabela `produtos`).
  `custo` é `Decimal`; `abelinhasManual` (`Decimal?`) nulo significa calcular
  pela regra de faixas.

## documento_Plataforma
- **Arquivo:** `lib/domain/entidades/plataforma.dart`
- **Responsabilidade:** marketplace / canal de venda (tabela `plataformas`).
  `id`, `empresaId`, `nome`, `cor`, `obs`, `ordem`.

## documento_FaixaTaxa
- **Arquivo:** `lib/domain/entidades/faixa_taxa.dart`
- **Responsabilidade:** faixa de taxa de uma plataforma (tabela `faixas_taxa`).
  `taxaFixa`/`taxaPercentual` são `Decimal`; `precoAte` (`Decimal?`) nulo =
  faixa sem limite superior.

## documento_Destino
- **Arquivo:** `lib/domain/entidades/destino.dart`
- **Responsabilidade:** destino de rateio do caixa (tabela `destinos`).
  `percentual` é `Decimal`.

## documento_CompraInsumo
- **Arquivo:** `lib/domain/entidades/compra_insumo.dart`
- **Responsabilidade:** compra de insumos (tabela `compras_insumo`).
  `valorTotal` é `Decimal`; `data` é `DateTime`; `destinoId` opcional.

## documento_ProdutoVenda
- **Arquivo:** `lib/domain/entidades/produto_venda.dart`
- **Responsabilidade:** produto de venda / kit (tabela `produtos_venda`).
  Valores monetários/percentuais em `Decimal`. `itens`
  (`List<ProdutoVendaItem>`) e `precosPorPlataforma`
  (`Map<String, PrecoPlataforma>`, chave = `plataformaId`) são carregados pelo
  repositório e ficam fora do JSON da linha (`includeFromJson/ToJson: false`).

## documento_ProdutoVendaItem
- **Arquivo:** `lib/domain/entidades/produto_venda_item.dart`
- **Responsabilidade:** item (produto + quantidade) de um produto de venda
  (tabela `produtos_venda_itens`).

## documento_PrecoPlataforma
- **Arquivo:** `lib/domain/entidades/preco_plataforma.dart`
- **Responsabilidade:** preço por plataforma de um produto de venda (tabela
  `produtos_venda_precos`). `preco`/`desconto`/`cupom` (`Decimal?`) nulos =
  usa os valores base; `vendidosIniciais` é `int`.

## documento_SituacaoPedido
- **Arquivo:** `lib/domain/entidades/enums.dart`
- **Responsabilidade:** enum da situação do pedido: `concluido`, `cancelado`,
  `devolvido` (casa o check `situacao` em `pedidos`).

## documento_TipoPedidoItem
- **Arquivo:** `lib/domain/entidades/enums.dart`
- **Responsabilidade:** enum do tipo de item de pedido: `produto`
  (`@JsonValue('produto')`) e `produtoVenda` (`@JsonValue('produto_venda')`),
  casando o check `tipo` em `pedidos_itens`.

## documento_Pedido
- **Arquivo:** `lib/domain/entidades/pedido.dart`
- **Responsabilidade:** pedido de venda (tabela `pedidos`). Valores monetários
  em `Decimal`; `liquidoInformado` (`Decimal?`) opcional; `situacao`
  (`SituacaoPedido`). `itens` (`List<PedidoItem>`) é carregado pelo repositório
  e fica fora do JSON da linha.

## documento_PedidoItem
- **Arquivo:** `lib/domain/entidades/pedido_item.dart`
- **Responsabilidade:** item de pedido (tabela `pedidos_itens`). `tipo`
  (`TipoPedidoItem`); `custoUnitario` e `abelinhasUnitarias` (`Decimal`) são
  snapshots gravados no salvamento; `produtoId`/`produtoVendaId` conforme o tipo.

## documento_Investimento
- **Arquivo:** `lib/domain/entidades/investimento.dart`
- **Responsabilidade:** investimento (compra de mercadoria por distribuidor,
  tabela `investimentos`). `valor` é `Decimal`.

## documento_Saque
- **Arquivo:** `lib/domain/entidades/saque.dart`
- **Responsabilidade:** saque de uma plataforma (tabela `saques`). `valor` é
  `Decimal`; `rateio` (`List<SaqueRateio>`) é carregado pelo repositório e fica
  fora do JSON da linha.

## documento_SaqueRateio
- **Arquivo:** `lib/domain/entidades/saque_rateio.dart`
- **Responsabilidade:** rateio de um saque entre destinos (snapshot, tabela
  `saques_rateio`). `percentual` e `valor` são `Decimal`.

## documento_Retirada
- **Arquivo:** `lib/domain/entidades/retirada.dart`
- **Responsabilidade:** retirada de um destino do caixa (tabela `retiradas`).
  `valor` é `Decimal`.

---

> Cálculos puros (`lib/domain/calculos/`) — funções e tipos de resultado do
> design.md §6. Sem dependência de Flutter ou Supabase (apenas `dart:core`,
> `package:decimal` e as entidades). Arredondamento só na exibição; os
> resultados guardam `Decimal` em precisão plena. Cobertos pelos vetores do §6
> em `test/domain/calculos/` (tolerância 0,005).

## documento_CalculoDecimal
- **Arquivo:** `lib/domain/calculos/decimais.dart`
- **Responsabilidade:** extensão de [Decimal] com `dividir` (divisão com escala
  interna ampla, já que `/` devolve `Rational`) e `arred2` (arredondamento de
  exibição a 2 casas). Expõe também `zero` e `cem` reutilizáveis.

## documento_Taxas
- **Arquivo:** `lib/domain/calculos/taxas.dart`
- **Responsabilidade:** faixa/taxa de plataforma e preços-alvo (§6.1/§6.2).
  `ordenarFaixas`, `faixa`, `taxa`, `precoMinimo` e `precoParaMargem`. Faixas
  ordenadas por `precoAte` asc (sem limite por último).

## documento_ResultadoKit
- **Arquivo:** `lib/domain/calculos/produto_venda.dart`
- **Responsabilidade:** resultado freezed do cálculo de um produto de venda
  (kit) em uma plataforma (§6.3): `compra`, `investimento`, `clientePaga`,
  `taxa`, `liquido`, `lucro`, `margem`, `roi`, `metaQtd` (int?), `metaFaturamento`,
  `atingido`, `roasAlvo` (Decimal?), `custoAnuncio`, `vendidos` (int),
  `abelinhasKit`. Produzido por `calcularKit`. `metaQtd` usa o lucro exibido
  (2 casas), como na planilha de origem.

## documento_ResultadoPedido
- **Arquivo:** `lib/domain/calculos/pedido.dart`
- **Responsabilidade:** resultado freezed do cálculo de um pedido (§6.4):
  `mercadoria`, `custo`, `taxaEstimada`, `liquidoEstimado`, `liquido`,
  `taxaEfetiva`, `lucro`, `margem`, `abelinhasPedido`. Produzido por
  `calcularPedido`. Helpers `precoAutomatico` e `itensTaxaFixaAutomatico` para
  pedidos novos compostos só por kits.

## documento_Abelinhas
- **Arquivo:** `lib/domain/calculos/abelinhas.dart`
- **Responsabilidade:** regra e análises de abelinhas (§6.6/§6.7).
  `abelinhasRegra`, `acimaDaTabela`, `abelinhasProduto`, `roiProduto`,
  `analisePorFaixa` → `AnaliseFaixa` (teto, abelinhas, limite inferior,
  nº de produtos, venda, ROI médio, ROI no limite, abelinha mínima, situação),
  `analiseGeral` → `AnaliseGeralAbelinhas` (ROI médio geral, com lucro/prejuízo,
  abelinha mínima sem prejuízo) e `avisoAjusteManual` → `AvisoAjusteManual`
  (regra/manual, diferença, lucro/ROI antes e depois, mínimo, cor do aviso).

## documento_Caixa
- **Arquivo:** `lib/domain/calculos/caixa.dart`
- **Responsabilidade:** caixa e saques (§6.8). `rateio` (lista de `SaqueRateio`),
  `entradasDestino`, `saidasDestino`, `saldoDestino` → `SaldoDestino`
  (entradas, saídas, saldo) e `saldoTotal`.

## documento_Painel
- **Arquivo:** `lib/domain/calculos/painel.dart`
- **Responsabilidade:** KPIs e pontos de atenção do painel (§6.5/§6.9).
  `kpisPainel` → `KpisPainel` (faturamento, taxas, líquido, custo, lucro,
  margem) sobre pedidos `concluido`; `pontosAtencao` → lista de `PontoAtencao`
  (soma de destinos != 100%, kit com prejuízo ou margem < 15% por plataforma,
  códigos repetidos).
