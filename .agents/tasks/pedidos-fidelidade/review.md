# Fidelidade visual — tela de Pedidos ao protótipo

Revisão do commit `052072c` ("fix: fidelidade visual da tela de Pedidos ao prototipo") contra a fonte da verdade `docs/prototipo/balcao-revenda.html` (bloco `<style>` + função `V.pedidos`) e `docs/telas/02-pedidos.png`. A tarefa é replicação campo-a-valor: comparar cada propriedade (hex, px, pesos, paddings, alinhamentos) do protótipo com o valor equivalente no código.

A mudança reestrutura a tela em torno de um único `.panel` (toolbar no topo com borda inferior, tabela encostada logo abaixo), corrige o alinhamento do conteúdo ao topo da área de trabalho, adota o visual `.iconbtn` 34×34 nas ações, e ajusta paddings/sublinhas aos valores exatos do protótipo. Os tokens de cor e a tipografia já batiam e não foram tocados.

**Watch for:** o `Pill` (status, `est.`) e o `PlatformPill` divergem do protótipo (peso/padding e ausência do `dot` 8px), **mas esses dois widgets não foram alterados neste commit** — são divergências pré-existentes, fora do escopo desta revisão (regra: só se revisa o que o diff mudou). Nenhuma divergência bloqueante foi **introduzida** pelo commit.

**Verdict:** APPROVED

## Evidência de build/teste

O plano (`plan.md`, seção "Resultados da verificação (iteração 1)") registra, nesta ordem e todos verdes: `build_runner build` OK (3 outputs); `flutter analyze lib test` → "No issues found!"; `flutter test` → "All tests passed!" (60 testes); `flutter build macos` → app gerado (50.4MB). A instrução proíbe re-rodar as suítes; a evidência está presente e foi aceita. Não foi re-executada nenhuma suíte.

Observação de estado git: o diff vive no commit `052072c` (HEAD = main), por isso `git diff main` não mostra nada; a comparação foi feita com `git show 052072c`. Os arquivos de `lib/features/caixa/**` aparecem modificados na árvore de trabalho mas são de outra tarefa e não fazem parte deste commit.

## High-level view

A causa do visual "quebrado" relatado pelo usuário era card-dentro-de-card: `_Conteudo` desenhava um `Container` com borda/radius e, dentro, a `ResponsiveList` desenhava **outro** card com borda/radius própria — gerando borda dupla, cantos internos e a toolbar flutuando com `padding 16 + SizedBox(16)`. O commit resolve isso desenhando o `.panel` uma única vez em `pedidos_page.dart` e dando à `ResponsiveList` um modo `semMoldura` (default `false`) em que ela não desenha card próprio. A toolbar passa a viver dentro do painel no topo, com `border-bottom`, e a tabela fica encostada logo abaixo — exatamente a hierarquia `.panel > .toolbar + table.ptable` do protótipo.

A reclamação "lista no meio" é resolvida no `app_shell._Corpo`: o padding do `main` do protótipo (`padding-block:32px 64px`) foi reproduzido e o conteúdo é alinhado ao topo via `SingleChildScrollView` — não há `Center`/`MainAxisAlignment.center` na cadeia vertical.

O `.head` foi reescrito para `Row` em telas largas (título à esquerda, ações à direita, alinhados pela base = `align-items:flex-end`) e empilhamento em telas estreitas, com `margin-bottom:24`, subtítulo `margin-top:6` e `max-width ~64ch`.

As ações da linha adotam o `.iconbtn` 34×34 (borda 1px line, radius 8, muted; hover surface-2, e bad-soft no excluir), com `Tooltip` + `Semantics` preservados.

Os tokens de cor (`tokens.dart`) e a tipografia (`tema_app.dart`) já batiam byte-a-byte com o protótipo e não foram alterados — confirmados nesta revisão.

<details>
<summary>Issues (3)</summary>

1. **th a 12,5px (proto 12px)** — o cabeçalho usa `labelLarge` = 12,5px; o protótipo `th` é 12px. Diferença de 0,5px, sem impacto visual perceptível; o plano a declarou aceitável. Não bloqueante. *(confirmed)*
2. **Pill peso/padding divergem** — `Pill` usa `fontWeight w600` e padding `8×3`; o protótipo `.pill` é `font-weight:500; padding:2px 9px`. `pill.dart` **não foi alterado neste commit** → pré-existente, fora do escopo. Corrigir em tarefa dedicada se a fidelidade do pill for exigida. *(confirmed)*
3. **PlatformPill sem dot 8px** — o protótipo `platPill` é `.pill` neutro com `i.dot` 8px + nome; o código renderiza chip translúcido colorido com borda, sem dot. `platform_pill.dart` **não foi alterado neste commit** → pré-existente, fora do escopo. *(confirmed)*

</details>

<details>
<summary>Details</summary>

### Painel único vs card-dentro-de-card

