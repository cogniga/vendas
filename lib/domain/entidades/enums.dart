import 'package:json_annotation/json_annotation.dart';

/// Situação de um pedido — check `situacao` em `pedidos`.
enum SituacaoPedido {
  @JsonValue('concluido')
  concluido,
  @JsonValue('cancelado')
  cancelado,
  @JsonValue('devolvido')
  devolvido,
}

/// Tipo de item de pedido — check `tipo` em `pedidos_itens`.
enum TipoPedidoItem {
  @JsonValue('produto')
  produto,
  @JsonValue('produto_venda')
  produtoVenda,
}
