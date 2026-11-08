# Implementation Plan — Fidelidade visual da tela Composição de custo

Objetivo: deixar a tela de **Composição de custo** (lista de produtos de venda + editor de kit)
visualmente IDÊNTICA ao protótipo. A lógica já existe e funciona — NÃO reimplementar cálculos
(`calcularKit`, `precoMinimo`, `precoParaMargem`, `abelinhasProduto` etc.). Só ajustar estrutura
de painéis, tipografia, cores, pills/chips, alinhamentos, paddings e botões.

Fonte da verdade visual:
- `docs/prototipo/balcao-revenda.html` — `<style>` (linhas ~70–253) e as funções `V.kits`
  (~517), `openKit` (~782), `pickerHTML` (~806), `kitRender` (~813), `kitPlats` (~818),
  `kitSum` (~824).
- PNGs: `docs/telas/04-composicao.png` (lista), `05-composicao-editor.png` e
  `06-composicao-por-plataforma.png` (editor).

Padrão já aprovado a replicar: `lib/features/pedidos/presentation/pedidos_page.dart`.

## Diferenças atuais vs protótipo (diagnóstico)

Lista (`composicao_page.dart`):
1. **Card dentro de card / conteúdo "no meio".** O `_Conteudo` envolve a `ResponsiveList` num
   `Container` com `padding: all(16)` + borda, e a `ResponsiveList` (sem `semMoldura`) desenha
   OUTRA borda/fundo/radius. Resultado: borda dupla, padding solto e a tabela "flutuando" dentro
   do painel — exatamente o defeito corrigido em Pedidos. O protótipo usa UM `section.panel` com
   a `table.ptable.wide` encostada e a hint num rodapé `.toolbar` (border-top) dentro do mesmo
   painel. Corrigir: `ResponsiveList(semMoldura: true)` dentro de um único `Container`-painel
   (surface, borda 1px line, radius 14, `clipBehavior: Clip.antiAlias`), sem padding externo, e a
   hint num rodapé com `border-top` dentro do painel.
2. **Raiz sem `mainAxisSize: MainAxisSize.min`.** Pedidos usa `Column(mainAxisSize: min,
   crossAxisAlignment: stretch)`; Composição usa só `stretch`. Alinhar com Pedidos.
3. **Coluna "Ações" sem header rotulado** — o protótipo tem `<th>Ações</th>`. A `ResponsiveList`
   atual reserva a largura das ações mas sem rótulo. Manter consistente com Pedidos (que também
   não rotula); apenas garantir o espaçamento idêntico ao de Pedidos (`SizedBox(width: g8-2)`
   entre abrir/duplicar/excluir — hoje a Composição não tem esse espaçador).
4. **Hint final fora do painel.** Hoje é um `Text` após a lista, dentro do mesmo `Container` com
   padding. Deve virar o rodapé do painel (faixa com `border-top: 1px line`, padding 14x20,
   texto `.hint` 12px muted), encostado à tabela.

Editor (`kit_editor.dart`):
5. **Painéis sem header com divisória.** O helper `_painel` põe título + corpo com `padding:
   all(16)` e sem linha separando título do corpo. O protótipo `.panel > header` tem
   `padding:16px 20px; border-bottom:1px solid line` e `.panel .body{padding:20px}` — ou seja,
   título num cabeçalho separado por linha, corpo abaixo. Ajustar `_painel` para reproduzir
   header (16x20, border-bottom) + body (padding 20). A "dica" opcional vira um `.hint` à direita
   do título no header (como `V.kits`/`openKit`: `<span class="hint">` no header).
6. **Resumo (`_resumo`) usa `labelLarge` como "sect-title".** O protótipo usa `.sect-title`
   (15/600 ink), não o rótulo 12,5/500 muted. Trocar os títulos de seção do resumo
   ("Custo do produto de venda", "Abelinhas do kit", "Lucro por plataforma") para `titleMedium`
   (15/600). Usar o widget `Ledger` para as linhas chave/valor (hoje usa um `linha()` ad-hoc).
7. **Linha "Investimento por venda" sem destaque de total.** No protótipo é `.ledger .row.total`
   (fundo surface-2, radius 8, padding 12x14, 15/600). Hoje é só `forte: true`. Usar o `total:`
   do `Ledger`, que já desenha divisória + destaque; ou replicar o box surface-2.