Protótipo: `.panel{background:surface;border:1px solid line;border-radius:14px(--r-m);box-shadow:shadow-s;overflow:hidden}`, contendo `.toolbar` (no topo, `border-bottom`) e `table.ptable` encostada.

Código (`pedidos_page.dart` `_Conteudo`): `Container` com `color:surface`, `border:1px line`, `borderRadius:Raios.cartao`(14), `clipBehavior:Clip.antiAlias`(= overflow hidden). Dentro, `Column(crossAxisAlignment:stretch)` com (a) `DecoratedBox` de `border(bottom: line)` envolvendo `Padding(horizontal:20, vertical:14)` com a `_Barra`, e (b) a `ResponsiveList(semMoldura:true)` logo abaixo, sem padding externo. O `SizedBox(16)` intermediário foi removido. A borda dupla desapareceu porque `ResponsiveList`, em `semMoldura:true`, retorna só o conteúdo (sem o `Container` de card). Bate com o protótipo. A única diferença de token é a sombra: o protótipo aplica `box-shadow:var(--shadow-s)` no `.panel` e o `Container` não define `boxShadow` — diferença sutil (sombra de 1px rgba .04) que não aparece no PNG de referência; não bloqueante e não listada como issue por ser imperceptível.

### Toolbar (busca + filtro)

Protótipo `.toolbar{padding:14px 20px;border-bottom:1px solid line}`, `input[type=search]{flex:1 1 220px}`, `select{width:auto}`; em telas estreitas os itens quebram em linhas.

Código: padding `horizontal:20, vertical:14` ✓; `border-bottom` 1px line ✓. Busca em `Expanded` (ocupa o espaço) ✓; filtro em `SizedBox(width:240)` — o protótipo usa `width:auto`, aqui fixou 240px. Diferença consciente (um `DropdownButtonFormField` sem largura fixa expandiria de forma imprevisível); visualmente coerente com o PNG. Abaixo de 480px empilha em `Column(stretch)`, reproduzindo o `flex-wrap` do protótipo. Busca e filtro continuam funcionais (`onBusca`/`onFiltro` ligados ao `setState`).

### Cabeçalho e células da tabela

Protótipo: `th{font-size:12px;color:muted;font-weight:500;padding:10px 14px;background:surface-2;text-align:left}`, `.n{text-align:right}`; `td{padding:11px 14px;vertical-align:middle;border-bottom:1px line}`, última linha sem borda.

Código (`responsive_list.dart`, modo `semMoldura`): `padH = 14`, `padVCabecalho = 10`, `padVCelula = 11` ✓ exatos. Cabeçalho com `color:surface2` ✓. Colunas Venda/Líquido/Lucro com `alinhamento:centerRight` ✓. Alinhamento vertical: as `Row` das linhas não definem `crossAxisAlignment`, logo usam o default `center` = `vertical-align:middle` ✓. Separador entre linhas via `Divider(height:1, color:line)`, sem divisor após a última (o `Divider` só é inserido para `i>0`) ✓. O estilo do `th` é `labelLarge` (12,5px) — 0,5px acima do protótipo (12px); diferença declarada aceitável no plano (issue 1).

### Alinhamento ao topo (reclamação "lista no meio")

Protótipo `main{padding-block:32px 64px; padding-inline:max(16,min(4vw,44))}` e `@max-width:760{padding-block:20px 60px; inline:16}`.

Código (`app_shell._Corpo`): `padTopo = estreito?20:32`, `padBase = estreito?60:64`, `padLateral = estreito?16:(largura*0.04).clamp(16,44)` ✓ reproduz a fórmula. O `SingleChildScrollView` alinha o filho ao topo; não há `Center`/`Alignment` vertical na cadeia → o conteúdo começa no topo, corrigindo a reclamação.

### Cabeçalho da página (.head)

Protótipo `.head{display:flex;align-items:flex-end;justify-content:space-between;gap:14px 24px;margin-bottom:24px}`, `h1{26px;600;line-height 1.2;letter-spacing -.02em}`, `p{margin:6px 0 0;max-width:64ch}`.

Código (`page_header.dart`): `margin-bottom:24` ✓; em telas largas `Row(crossAxisAlignment:end)` (= flex-end) com título em `Expanded`, `SizedBox(width:24)` e ações ✓; em estreitas empilha. Subtítulo `SizedBox(height:6)` + `ConstrainedBox(maxWidth:512 ≈ 64ch)` ✓. `h1` = `headlineMedium` (26/600/−0.52 letter-spacing = −.02em de 26px) ✓. Ação "Novo pedido" é `FilledButton.icon` (ícone + texto); o `FilledButtonTheme` aplica `accent`/`accentInk`, radius 8 — bate com `.btn.primary` (accent bg, branco, radius r-s). O padding do botão não é fixado em `8×14` no tema, mas o default do `FilledButton` é visualmente próximo; não bloqueante.

### Ações da linha (.iconbtn)

