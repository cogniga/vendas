# documento_PedidoEditor
- **Arquivo:** `lib/features/pedidos/presentation/pedido_editor.dart`
- **Responsabilidade:** editor de pedido em painel largo, fiel ao protótipo. Portão de carregamento (`PedidoEditor`) + formulário privado `_PedidoForm`. Detalhes em `documento_features.md` (seção documento_PedidoEditor) e decisão D10.
- **Dados:** `pedidoCompletoProvider(id)` (pedido com itens), `dadosEdicaoPedidoProvider`, `pedidoRepositoryProvider.salvar`.
- **Itens:** snapshot de custo/abelinhas preservado para itens já gravados; itens novos usam o cadastro atual.
- **Função pública:** `rotuloSituacao(SituacaoPedido)` → Pago / Devolvido / Cancelado.
