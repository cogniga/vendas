---
inclusion: always
---

# Produto: Balcão Revenda

Sistema de gestão para uma empresa que **compra produtos (cosméticos e acessórios) de distribuidores e revende em marketplaces**: Shopee, TikTok Shop, Mercado Livre e venda direta (WhatsApp/Instagram). Hoje tudo é controlado em planilha; o sistema substitui a planilha.

## Quem usa
- O dono da revenda (perfil financeiro, usa no computador e às vezes no celular).
- Eventualmente um operador que lança pedidos.

## O que o sistema resolve
1. **Cadastro de produtos** comprados para revenda, com custo unitário e "abelinhas" (unidade de valor interna calculada pelo custo).
2. **Composição de custo**: montar um *produto de venda* (kit) a partir de um ou mais produtos e ver custo, taxa, líquido, lucro, margem, ROI e metas **em todas as plataformas de uma vez**.
3. **Pedidos**: lançar a venda, escolher a plataforma, itens, preço e o líquido que a plataforma pagou; o sistema calcula custo, taxa estimada, lucro e abelinhas.
4. **Plataformas e taxas**: cada plataforma cobra valor fixo + percentual, por faixa de preço.
5. **Compras de insumos** (caixas, etiquetas, papel) e **investimento** (compra de mercadoria por distribuidor).
6. **Caixa e saques**: cada saque das plataformas é dividido automaticamente entre destinos (ex.: Cartão/empréstimos 40%, Compras de produtos 30%, Pró-labore 30%); compras e investimentos saem dos destinos.
7. **Regra de abelinhas**: tabela de faixas de custo → abelinhas, com análise de ROI conforme o valor de 1 abelinha.

## Princípios de produto
- Resumo antes do detalhe; números sempre em R$ no formato brasileiro (`R$ 1.234,56`).
- Estado visível por cor e forma (pills de lucro/atenção/prejuízo).
- Nenhuma lista com rolagem horizontal: em tela estreita as linhas viram cartões.
- Textos seguem o **padrão de escrita** (ver `design.md` §8).
- Idioma: **português do Brasil** em toda a interface.

## Referência visual e funcional
O protótipo funcional completo está em `docs/prototipo/balcao-revenda.html` (abra no navegador). Ele é a **fonte da verdade** de comportamento, cálculos e layout. Em caso de dúvida, reproduza o que o protótipo faz, salvo onde `design.md` diz explicitamente que muda.