8. **Tabela "Resultado por plataforma" com header não estilizado e sem fundo surface-2.** O
   protótipo usa `th` (12px muted 500, fundo surface-2, padding 10x14) e `td` (11x14). Hoje o
   `_tabelaLarga` usa `labelLarge` sem fundo no cabeçalho e `Espacos.g8` de padding. Ajustar o
   cabeçalho para faixa surface-2 e paddings 10x14 / 11x14, com `Divider` 1px line entre linhas.
9. **Botão "Sugerido" não é `.btn.sm`.** Hoje é `TextButton` com texto. O protótipo é um
   `button.btn.sm` (padding 5x10, fonte 12,5/500, borda 1px line, fundo surface, radius 8). Criar
   um botão pequeno estilo `.btn.sm` e usá-lo.
10. **Pills de plataforma, dot e `.code` já OK** (`PlatformPill` e `CodeChip` conferem com o
    protótipo). Reutilizar nos itens do picker e nas linhas de item (hoje o picker usa `ListTile`
    com `Text(p.codigo)` em vez de `CodeChip`, e a linha de item usa `Text('cod · nome')` em vez
    de `CodeChip`). Alinhar para usar `CodeChip`.
11. **Picker (`_picker`) usa `ListTile`** — difere do protótipo `.pick` (linha com `.code`/pill +
    nome truncado + custo em negrito + botão `.btn.sm` "Adicionar", separada por `border-top`).
    Reconstruir como linhas `.pick` com botão `.btn.sm`.

Nenhum teste de widget cobre a Composição hoje (só `test/widgets/app_shell_test.dart` e
`responsive_list_test.dart`). Logo, os ajustes acima não quebram testes existentes; o item final
adiciona um teste de widget de fumaça para a lista.

---

- [ ] 1. Padronizar a RAIZ e o PAINEL da lista com o padrão de Pedidos (remove o card-dentro-de-card).
      No `_ComposicaoPageState.build`, trocar a raiz para
      `Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, ...)`.
      No `_Conteudo.build`, remover o `padding: all(16)` do `Container`-painel, adicionar
      `clipBehavior: Clip.antiAlias`, e passar `semMoldura: true` para a `ResponsiveList` (como em
      `pedidos_page.dart`). Manter cor `surface`, borda 1px `line`, radius `Raios.cartao`.
      Files: `lib/features/composicao/presentation/composicao_page.dart`
      Verify: `dart analyze lib/features/composicao` → "No issues found!"; depois
      `flutter test test/widgets/responsive_list_test.dart` segue passando.

- [ ] 2. Mover a hint final para um RODAPÉ dentro do painel (faixa com border-top), encostada à tabela.
      No `_Conteudo`, remover o `SizedBox(height: g12)` + `Text(...)` soltos e, abaixo da
      `ResponsiveList`, adicionar um `DecoratedBox` com `border: Border(top: BorderSide(color:
      line))` contendo `Padding(horizontal: g20, vertical: 14)` com o texto hint
      (`bodySmall` com `color: muted`): "Em cada plataforma: lucro por venda, e abaixo o valor que
      o cliente paga e a margem." O `_Vazio` continua renderizado quando `kits.isEmpty` (sem a
      faixa de rodapé nesse caso, como no protótipo que mostra só a linha "empty").
      Files: `lib/features/composicao/presentation/composicao_page.dart`
      Verify: `dart analyze lib/features/composicao` → sem erros.

- [ ] 3. Igualar o espaçamento das ações da lista ao de Pedidos.
      No `acoes:` da `ResponsiveList` em `_Conteudo`, inserir `const SizedBox(width: Espacos.g8 - 2)`
      entre os `IconAction` (abrir/duplicar) e antes do `ConfirmDeleteButton`, replicando o espaçamento
      usado em `pedidos_page.dart`. Manter os ícones `LucideIcons.eye`, `LucideIcons.copy` e o
      `ConfirmDeleteButton`.
      Files: `lib/features/composicao/presentation/composicao_page.dart`
      Verify: `dart analyze lib/features/composicao` → sem erros.

- [ ] 4. Ajustar o helper `_painel` do editor para o padrão `.panel > header` + `.body` do protótipo.
      Em `kit_editor.dart`, reescrever `_painel(titulo, corpo, {dica})` para:
      (a) um cabeçalho `Padding(horizontal: 20, vertical: 16)` com `Row` → `Text(titulo,
      style: titleMedium)` à esquerda e, se `dica != null`, um `Text(dica, style: bodySmall com
      color: muted)` à direita (como o `<span class="hint">` no header de `openKit`); (b) um
      `Divider(height: 1, color: line)`; (c) o corpo em `Padding(all: 20)`. Envolver tudo num
      `Container` surface / borda 1px line / radius 14 / `clipBehavior: Clip.antiAlias`. Isso afeta
      todos os painéis do editor (Itens, Adicionar itens, Custos adicionais, Preço base e metas,
      Resultado por plataforma) de uma vez.
      Files: `lib/features/composicao/presentation/kit_editor.dart`
      Verify: `dart analyze lib/features/composicao` → sem erros.

