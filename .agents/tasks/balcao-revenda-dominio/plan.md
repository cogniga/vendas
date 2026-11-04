# Plano de implementação — Camada de domínio (Balcão Revenda)

Escopo: entidades `freezed` (`lib/domain/entidades/`) + cálculos puros
(`lib/domain/calculos/`) + testes de unidade com os vetores do `design.md` §6.
Trabalho direto no repositório (sem worktree). Package `sales`, imports
`package:sales/...`.

Fontes da verdade lidas: `.kiro/specs/balcao-revenda/design.md` (§2, §3, §6, §8),
`supabase/migrations/0001_schema.sql`, `assets/seed/dados-iniciais.json`,
`lib/core/format/formatos.dart`, `lib/core/format/padrao_escrita.dart`,
`.kiro/steering/{structure,tech}.md`, `docs/classes/documento_core.md`.

Decisões de design (registradas aqui, não há design novo a decidir):
- **Dinheiro = `Decimal`** (pacote `decimal`, já em `pubspec.yaml`). Um
  `JsonConverter` central (`DecimalConverter`) e um `DecimalNullableConverter`
  convertem `Decimal <-> String|num`, pois o PostgREST devolve `numeric` ora como
  `String` ora como `num`. Na serialização grava-se `String` (preserva precisão).
- **Percentuais e abelinhas** também como `Decimal` (schema usa `numeric(6,2)`),
  pelo mesmo motivo de precisão; cálculos usam `Decimal`/`Rational`.
- **Resultados de cálculo** são classes `freezed` próprias (ex.: `ResultadoKit`,
  `ResultadoPedido`), separadas das entidades de dados — mantém o domínio puro e
  testável sem Supabase.
- **Cálculos puros**: só dependem de `dart:core`, `package:decimal` e das
  entidades. Nenhum import de Flutter/Supabase (tech.md). Arredondamento só na
  borda de exibição; internamente mantém precisão. Comparações de teste com
  tolerância 0,005.
- **Documentação de classe**: cada classe nova é registrada em
  `docs/classes/documento_dominio.md` (novo arquivo, mesmo estilo de
  `documento_core.md`), conforme regra global do projeto.
- **Lint**: `very_good_analysis`, linhas <= 80 colunas; `*.g.dart`/`*.freezed.dart`
  já excluídos em `analysis_options.yaml`.

Comandos de verificação (toolchain confirmado: Flutter 3.35.7 estável):
- Geração: `dart run build_runner build --delete-conflicting-outputs`
- Análise: `flutter analyze`
- Testes: `flutter test` (baseline atual: 13 testes passam)

---

- [ ] 1. Conversores `Decimal` e barris de domínio.
      Criar `DecimalConverter`/`DecimalNullableConverter` (`JsonConverter`) que
      lê `String` ou `num` do PostgREST e serializa como `String`; cobrir casos
      `null`, `"12.50"`, `12.5`, `0`. Criar documento de classes do domínio.
      Arquivos: `lib/domain/entidades/conversores.dart`,
      `docs/classes/documento_dominio.md`.
      Verificar: `flutter analyze lib/domain/entidades/conversores.dart` sem erros;
      teste unitário do conversor passa em `flutter test test/domain/`.

- [ ] 2. Entidades `freezed` espelhando §2/§3 e o schema SQL.
      Criar, em um conjunto coeso (cada uma com `fromJson/toJson` snake_case e
      `@JsonKey(name:)` onde o nome Dart difere; `Decimal` via conversores):
      `Empresa`, `Configuracoes`, `FaixaAbelinha`, `Produto`
      (`abelinhasManual Decimal?` — null = regra), `Plataforma`, `FaixaTaxa`
      (`precoAte Decimal?`), `Destino`, `CompraInsumo`, `ProdutoVenda`
      (carrega `itens: List<ProdutoVendaItem>` e
      `precosPorPlataforma: Map<String, PrecoPlataforma>`), `ProdutoVendaItem`,
      `PrecoPlataforma` (`preco/desconto/cupom` nullable + `vendidosIniciais`),
      `Pedido` (carrega `itens`; `situacao` enum concluido/cancelado/devolvido),
      `PedidoItem` (`tipo` enum produto|produto_venda, `custoUnitario` e
      `abelinhasUnitarias` como snapshot `Decimal`), `Investimento`,
      `Saque` (carrega `rateio`), `SaqueRateio`, `Retirada`.
      Enums com `@JsonValue` para casar com os `check` do SQL.
      Arquivos: `lib/domain/entidades/*.dart` (um arquivo por agregado/entidade).
      Verificar: `dart run build_runner build --delete-conflicting-outputs`
      gera `*.freezed.dart`/`*.g.dart` sem erro; `flutter analyze` limpo; teste de
      round-trip `fromJson(toJson())` em `flutter test test/domain/entidades/`
      usando um registro de `assets/seed/dados-iniciais.json`.

- [ ] 3. `taxas.dart` — faixa, taxa, preço mínimo, preço para margem (§6.1/§6.2).
      Funções puras: `faixa(plataforma, preco)`, `taxa(plataforma, preco,
      itensTaxaFixa=1)`, `precoMinimo(plataforma, custo)`,
      `precoParaMargem(plataforma, custo, margemAlvo)`.
      Arquivos: `lib/domain/calculos/taxas.dart`.
      Verificar: incluído na suíte do item 7 (`flutter test`).

