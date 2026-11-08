# Fidelidade visual da tela de Composição de custo (kits)

O diff refaz a tela de Composição de custo (lista) e o editor de kit (painel lateral) para bater com o protótipo `balcao-revenda.html` (`V.kits`, `openKit`, `kitSum`, `kitPlats`, `pickerHTML`) e com o padrão aprovado em `pedidos_page.dart`. A lista passa a um painel único (sem card-dentro-de-card) via `ResponsiveList(semMoldura: true)` dentro de um `Container` com borda/radius, hint no rodapé com `border-top`. O editor adota o `.panel` do protótipo (header 16x20 com `border-bottom` + body padding 20), resumo com `Ledger` e total destacado, tabela "Resultado por plataforma" com `th` em surface-2 e divisórias 1px, picker reconstruído como `.pick` e botão Sugerido como `.btn.sm` (`BotaoPequeno`). A lógica de cálculo não foi reimplementada: tudo passa por `calcularKit`, `precoMinimo`, `precoParaMargem` e `abelinhasProduto`.

Watch for:
- Nenhuma divergência bloqueante encontrada. Os desvios restantes são cosméticos e herdados de widgets compartilhados aprovados (confirmed).

**Verdict**: APPROVED

## High-level view

A estrutura da lista reproduz fielmente o `section.panel` do protótipo e o PNG `04-composicao.png`: cabeçalho com ponto 8px por plataforma, colunas numéricas à direita, lucro em negrito verde/vermelho, sub-linha muted e faixa de hint encostada à tabela. As cores saem dos tokens (`CoresApp`), que reproduzem a paleta hex do `:root` exatamente, então não há risco de desvio de cor.

O editor segue o `05-composicao-editor.png`: painel com header (título 15/600 + contagem de unidades à direita), ledger com "Investimento por venda" como total destacado, nota "Abelinhas do kit" como subtotal em negrito, "Lucro por plataforma" com dots e a nota "Melhor resultado" em accent-soft/accent. A tabela larga usa `th` em surface-2 (12px muted w500, pad 10x14) e `td` pad 11x14 com divisórias 1px, rótulos e ordem idênticos ao `kitPlats` ("Preço mínimo", "ROAS alvo"). O botão Sugerido virou `.btn.sm` com tooltip de margem.

A não-regressão funcional se mantém: overrides por plataforma (`_onPrecoCelula`/`_precos`), recálculo ao digitar (`setState` + `calcularKit`), adicionar/remover item, controle de quantidade, duplicar, excluir, usar sugerido e salvar continuam intactos, reaproveitando o domínio sem reimplementar fórmulas.

A verificação está registrada no corpo do commit (`build_runner` ok, `flutter analyze` sem issues, 63 testes verdes, `flutter build macos` compila) e um smoke test de widget da lista foi adicionado.

<details>
<summary>Issues (2)</summary>

1. **CodeChip radius/borda** — `CodeChip` usa radius 6 (`Raios.pill`) e `Border.all(line)`, enquanto o `.code` do protótipo é radius 5 sem borda. Cosmético, herdado de widget compartilhado já usado em produtos; não bloqueia. (possible)
2. **Limite do picker** — o picker usa `.take(12)` contra `.slice(0,60)` do protótipo. Pré-existente (presente em `HEAD~1`), fora do escopo deste diff. (confirmed, out of scope)

</details>

<details>
<summary>Details</summary>

### Painel único da lista (sem card-dentro-de-card)

`_Conteudo` embrulha a lista num `Container` (surface, `Border.all(line)`, radius `Raios.cartao`=14, `clipBehavior: antiAlias`) e passa `semMoldura: true` ao `ResponsiveList`, que então não desenha a própria moldura — exatamente o `section.panel > table.ptable` do protótipo, sem borda dupla. O `ResponsiveList` com `semMoldura` aplica `th 10x14` / `td 11x14` (confirmado em `responsive_list.dart`: `padH = g12+2 = 14`, `padVCabecalho = 10`, `padVCelula = 11`), batendo com o CSS. O rodapé reproduz `.toolbar` com `border-top` (padding 14x20, hint 12px muted). Confere com `04-composicao.png`.

A raiz da página virou `Column(mainAxisSize: min)`, encostando o conteúdo ao topo — consistente com a correção de centralização aprovada em Pedidos.

### Cabeçalho e células da lista

Cada coluna de plataforma usa o nome como label e `_CelulaPlataforma` com lucro em `bodyMedium` w600 colorido (`good`/`bad`) e sub-linha `clientePaga · margem` em `bodySmall` muted — igual ao `kitCalc` renderizado no protótipo (`<b class=pos/neg>` + `.sub`). `PlatformPill` desenha o dot 8px com a cor hex da plataforma. O estado vazio usa `.empty` (padding 32x16, centralizado, muted).