- [ ] 5. Reescrever o resumo lateral (`_resumo`) usando `Ledger` e títulos `.sect-title`.
      Substituir a função `linha()` ad-hoc e os `Text(..., style: labelLarge)` por:
      títulos de seção "Custo do produto de venda", "Abelinhas do kit", "Lucro por plataforma" em
      `titleMedium` (15/600 ink); o custo como `Ledger(linhas: [Compra dos itens, Embalagem,
      Impressão, Outros insumos], total: LinhaLedger('Investimento por venda', ...))` — o `total`
      já dá a divisória + destaque equivalente a `.row.total`. Abaixo do custo, a hint "Esse custo
      é igual em todas as plataformas. O que muda é a taxa de cada uma." (`bodySmall` muted). As
      abelinhas como `Ledger` com `LinhaLedger('Abelinhas do kit', valor, destaque: true)` e a
      sub-linha "Valem com 1 🐝 = R$ X,XX". Manter o `_linhaLucro` (PlatformPill + lucro colorido
      good/bad + margem) e o box "Melhor resultado" (fundo `accentSoft`, radius `Raios.controle`).
      NÃO alterar nenhum valor calculado — só a apresentação.
      Files: `lib/features/composicao/presentation/kit_editor.dart`
      Verify: `dart analyze lib/features/composicao` → sem erros.

- [ ] 6. Estilizar a tabela "Resultado por plataforma" (`_tabelaLarga`) como `th`/`td` do protótipo.
      No `_tabelaLarga`: o cabeçalho vira uma faixa `Container(color: surface2,
      padding: horizontal 14, vertical 10)` com os rótulos em `bodySmall` 12px muted weight 500
      (não `labelLarge`); cada linha de plataforma com `padding: horizontal 14, vertical 11` e
      `Divider(height:1, color: line)` entre linhas. Manter a ordem de colunas do protótipo:
      Plataforma | Preço anúncio | Desconto | Cupom | Cliente paga | Taxa | Líquido | Lucro |
      Margem | ROI | Preço mínimo | Sugerido | Meta | ROAS alvo. (Hoje faltam colunas Desconto e
      Cupom como células separadas — os inputs preço/desc/cupom estão agrupados em `_camposPreco`;
      manter os três inputs e apenas conferir que os rótulos/ordem do cabeçalho batem com as
      células.) Lucro colorido good/bad; valores numéricos alinhados à direita.
      Files: `lib/features/composicao/presentation/kit_editor.dart`
      Verify: `dart analyze lib/features/composicao` → sem erros; abrir o app e confirmar que
      digitar nos inputs de preço/desconto/cupom recalcula sem perder o foco (item 10 valida).

- [ ] 7. Criar o botão pequeno estilo `.btn.sm` e aplicar no "Sugerido".
      Adicionar ao core um widget `BotaoPequeno` (ou `BtnSm`) em
      `lib/core/widgets/botao_pequeno.dart`: `OutlinedButton`/`TextButton` com
      `padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5)`, borda 1px `line`, fundo
      `surface`, radius `Raios.controle` (8), texto 12.5/500 `ink`, `visualDensity: compact`,
      `hover → surface2`. Em `kit_editor.dart` (`_botaoSugerido`), trocar o `TextButton` atual por
      esse botão, mantendo `onPressed: () => _usarSugerido(platId, sugerido)` e o rótulo
      `Formatos.moedaDecimal(sugerido)`. Risco em outras telas: NENHUM — widget novo, não altera
      componentes existentes.
      Files: `lib/core/widgets/botao_pequeno.dart`, `lib/features/composicao/presentation/kit_editor.dart`
      Verify: `dart analyze lib/core/widgets lib/features/composicao` → sem erros.

