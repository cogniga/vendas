import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sales/domain/entidades/conversores.dart';
import 'package:sales/domain/entidades/enums.dart';

part 'pedido_item.freezed.dart';
part 'pedido_item.g.dart';

/// Item de um pedido — tabela `pedidos_itens`.
///
/// `custoUnitario` e `abelinhasUnitarias` são snapshots no salvamento.
@freezed
class PedidoItem with _$PedidoItem {
  const factory PedidoItem({
    required String id,
    @JsonKey(name: 'empresa_id') required String empresaId,
    @JsonKey(name: 'pedido_id') required String pedidoId,
    required TipoPedidoItem tipo,
    required int quantidade,
    @JsonKey(name: 'custo_unitario')
    @DecimalConverter()
    required Decimal custoUnitario,
    @JsonKey(name: 'abelinhas_unitarias')
    @DecimalConverter()
    required Decimal abelinhasUnitarias,
    @JsonKey(name: 'produto_id') String? produtoId,
    @JsonKey(name: 'produto_venda_id') String? produtoVendaId,
  }) = _PedidoItem;

  factory PedidoItem.fromJson(Map<String, dynamic> json) =>
      _$PedidoItemFromJson(json);
}
