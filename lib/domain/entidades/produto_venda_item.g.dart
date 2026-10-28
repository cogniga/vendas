// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'produto_venda_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProdutoVendaItemImpl _$$ProdutoVendaItemImplFromJson(
  Map<String, dynamic> json,
) => _$ProdutoVendaItemImpl(
  id: json['id'] as String,
  empresaId: json['empresa_id'] as String,
  produtoVendaId: json['produto_venda_id'] as String,
  produtoId: json['produto_id'] as String,
  quantidade: (json['quantidade'] as num).toInt(),
);

Map<String, dynamic> _$$ProdutoVendaItemImplToJson(
  _$ProdutoVendaItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'empresa_id': instance.empresaId,
  'produto_venda_id': instance.produtoVendaId,
  'produto_id': instance.produtoId,
  'quantidade': instance.quantidade,
};