- [ ] 8. Usar `CodeChip` nas linhas de item e no picker do editor.
      Em `_linhaItem`, trocar `Text('${produto?.codigo} · $nome')` por uma `Row` com
      `CodeChip(produto?.codigo ?? '?')` + `SizedBox(width: g8)` + `Text(nome)` (nome com
      `TextOverflow.ellipsis`). A sub-linha de abelinhas/custo permanece.
      Files: `lib/features/composicao/presentation/kit_editor.dart`
      Verify: `dart analyze lib/features/composicao` → sem erros.

- [ ] 9. Reconstruir o picker (`_picker`) como linhas `.pick` com botão `.btn.sm` "Adicionar".
      Substituir os `ListTile` por linhas no estilo do protótipo: cada resultado é uma `Row`
      separada por `border-top: 1px line` (usar `Divider`/`DecoratedBox`), com
      `CodeChip(p.codigo)` + nome truncado (`Expanded` + ellipsis, marca em `muted`) +
      `Text(Formatos.moedaDecimal(p.custo), weight 600)` + o `BotaoPequeno` "Adicionar"
      (`onPressed: () => _adicionar(p.id)`). Manter o campo de busca (`_buscaCtrl`) acima e o
      "Nada encontrado." quando vazio. Limitar a 12 resultados como hoje.
      Files: `lib/features/composicao/presentation/kit_editor.dart`
      Verify: `dart analyze lib/features/composicao` → sem erros.

- [ ] 10. Verificação funcional de não-regressão do editor (foco e recálculo).
      Rodar o app (`flutter run -d macos --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
      ou o alvo disponível) OU, se o ambiente não permitir, revisar que os `TextEditingController`
      das células (`_celula`) continuam preservados no `Map _celulas` e que `_onPrecoCelula`
      chama `setState` sem recriar controllers (garante recálculo ao digitar sem perder foco).
      Confirmar que o botão "Salvar produto de venda" e "Cancelar"/"Fechar" continuam no rodapé
      fixo do `CorpoPainelLateral`/`RodapePainel` (inalterados). Nenhuma mudança de lógica.
      Files: (verificação; nenhuma edição esperada)
      Verify: ao digitar em Preço/Desconto/Cupom de uma plataforma, os valores Cliente paga/Taxa/
      Líquido/Lucro/Margem/ROI recalculam e o foco permanece no campo.

- [ ] 11. Adicionar teste de widget de fumaça para a lista de Composição.
      Criar `test/widgets/composicao_page_test.dart` seguindo o padrão de
      `test/widgets/responsive_list_test.dart` (bombar um `MaterialApp` com o tema via
      `tema_app.dart` e `ProviderScope` com overrides mínimos, ou testar o widget `_Conteudo` se
      exposto). Cobrir: (a) renderiza o `PageHeader` com "Composição de custo" e o botão "Novo
      produto de venda"; (b) com uma lista de kits, aparece UM painel único (sem borda dupla) e as
      colunas por plataforma; (c) o estado vazio mostra a mensagem de "Nenhum produto de venda".
      Se `_Conteudo` for privado, extrair o mínimo necessário para testabilidade sem mudar o
      comportamento, ou testar via `ComposicaoPage` com providers sobrescritos.
      Files: `test/widgets/composicao_page_test.dart` (e, se preciso, pequena exposição em
      `lib/features/composicao/presentation/composicao_page.dart`)
      Verify: `flutter test test/widgets/composicao_page_test.dart` → todos passam.

- [ ] 12. Verificação final completa.
      Rodar análise estática e toda a suíte para garantir que nada quebrou (lista, editor, Pedidos,
      Produtos, Abelinhas, Caixa, Plataformas — nenhum componente compartilhado foi alterado de
      forma incompatível; `BotaoPequeno` é adição nova).
      Files: (nenhuma edição)
      Verify: `flutter analyze` → sem erros/avisos novos; `flutter test` → toda a suíte passa.

## Notas de risco (componentes compartilhados)
- `Ledger`, `CodeChip`, `PlatformPill`, `IconAction`, `ConfirmDeleteButton`, `ResponsiveList`,
  `PageHeader` são REUTILIZADOS como estão — sem alteração — logo sem risco para Pedidos/Produtos/
  Abelinhas/Caixa/Plataformas.
- O único acréscimo ao core é `BotaoPequeno` (widget novo). Não afeta nenhuma tela existente.
- Se, ao estilizar o cabeçalho da tabela do editor (item 6), for tentador mudar `ResponsiveList`,
  NÃO mudar: a tabela do editor é própria do `kit_editor.dart` (`_tabelaLarga`), não a
  `ResponsiveList`. A `ResponsiveList` só é tocada via o parâmetro já existente `semMoldura`.
