// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preco_plataforma.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PrecoPlataformaImpl _$$PrecoPlataformaImplFromJson(
  Map<String, dynamic> json,
) => _$PrecoPlataformaImpl(
  empresaId: json['empresa_id'] as String,
  produtoVendaId: json['produto_venda_id'] as String,
  plataformaId: json['plataforma_id'] as String,
  preco: const DecimalNullableConverter().fromJson(json['preco']),
  desconto: const DecimalNullableConverter().fromJson(json['desconto']),
  cupom: const DecimalNullableConverter().fromJson(json['cupom']),
  vendidosIniciais: (json['vendidos_iniciais'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$PrecoPlataformaImplToJson(
  _$PrecoPlataformaImpl instance,
) => <String, dynamic>{
  'empresa_id': instance.empresaId,
  'produto_venda_id': instance.produtoVendaId,
  'plataforma_id': instance.plataformaId,
  'preco': const DecimalNullableConverter().toJson(instance.preco),
  'desconto': const DecimalNullableConverter().toJson(instance.desconto),
  'cupom': const DecimalNullableConverter().toJson(instance.cupom),
  'vendidos_iniciais': instance.vendidosIniciais,
};