### Painel do editor (`.panel`)

`_painel` monta header com padding 16x20, título em `titleMedium` (15/600, confirmado em `tema_app.dart`), ação/hint opcional à direita, `Divider` 1px (`border-bottom`) e body com padding 20. Elimina o `padding:all(16)` antigo que criava um card compacto fora do padrão. "Itens do produto de venda" mostra a contagem de unidades no header (como `k_unid` no `kitSum`); "Preço base e metas" mostra a dica à direita.

### Resumo com Ledger

O resumo trocou a função `linha(...)` local pelo `Ledger` compartilhado: "Compra dos itens / Embalagem / Impressão / Outros insumos" como linhas e "Investimento por venda" como `total` destacado (surface-2, w600) — igual ao `.ledger .row.total`. Em seguida a hint muted, o bloco de abelinhas (com "Abelinhas do kit" como `destaque`) e "Lucro por plataforma" com `_linhaLucro` (dot + nome + lucro colorido + margem). A nota "Melhor resultado" usa accentSoft/accent, reproduzindo `.note.info`. Confere com `05-composicao-editor.png`.

### Tabela "Resultado por plataforma"

`_tabelaLarga` envolve a tabela num `ClipRRect` (radius 8), com o cabeçalho num `Container` surface-2 (`estiloCab` = 12px muted w500, pad 10x14) e cada linha com pad 11x14 separada por `Divider` 1px. Rótulos e ordem batem com `kitPlats`: inclui "Preço mínimo" e "ROAS alvo" (antes eram "Mínimo"/"ROAS"). Colunas numéricas alinhadas à direita; Plataforma e Preço anúncio à esquerda. Abaixo de 860px cai em blocos por plataforma (`_blocosPlataforma`), preservando o padrão sem rolagem horizontal.

### Picker `.pick` e botão Sugerido

O picker foi reconstruído como linhas `.pick`: `CodeChip` + nome truncado + marca muted + custo em negrito (`bodyMedium` w600) + `BotaoPequeno('Adicionar')`, separadas por `border-top` (sem borda na primeira). `BotaoPequeno` reproduz `.btn.sm` (pad 5x10, 12,5/500 ink, borda line, surface, radius 8, hover surface-2). O botão Sugerido virou `BotaoPequeno` com o preço formatado e tooltip "Preço para N% de margem", como `data-act="usarSug"` no protótipo.

### Não-regressão funcional

Nada da lógica foi reimplementado. `_resultado` e `_resumo` chamam `calcularKit`; `_sugerido` usa `precoParaMargem` + desconto/cupom efetivo (override da plataforma, senão base), como `kitCalc`; `precoMinimo` vem de `taxas`; abelinhas de `abelinhasProduto`. Os overrides por plataforma continuam em `_precos`/`_onPrecoCelula`, o recálculo ao digitar via `setState`, e adicionar/remover/quantidade/duplicar/excluir/salvar/usar-sugerido seguem intactos. `_usarSugerido` grava na célula e no override, como o protótipo.

### Verificação

O corpo do commit registra `build_runner` ok, `flutter analyze lib test` sem issues, 63 testes verdes e `flutter build macos` compilando. Foi adicionado `test/widgets/composicao_page_test.dart` com smoke tests da lista (cabeçalho, botão novo, coluna de plataforma + hint do rodapé em 1400px, estado vazio). Não tem teste de widget do editor nem dos overrides/sugerido, mas os cálculos já têm cobertura de unidade no domínio e o escopo aqui é visual.

</details>

<details>
<summary>Arquivos alterados</summary>

- `lib/features/composicao/presentation/composicao_page.dart` — painel único via `semMoldura`, rodapé com `border-top`, estado vazio 32x16, raiz `Column(min)`.
- `lib/features/composicao/presentation/kit_editor.dart` — `.panel` com header/divider/body, `Ledger` no resumo, tabela com th surface-2 e td 11x14, picker `.pick` com `CodeChip`, Sugerido como `BotaoPequeno`.
- `lib/core/widgets/botao_pequeno.dart` — novo widget `.btn.sm` (reutilizado também em Pedidos).
- `lib/core/widgets/platform_pill.dart` — ajuste de dot/estilo (reutilizado).
- `test/widgets/composicao_page_test.dart` — smoke test da lista.
- Outros (`app_shell`, `caixa/*`, `destinos_panel`, `code_chip` via import) — fora do escopo de Composição; `CodeChip` já existia inalterado em `HEAD~1`.

Diff completo: `git diff HEAD~1`.

</details>
