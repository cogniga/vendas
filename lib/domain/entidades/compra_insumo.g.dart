// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compra_insumo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CompraInsumoImpl _$$CompraInsumoImplFromJson(Map<String, dynamic> json) =>
    _$CompraInsumoImpl(
      id: json['id'] as String,
      empresaId: json['empresa_id'] as String,
      data: DateTime.parse(json['data'] as String),
      produto: json['produto'] as String,
      valorTotal: const DecimalConverter().fromJson(
        json['valor_total'] as Object,
      ),
      tipo: json['tipo'] as String? ?? 'Embalagem',
      descricao: json['descricao'] as String? ?? '',
      pacotes: (json['pacotes'] as num?)?.toInt() ?? 1,
      itens: (json['itens'] as num?)?.toInt() ?? 1,
      destinoId: json['destino_id'] as String?,
    );

Map<String, dynamic> _$$CompraInsumoImplToJson(_$CompraInsumoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'empresa_id': instance.empresaId,
      'data': instance.data.toIso8601String(),
      'produto': instance.produto,
      'valor_total': const DecimalConverter().toJson(instance.valorTotal),
      'tipo': instance.tipo,
      'descricao': instance.descricao,
      'pacotes': instance.pacotes,
      'itens': instance.itens,
      'destino_id': instance.destinoId,
    };