Protótipo `.iconbtn{width:34;height:34;border:1px line;border-radius:8;background:surface;color:muted}`, hover `surface-2`; `.iconbtn.danger:hover{background:bad-soft;color:bad}`. `.iconrow{gap:6px}`.

Código (`icon_action.dart`): `SizedBox(34×34)` + `Material(color:surface, shape:RoundedRectangleBorder(side:line, radius:Raios.controle=8))` + `InkWell(hoverColor: danger?badSoft:surface2)`, ícone 18px `muted` (ou `bad` se danger) ✓. `Tooltip` + `Semantics(label:)` mantidos (acessibilidade). `confirm_delete_button.dart` espelha o mesmo visual no estado normal (34×34, borda, hover badSoft, ícone `bad`). Gap entre os dois botões: `SizedBox(width: Espacos.g8 - 2)` = 6 = `.iconrow{gap:6px}` ✓. A coluna de ações reserva 120px com `FittedBox(scaleDown)` à direita — comporta dois botões 34px + 6px de gap com folga.

### Sublinhas (.sub)

Protótipo `.ptable .sub{font-size:12px;color:muted;margin-top:3px}`. Código: cada célula (`_CelulaPedido/Itens/Venda/Liquido/Lucro`) troca o gap de `Espacos.base`(4) para `SizedBox(height:3)` ✓; texto da sublinha usa `bodySmall` (12/400 muted) ✓. Conteúdo por coluna confere com `V.pedidos`: Pedido → nome em w600 + `dd/MM/yyyy · PlatformPill`; Itens → "N itens" + abelinhas; Venda → preço + "taxa R$ x"; Líquido → líquido (+ pill "est." quando estimado) + "custo R$ x"; Lucro → valor em `good`(≥0)/`bad`(<0) weight 600 + "x% da venda". A margem usa `percentualFracao` e o lucro colore via `cores.good/bad`.

Nota de formato: o protótipo mostra abelinhas como `6 bee` (`abN`); o app mantém `6 🐝` (`Formatos.abelinhas`) — decisão consciente registrada no plano, consistente com design.md. Não é uma divergência bloqueante de fidelidade visual de layout.

### Estado vazio (.empty)

Protótipo `.empty{padding:32px 16px;text-align:center;color:muted}`. Código (`_Vazio`): `Padding(vertical:32, horizontal:16)`, `Center`, `textAlign:center`, `color:muted` ✓. Renderizado dentro do painel, abaixo da toolbar ✓.

### Tokens e tipografia (inalterados, conferidos)

`tokens.dart` bate byte-a-byte com `:root` do protótipo (claro e escuro): bg #f5f6f8, surface #fff, surface-2 #f1f3f5, ink #1c2128, muted #687280, line #e7e9ee, accent #2b7a70, accent-soft #e8f3f1, good #2e7d55, warn #9a6212, bad #b54a40, bad-soft #fcecea; raios r-s 8 / r-m 14 / pill 6. `tema_app.dart`: headlineMedium 26/600/−.02em, titleMedium 15/600, bodyMedium 14/400, labelLarge 12,5/500 muted, bodySmall 12/400 muted, `tabularFigures`. Nenhum dos dois foi tocado pelo commit.

### Escopo preservado / regressões

`ResponsiveList` é compartilhada (Produtos, Composição, Abelinhas, Caixa, Plataformas). O novo `semMoldura` tem default `false` e o caminho `false` manteve os paddings antigos (16/12) e o card próprio — as demais telas não mudam. `IconAction`/`ConfirmDeleteButton` mudaram só o visual (assinaturas intactas), beneficiando todas as telas. Funcionalidade de Pedidos (busca, filtro por plataforma, abrir editor, excluir com confirmação em duas etapas) preservada. O plano registra `flutter test` 60/60 verde, incluindo `responsive_list_test.dart`.

</details>

<details>
<summary>Arquivos no commit</summary>

- `lib/features/pedidos/presentation/pedidos_page.dart` — painel único, toolbar com border-bottom, tabela `semMoldura`, sublinhas gap 3, estado vazio 32×16, gap de ações 6.
- `lib/core/widgets/responsive_list.dart` — novo `semMoldura` (default false); paddings do protótipo (th 10×14 / td 11×14) no modo sem moldura.
- `lib/core/widgets/icon_action.dart` — visual `.iconbtn` 34×34 (borda, radius 8, hover surface-2 / bad-soft).
- `lib/core/widgets/confirm_delete_button.dart` — estado normal como `.iconbtn danger` 34×34.
- `lib/core/widgets/app_shell.dart` — `_Corpo` com padding do `main` (topo 32/base 64; conteúdo no topo).
- `lib/core/widgets/page_header.dart` — Row flex-end em telas largas, margin-bottom 24, subtítulo 64ch/margin 6.
- `docs/classes/documento_core.md` — doc dos widgets alterados.
- `.agents/tasks/pedidos-fidelidade/plan.md` — plano + evidência de verificação.

Diff completo: `git show 052072c -- lib/`.

</details>
