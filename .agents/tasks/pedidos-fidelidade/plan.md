# Plano — Fidelidade visual da tela de Pedidos

Objetivo: deixar `lib/features/pedidos/presentation/pedidos_page.dart` visualmente
idêntica ao protótipo (`docs/prototipo/balcao-revenda.html`, função `V.pedidos` +
bloco `<style>`) e à imagem `docs/telas/02-pedidos.png`. Peso médio, uma única
preocupação: fidelidade visual.

## Contexto verificado (o que já bate e o que diverge)

Investiguei o código real e o protótipo. Resumo:

- `lib/core/theme/tokens.dart` — os tokens de cor (claro/escuro) JÁ batem byte a
  byte com `:root` do protótipo (bg #f5f6f8, surface #fff, surface-2 #f1f3f5,
  ink #1c2128, muted #687280, line #e7e9ee, accent #2b7a70, accent-soft #e8f3f1,
  good #2e7d55, warn #9a6212, bad #b54a40). **Não mexer nas cores.**
- `lib/core/theme/tema_app.dart` — tipografia já aproxima o protótipo
  (headlineMedium 26/600 −0.52, titleMedium 15/600, bodyMedium 14/400,
  labelLarge 12.5/500 muted, bodySmall 12/400 muted, tabularFigures). Pequenos
  ajustes de alinhamento de `letterSpacing`/pesos são opcionais; o foco são os
  problemas estruturais abaixo.
- `lib/core/widgets/page_header.dart` — já faz Row (título esquerda / ações
  direita) em telas largas e empilha em estreitas. Precisa de refinamento fino
  (ver item 2), não de reescrita.

### Diferença estrutural principal (causa do visual "quebrado")

No protótipo a hierarquia é: `head` (fora do card) → **UM** `section.panel`
(card: surface, borda 1px line, radius 14, overflow hidden, sombra leve) que
contém, no topo, a `.toolbar` (busca+filtro, padding 14x20, border-bottom 1px
line) e **logo abaixo, encostada**, a `table.ptable` sem margens.

No código atual há **card dentro de card**: `_Conteudo` desenha um
`Container(padding: EdgeInsets.all(16))` com borda+radius, e dentro dele a
`ResponsiveList` (`_Tabela`) desenha **outro** `Container` com borda+radius. Isso
gera borda dupla, cantos internos e espaçamento solto (toolbar com padding 16 em
volta + `SizedBox(16)` + tabela com borda própria). É o que o usuário vê como
"textos/lista fora de lugar, sem alinhamento".

Decisão de design: o `.panel` passa a ser desenhado UMA única vez, em
`pedidos_page.dart`. A `ResponsiveList`/`_Tabela` deixa de desenhar o próprio
card (passa a ser "sem moldura") quando usada dentro de um painel, para a
toolbar e a tabela ficarem encostadas e sem borda dupla. Para não quebrar as
outras telas que usam `ResponsiveList` (Produtos, Composição, Abelinhas, Caixa,
Plataformas), adiciono um parâmetro opcional `semMoldura` (default `false`), e só
Pedidos passa `true`. Assim o comportamento atual das demais telas é preservado.

### Divergências de valor (campo a campo) a aplicar

Painel (card único em `pedidos_page.dart`):
- fundo `cores.surface`; borda `1px cores.line`; radius `Raios.cartao` (14);
  `clipBehavior: Clip.antiAlias` (= overflow hidden). Sem padding externo no card.

Toolbar (dentro do painel, no topo):
- padding `vertical 14, horizontal 20` (protótipo `.toolbar{padding:14px 20px}`);
- `border-bottom: 1px cores.line` (separa da tabela);
- busca ocupa o espaço disponível (`flex:1 1 220px`), filtro largura automática
  (no protótipo `select{width:auto}`); em telas estreitas quebram em duas linhas
  (`Wrap` já faz isso). Hoje a busca tem `width:320` fixo e o filtro `width:240` —
  trocar para busca expansível + filtro com largura por conteúdo.

Cabeçalho da tabela (`th`):
- padding `vertical 10, horizontal 14` (hoje 12/16);
- fundo `cores.surface2`; fonte 12/500 muted (labelLarge já ~12.5/500 — aceitável);
- colunas numéricas (Venda, Líquido, Lucro, Ações) alinhadas à direita
  (já ocorre via `c.alinhamento`); manter rótulo "Ações" à direita na coluna de ações.

Células (`td`):
- padding `vertical 11, horizontal 14` (hoje 12/16);
- `border-bottom: 1px cores.line`, última linha sem borda (hoje usa `Divider`
  entre linhas — equivalente, manter);
- alinhamento vertical ao MEIO (`CrossAxisAlignment.center` nas linhas; hoje é
  `start`) — o protótipo usa `vertical-align:middle`;
- hover de linha = fundo surface-2 (opcional em desktop; se simples, usar
  `MouseRegion`/`InkWell`; caso contrário, deixar como melhoria e registrar).

Sublinhas (`.sub`): 12px muted, `margin-top:3px`. Hoje usa `Espacos.base` (4) —
trocar o gap das sublinhas para 3 nas células de pedido.

Coluna de ações:
- largura estreita à direita; dois `IconAction` (olho=abrir, lixeira=excluir).
  Protótipo usa `.iconbtn` 34x34, borda 1px line, radius 8, cor muted, hover
  surface-2 (excluir hover vermelho). Hoje `IconAction` é um `IconButton` sem
  moldura. Ajustar `IconAction` para o visual `.iconbtn` (quadrado 34x34, borda,
  radius 8) — cuidado: `IconAction` é usado em várias telas; manter assinatura,
  mudar só o visual (todas as telas se beneficiam).

Formato "abelinhas": o protótipo mostra `6 bee` (função `abN`); o app mostra
`6 🐝` (`Formatos.abelinhas`). Manter o emoji é uma escolha local válida, mas o
brief do usuário cita "X bee". **Decisão:** manter `🐝` (consistente com o resto
do app e com design.md) e registrar como diferença consciente; não alterar
`Formatos.abelinhas` salvo pedido explícito.

Alinhamento ao topo (reclamação "lista no meio"): o encadeamento atual é
`Scaffold.body → _Corpo (SingleChildScrollView, padding all) → PedidosPage
(Column mainAxisSize.min)`. Um `SingleChildScrollView` já alinha o filho ao topo,
então não reproduzi o "centralizado verticalmente" só lendo o código.
**Verificar durante a implementação** rodando o app; se aparecer centralizado,
a causa provável é algum `Center`/`Alignment` herdado ou o padding do `_Corpo`
(16/20) diferente do protótipo (topo 32). Ajuste alvo: `_Corpo` com padding
topo ~32 em telas largas (protótipo `main{padding-block:32px 64px}`), mantendo
laterais responsivas, e garantir `crossAxisAlignment.stretch` / topo.

## Itens

- [x] 1. Adicionar modo "sem moldura" à ResponsiveList para permitir uso dentro de um painel externo sem borda dupla.
      Adicionar `final bool semMoldura` (default `false`) ao construtor de
      `ResponsiveList`. Em `_Tabela`, quando `semMoldura == true`, NÃO desenhar o
      `Container` com `color/border/borderRadius/clipBehavior` (renderizar só a
      `Column` com cabeçalho + linhas). Ajustar padding do cabeçalho para
      `vertical 10, horizontal 14` e das linhas para `vertical 11, horizontal 14`,
      e trocar `crossAxisAlignment` das linhas e do cabeçalho de `start` para
      `center` (vertical-align middle). Manter o comportamento atual (com moldura
      e paddings atuais) quando `semMoldura == false` para não afetar as outras
      telas. Reduzir o gap das sublinhas de `Espacos.base` para 3 onde aplicável
      é feito nas células (item 4), não aqui.
      Files: lib/core/widgets/responsive_list.dart
      Verify: `cd /Users/raquel/Documents/projetos/front/private/sales && flutter analyze lib/core/widgets/responsive_list.dart` sem erros; `flutter test` continua verde (telas Produtos/Composição/Abelinhas/Caixa/Plataformas inalteradas pois usam o default).

- [x] 2. Refinar o IconAction para o visual `.iconbtn` do protótipo (quadrado com borda), preservando a assinatura.
      Trocar o `IconButton` por um botão quadrado 34x34 com `border: 1px
      cores.line`, `borderRadius: Raios.controle` (8), fundo `cores.surface`, cor
      do ícone `cores.muted`; hover → fundo `cores.surface2` (e, quando
      `danger`, hover → fundo `cores.badSoft`, cor `cores.bad`). Manter
      `Semantics(label:)` + `Tooltip` obrigatórios. Como `IconAction` é usado em
      várias telas, só muda o visual (melhora geral); não alterar parâmetros.
      Confirmar que `ConfirmDeleteButton` (usado na coluna de ações) continua
      coerente visualmente; se ele renderizar o próprio botão, alinhar o tamanho
      a 34x34 também.
      Files: lib/core/widgets/icon_action.dart (e conferir lib/core/widgets/confirm_delete_button.dart)
      Verify: `flutter analyze lib/core/widgets/icon_action.dart lib/core/widgets/confirm_delete_button.dart` sem erros.

- [x] 3. Reestruturar `_Conteudo` da PedidosPage para um único painel: toolbar no topo (com border-bottom) e tabela encostada abaixo, sem card interno.
      Substituir o `Container(padding: EdgeInsets.all(16))` + `SizedBox(16)` +
      `ResponsiveList` por: um `Container` painel (surface, borda 1px line,
      radius 14, `clipBehavior: Clip.antiAlias`) contendo uma `Column` com (a) a
      `_Barra` dentro de um `Padding(vertical:14, horizontal:20)` com um
      `Border(bottom: 1px line)` abaixo, e (b) a `ResponsiveList(... semMoldura:
      true)` logo abaixo, sem padding externo. O estado vazio (`_Vazio`) deve
      aparecer dentro do painel, abaixo da toolbar, com padding equivalente ao
      `.empty` do protótipo (`padding:32px 16px`, texto centralizado muted).
      Files: lib/features/pedidos/presentation/pedidos_page.dart
      Verify: `flutter analyze lib/features/pedidos/presentation/pedidos_page.dart` sem erros.

- [x] 4. Ajustar a `_Barra` (toolbar) e as células da PedidosPage aos valores do protótipo.
      Na `_Barra`: busca expansível (ocupando o espaço, em vez de `width:320`
      fixo) e filtro com largura por conteúdo (em vez de `width:240`), mantendo
      `Wrap` para quebrar em telas estreitas; usar os ícones/placeholders atuais
      ("Buscar cliente ou nº do pedido", "Todas as plataformas"). Nas células
      (`_CelulaPedido`, `_CelulaItens`, `_CelulaVenda`, `_CelulaLiquido`,
      `_CelulaLucro`): reduzir o espaçamento entre valor e sublinha de
      `Espacos.base` (4) para 3 (`.sub{margin-top:3px}`); confirmar o nome do
      pedido em weight 600, sublinha "dd/MM/yyyy · <PlatformPill>", "N itens" +
      sublinha abelinhas, "Venda" + "taxa R$ x", "Líquido" (+ pill "est.") +
      "custo R$ x", "Lucro" em verde (good, >=0) / vermelho (bad, <0) weight 600
      + "x% da venda". Esses conteúdos já existem; ajustar apenas espaçamentos e
      pesos onde divergirem. Manter o emoji 🐝 (decisão registrada no contexto).
      Files: lib/features/pedidos/presentation/pedidos_page.dart
      Verify: `flutter analyze lib/features/pedidos/presentation/pedidos_page.dart` sem erros.

- [x] 5. Garantir conteúdo alinhado ao topo com padding de topo ~32 (protótipo `main{padding-block:32px 64px}`) e refinar o PageHeader.
      Em `lib/core/widgets/app_shell.dart` (`_Corpo`): aplicar padding assimétrico
      — topo 32 (em telas largas; ~20 no celular, protótipo
      `@max-width:760{padding-block:20px 60px}`), base 64/60, laterais
      responsivas como hoje — garantindo que o conteúdo COMECE no topo (o
      `SingleChildScrollView` já alinha ao topo; só ajustar o padding). No
      `PageHeader`: título h1 26/600 (−0.02em, já no tema), subtítulo muted com
      `maxWidth ~64ch` e `margin-top 6` (`Espacos.base+2`), `margin-bottom 24`
      (`Espacos.g20` já é 20; subir para 24 via Padding dedicado). Validar que a
      ação "Novo pedido" fica no canto superior direito com ícone + texto
      (FilledButton.icon já faz isso) e alinhada ao fim (`align-items:flex-end`).
      Files: lib/core/widgets/app_shell.dart, lib/core/widgets/page_header.dart
      Verify: `flutter analyze lib/core/widgets/app_shell.dart lib/core/widgets/page_header.dart` sem erros; as demais telas continuam com layout coerente (o padding do `_Corpo` é compartilhado — conferir Painel/Produtos ainda OK).

- [x] 6. Validação visual final e build completo.
      Rodar o build e os testes do projeto. Abrir a tela de Pedidos (desktop
      macOS) e comparar lado a lado com `docs/telas/02-pedidos.png`: conteúdo
      começa no topo; título à esquerda e "Novo pedido" no canto superior
      direito; um único card com toolbar no topo e tabela encostada (sem borda
      dupla); cabeçalhos numéricos à direita; "Lucro" verde/vermelho; pills e
      sublinhas corretas; em telas estreitas as linhas viram cartões (sem rolagem
      horizontal). Confirmar especialmente a reclamação do usuário ("lista no
      meio"): se ainda aparecer centralizado, investigar `Center`/`Alignment`
      herdado e corrigir.
      Files: (nenhum — verificação)
      Verify: `cd /Users/raquel/Documents/projetos/front/private/sales && flutter analyze` sem erros e `flutter test` verde; inspeção visual em `flutter run -d macos` batendo com o PNG do protótipo.

## Resultados da verificação (iteração 1)

Rodado nesta ordem, todos verdes:

1. `dart run build_runner build --delete-conflicting-outputs` → OK
   ("Built with build_runner in 19s; wrote 3 outputs").
2. `flutter analyze lib test` → "No issues found!" (zero issues).
3. `flutter test` → "All tests passed!" (60 testes, +60). O teste
   `test/widgets/responsive_list_test.dart` continua verde sem alteração
   (o novo parâmetro `semMoldura` tem default `false`, preservando o markup
   usado por Produtos/Composição/Abelinhas/Caixa/Plataformas).
4. `flutter build macos --dart-define-from-file=env/supabase.json` →
   "✓ Built build/macos/Build/Products/Release/sales.app (50.4MB)".

### O que mudou (fidelidade visual de Pedidos)

- `responsive_list.dart`: novo `semMoldura` (default `false`); no modo sem
  moldura não desenha card próprio e usa paddings do protótipo (th 10x14,
  td 11x14); alinhamento vertical das linhas passou a `center`
  (vertical-align middle).
- `icon_action.dart` e `confirm_delete_button.dart`: botões de ação viraram
  `.iconbtn` 34x34 (borda 1px line, radius 8, muted; hover surface-2 / bad-soft
  no danger). Assinaturas preservadas.
- `pedidos_page.dart`: um único painel (surface, borda 1px line, radius 14,
  overflow hidden) com a toolbar no topo (padding 14x20 + border-bottom) e a
  tabela encostada abaixo (sem card interno / borda dupla); busca expansível +
  filtro com largura fixa 240 (empilham < 480); sublinhas com gap 3
  (`.sub{margin-top:3px}`); estado vazio dentro do painel (padding 32x16).
- `app_shell.dart` (`_Corpo`): padding do protótipo `main` (topo 32 / base 64,
  laterais 4vw 16–44; celular topo 20 / base 60 / laterais 16); conteúdo
  alinhado ao TOPO (nunca centralizado verticalmente).
- `page_header.dart`: `margin-bottom:24`, Row em tela larga alinhado pela base
  (`align-items:flex-end`), subtítulo `margin-top:6` + `max-width ~64ch`.
- Tokens de cor conferidos — já batiam com o protótipo; não alterados.
- `docs/classes/documento_core.md` atualizado para os widgets alterados.

Observação: os arquivos de `lib/features/caixa/**` aparecem modificados no
repositório, mas são trabalho de outra tarefa (bugs de caixa/saques) e NÃO
fazem parte deste commit — apenas os arquivos da fidelidade de Pedidos foram
commitados.

## Observações / lacunas

- Hover de linha (fundo surface-2) e hover do `.iconbtn` são detalhes de desktop;
  se exigirem `MouseRegion`/`StatefulWidget` e complicarem, podem ser tratados
  como refinamento e registrados, sem bloquear a entrega.
- O emoji 🐝 é mantido em vez de "bee" por consistência com design.md e o resto
  do app (decisão consciente; reverter só a pedido do usuário).
- `ResponsiveList` é compartilhada: a mudança usa parâmetro opcional
  `semMoldura` com default que preserva o comportamento atual das outras telas.
  `flutter test` deve confirmar que nada quebrou.
