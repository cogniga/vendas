// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedido.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PedidoImpl _$$PedidoImplFromJson(Map<String, dynamic> json) => _$PedidoImpl(
  id: json['id'] as String,
  empresaId: json['empresa_id'] as String,
  data: DateTime.parse(json['data'] as String),
  cliente: json['cliente'] as String,
  plataformaId: json['plataforma_id'] as String,
  embalagem: const DecimalConverter().fromJson(json['embalagem'] as Object),
  impressao: const DecimalConverter().fromJson(json['impressao'] as Object),
  outros: const DecimalConverter().fromJson(json['outros'] as Object),
  precoVenda: const DecimalConverter().fromJson(json['preco_venda'] as Object),
  itensTaxaFixa: (json['itens_taxa_fixa'] as num?)?.toInt() ?? 1,
  liquidoInformado: const DecimalNullableConverter().fromJson(
    json['liquido_informado'],
  ),
  situacao:
      $enumDecodeNullable(_$SituacaoPedidoEnumMap, json['situacao']) ??
      SituacaoPedido.concluido,
  obs: json['obs'] as String? ?? '',
);

Map<String, dynamic> _$$PedidoImplToJson(_$PedidoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'empresa_id': instance.empresaId,
      'data': instance.data.toIso8601String(),
      'cliente': instance.cliente,
      'plataforma_id': instance.plataformaId,
      'embalagem': const DecimalConverter().toJson(instance.embalagem),
      'impressao': const DecimalConverter().toJson(instance.impressao),
      'outros': const DecimalConverter().toJson(instance.outros),
      'preco_venda': const DecimalConverter().toJson(instance.precoVenda),
      'itens_taxa_fixa': instance.itensTaxaFixa,
      'liquido_informado': const DecimalNullableConverter().toJson(
        instance.liquidoInformado,
      ),
      'situacao': _$SituacaoPedidoEnumMap[instance.situacao]!,
      'obs': instance.obs,
    };

const _$SituacaoPedidoEnumMap = {
  SituacaoPedido.concluido: 'concluido',
  SituacaoPedido.cancelado: 'cancelado',
  SituacaoPedido.devolvido: 'devolvido',
};
