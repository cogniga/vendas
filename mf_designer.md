# mf_designer — Balcão Revenda

> Documento de design de referência exigido pelas regras do projeto.
> Fonte canônica completa: `.kiro/specs/balcao-revenda/design.md` (§6 cálculos/vetores,
> §7 tokens/tipografia/breakpoints, §8 padrão de escrita) e o protótipo
> `docs/prototipo/balcao-revenda.html` (fonte da verdade de comportamento e layout).

## Tokens de cor (§7.1)

| Token | Claro | Escuro | Uso |
|---|---|---|---|
| bg | #F5F6F8 | #111418 | fundo |
| surface | #FFFFFF | #181C21 | cartões, painéis |
| surface2 | #F1F3F5 | #20252C | cabeçalho de tabela, hover, chips |
| ink | #1C2128 | #E9ECF0 | texto |
| muted | #687280 | #9AA3AE | texto secundário |
| line | #E7E9EE | #2A3038 | bordas |
| accent | #2B7A70 | #6CC3B6 | ação principal, item ativo |
| accentInk | #FFFFFF | #0D1F1C | texto sobre accent |
| accentSoft | #E8F3F1 | #1C2F2C | fundo do ativo, aviso informativo |
| good / goodSoft | #2E7D55 / #E9F5EE | #6FCF9A / #17291F | lucro |
| warn / warnSoft | #9A6212 / #FBF3E4 | #E3B065 / #2E2615 | atenção |
| bad / badSoft | #B54A40 / #FCECEA | #EE8F86 / #331D1B | prejuízo, excluir |

Cores dos destinos padrão: #6A9FD8, #6FB59A, #E5BF55.

## Tipografia (§7.2) — Plus Jakarta Sans

Título de página 26/600 (−0,02em); título de painel 15/600; KPI 22/600 tabular;
corpo 14/400; rótulos 12,5/500 muted; sublinha de lista 12/400 muted; código 11,5/600
em chip. Números sempre com `FontFeature.tabularFigures()`.

## Forma (§7.3)

Raios: 8 (controles), 14 (cartões/painéis), 6 (pills). Sombra leve
`0 1px 2px rgba(16,24,40,.04)`. Espaçamento base 4; gaps 8/12/16/20; padding de painel
20 (16 no celular).

## Breakpoints (§7.4)

| Largura | Menu | Listas |
|---|---|---|
| ≥ 1380 | lateral 264 | tabela (todas) |
| 1200–1379 | lateral 264 | tabela, exceto Composição e Abelinhas (cartões) |
| 1100–1199 | lateral 264 | cartões 4 colunas |
| 760–1099 | lateral 240 | cartões 4 colunas |
| 600–759 | barra superior + gaveta | cartões 4 colunas |
| < 600 | barra superior + gaveta | cartões 2 colunas |

`ResponsiveList` decide pela largura disponível do próprio widget (LayoutBuilder),
limiar ~780 px (listas largas ~990 px). Nenhuma tela com rolagem horizontal.

## Componentes compartilhados (§5)

`AppShell`, `PageHeader`, `KpiCard`/`KpiRow`, `ResponsiveList<T>`, `IconAction`,
`ConfirmDeleteButton`, `Pill` (neutro|bom|atencao|ruim|destaque), `PlatformPill`,
`CodeChip`, `Ledger`, `MoneyField`, `TextCaseField`, `Abelinhas`.

## Padrão de escrita (§8)

- `titulo`: Título com conectivos minúsculos (nomes, marca, fornecedor, kit, distribuidor).
- `maius`: tudo maiúsculo (código, cliente/nº do pedido, nota).
- `frase`: só a 1ª letra maiúscula (categoria, descrição, destino, observações).
- Textos da interface (botões/títulos): só a primeira letra maiúscula.

## Estados (§10)

Carregando → skeletons; vazio → mensagem + ação; erro de rede → snackbar "Tentar de
novo" sem perder o formulário; validação → mensagem ao lado do campo; exclusão bloqueada
por vínculo → diálogo explicando.

> Cálculos e vetores de teste (§6) e telas-chave (§7.5) estão em
> `.kiro/specs/balcao-revenda/design.md` — consultar sempre antes de implementar.
