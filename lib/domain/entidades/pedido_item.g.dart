// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedido_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PedidoItemImpl _$$PedidoItemImplFromJson(Map<String, dynamic> json) =>
    _$PedidoItemImpl(
      id: json['id'] as String,
      empresaId: json['empresa_id'] as String,
      pedidoId: json['pedido_id'] as String,
      tipo: $enumDecode(_$TipoPedidoItemEnumMap, json['tipo']),
      quantidade: (json['quantidade'] as num).toInt(),
      custoUnitario: const DecimalConverter().fromJson(
        json['custo_unitario'] as Object,
      ),
      abelinhasUnitarias: const DecimalConverter().fromJson(
        json['abelinhas_unitarias'] as Object,
      ),
      produtoId: json['produto_id'] as String?,
      produtoVendaId: json['produto_venda_id'] as String?,
    );

Map<String, dynamic> _$$PedidoItemImplToJson(_$PedidoItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'empresa_id': instance.empresaId,
      'pedido_id': instance.pedidoId,
      'tipo': _$TipoPedidoItemEnumMap[instance.tipo]!,
      'quantidade': instance.quantidade,
      'custo_unitario': const DecimalConverter().toJson(instance.custoUnitario),
      'abelinhas_unitarias': const DecimalConverter().toJson(
        instance.abelinhasUnitarias,
      ),
      'produto_id': instance.produtoId,
      'produto_venda_id': instance.produtoVendaId,
    };

const _$TipoPedidoItemEnumMap = {
  TipoPedidoItem.produto: 'produto',
  TipoPedidoItem.produtoVenda: 'produto_venda',
};
