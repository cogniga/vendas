# Painel: KPIs, quatro painéis e seletor de período

A tela Painel reproduz o protótipo: cabeçalho com período e "Novo pedido", cinco KPIs e uma grade de quatro painéis (vendas por plataforma, pontos de atenção, caixa por destino, itens mais vendidos). Os cálculos são funções puras em `lib/domain/calculos/painel.dart`, os dados vêm de providers Riverpod sem Supabase nos widgets, e a evidência (`verification.md`) mostra analyze limpo, 103 testes passando (inclui painel_test e painel_page_test a 1440 e 400 px) e build macOS ok.

Watch for: alerta de estoque baixo omitido (confirmed, sem `estoque_min`, deliberado); só pedidos `concluido` entram, o protótipo exclui só cancelados (confirmed, alinhado ao design §6.5).

**Verdict**: APPROVED

## High-level view

Os KPIs seguem design §6.5 (faturamento = Σ preço, taxas = Σ taxaEfetiva, margem = lucro/faturamento com guarda de divisão por zero). Os textos de pt-BR batem com o protótipo.

O layout usa Column na raiz, sem ListView nem IntrinsicHeight, com `GradePaineis` por largura mínima. Durante recarga o provider mantém o valor anterior, então o spinner só aparece na primeira carga.

Pontos de atenção reproduzem os textos do protótipo, exceto estoque. O botão "Abrir caixa" tem tooltip e o seletor tem Semantics. Docs de classe criados em docs/classes.

<details>
<summary>Issues (2)</summary>

1. **Spinner na primeira carga** — possible, baixo risco: permanece spinner de 160 px se o provider ainda não tiver dados; aceitável por ser só no primeiro carregamento. Sem ação obrigatória.
2. **Sem comparação visual** — a verificação declara não ter aberto o app contra os prints; conferir manualmente.

</details>

<details>
<summary>Details</summary>

Não houve spot-check adicional; a revisão leu painel_page, painel_paineis, painel.dart e painel_providers e comparou com V.painel.

</details>