- [ ] 4. `produto_venda.dart` — `calcularKit` retornando todos os campos do §6.3.
      Resultado em classe `freezed` `ResultadoKit` (compra, investimento,
      clientePaga `M`, taxa, liquido, lucro, margem, roi, metaQtd,
      metaFaturamento, atingido, roasAlvo, custoAnuncio, vendidos, abelinhasKit).
      Usa override por plataforma quando preenchido, senão base.
      Arquivos: `lib/domain/calculos/produto_venda.dart`.
      Verificar: incluído na suíte do item 7.

- [ ] 5. `pedido.dart` — `calcularPedido`, preço automático e regra de
      embalagem/impressão zeradas quando o pedido novo só tem kits (§6.4).
      Resultado `ResultadoPedido` (mercadoria, custo, taxaEstimada,
      liquidoEstimado, liquido, taxaEfetiva, lucro, margem, abelinhasPedido);
      helper `precoAutomatico` e `itensTaxaFixaAutomatico`.
      Arquivos: `lib/domain/calculos/pedido.dart`.
      Verificar: incluído na suíte do item 7.

- [ ] 6. `abelinhas.dart`, `caixa.dart`, `painel.dart`.
      `abelinhas.dart`: `abelinhasRegra(custo)` (flag acimaDaTabela),
      `abelinhas(produto)`, `roi`, análise por faixa e geral, aviso de impacto do
      ajuste manual (§6.6/§6.7). `caixa.dart`: rateio, entradas, saídas, saldos
      (§6.8). `painel.dart`: KPIs (§6.5) e pontos de atenção (§6.9).
      Arquivos: `lib/domain/calculos/abelinhas.dart`,
      `lib/domain/calculos/caixa.dart`, `lib/domain/calculos/painel.dart`.
      Verificar: incluído na suíte do item 7.

- [ ] 7. Testes de todos os vetores numéricos do §6 (tolerância 0,005).
      `test/domain/calculos/*_test.dart`. Helper de leitura do seed para os
      vetores §6.6 (99 produtos). Vetores obrigatórios:
      - §6.3 Batom Bolsinha nas 4 plataformas (Shopee lucro 1,51 margem 10,2%
        mínimo 21,60 sugerido 31,71 meta 13/133; TikTok 3,39 20,3% 19,64 29,10
        0/59; Mercado Livre 0,67 4,8% 22,71 32,33 0/299; Venda direta 10,21 43,5%
        13,28 21,97 0/20); investimento 13,28; cliente paga 23,49. ROAS alvo
        Shopee ≈ 51,8. Kit 5 Sachês Shopee (inv 5,75, taxa 7,40, líquido 9,59,
        lucro 3,84, margem 40,1%, mínimo 12,19). Kit Maquiagem Shopee (inv 21,93,
        taxa 12,98, líquido 31,92, lucro 9,99, margem 31,3%, mínimo 32,41,
        metaQtd 21).
      - §6.4 KT01-DALILA (TikTok, custo 51,26, venda 110,00, líquido 85,85, lucro
        34,59, 7,5 🐝); KT01-THAIS (custo 43,66, líquido 97,40, lucro 53,74,
        6 🐝); Kit Batom no Mercado Livre (custo 13,28, venda 31,90, taxa 10,72,
        líquido 21,18, lucro 7,90, 1,5 🐝).
      - §6.5 painel: faturamento 220,00 · taxas 36,75 (16,7%) · líquido 183,25 ·
        custo 94,92 · lucro 88,33 (40,1%).
      - §6.6 v=10: ROI médio 86,5%, 99 com lucro, 0 prejuízo, 🐝 mínima 10,00;
        faixa até 5,00 → 38 produtos, ROI médio 141,1%, no limite 0,0%, "Empata
        no teto"; faixa 5,01 a 8,00 → 40 produtos, ROI médio 56,7%, no limite
        25,0%. v=8: ROI médio 49,2%, 9 produtos com prejuízo.
      - §6.7 Gloss Playboy (código PB) custo 6,45, regra 1, manual 0,5, v 10 →
        vermelho, prejuízo 1,45/un, ROI 55,0% → −22,5%, mínimo 1 🐝.
      - §6.8 caixa: saque TikTok 3.286,06 (40/30/30) → 1.314,42 / 985,82 / 985,82;
        saídas Compras de produtos 209,19 + 46,99 → saldo 729,64; saldo total
        3.029,88.
      Arquivos: `test/domain/calculos/taxas_test.dart`,
      `produto_venda_test.dart`, `pedido_test.dart`, `abelinhas_test.dart`,
      `caixa_test.dart`, `painel_test.dart`, mais `test/domain/seed_helper.dart`.
      Verificar: `flutter test` passa (baseline 13 + novos); `flutter analyze`
      limpo.

- [ ] 8. Atualizar `docs/classes/documento_dominio.md` com todas as classes de
      entidade e os resultados de cálculo (`ResultadoKit`, `ResultadoPedido`,
      estruturas de análise de abelinhas e caixa), no estilo de
      `documento_core.md`.
      Arquivos: `docs/classes/documento_dominio.md`.
      Verificar: revisão manual (arquivo lista cada classe criada nos itens 1–6).
