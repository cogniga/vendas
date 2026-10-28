// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'retirada.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RetiradaImpl _$$RetiradaImplFromJson(Map<String, dynamic> json) =>
    _$RetiradaImpl(
      id: json['id'] as String,
      empresaId: json['empresa_id'] as String,
      data: DateTime.parse(json['data'] as String),
      destinoId: json['destino_id'] as String,
      valor: const DecimalConverter().fromJson(json['valor'] as Object),
      descricao: json['descricao'] as String? ?? '',
    );

Map<String, dynamic> _$$RetiradaImplToJson(_$RetiradaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'empresa_id': instance.empresaId,
      'data': instance.data.toIso8601String(),
      'destino_id': instance.destinoId,
      'valor': const DecimalConverter().toJson(instance.valor),
      'descricao': instance.descricao,
    };
