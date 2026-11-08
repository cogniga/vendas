# documento_PedidoResumo
- **Arquivo:** `lib/features/pedidos/presentation/pedido_resumo.dart`
- **Responsabilidade:** resumo financeiro do editor de pedido (coluna direita do protótipo). Recebe valores já calculados e formatados pelo editor; nenhum cálculo de negócio.
- **Seções:** Custo do pedido (Mercadoria, Embalagem + impressão + outros, caixa cinza "Custo total"); Abelinhas do pedido (linha por item ou "Nenhum item ainda", "Total de abelinhas", "Valem com 1 🐝 = R$ x"); Venda (preço, taxa estimada com plataforma e fórmula, líquido estimado, "Líquido considerado" com `Pill` `estimado`/`informado`, taxa efetiva); caixa cinza "Lucro do pedido" (cor `bad` se negativo, `good` senão); "Margem sobre a venda"; avisos opcionais (preço do kit em `accentSoft`, líquido divergente em `warnSoft`).
- **Reutiliza:** `Ledger`, `Pill`, tokens de `lib/core/theme/tokens.dart`.
